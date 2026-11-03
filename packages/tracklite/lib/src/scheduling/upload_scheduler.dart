import 'dart:async';

import 'package:clock/clock.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/connectivity/network_monitor.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/scheduling/app_lifecycle.dart';
import 'package:tracklite/src/upload/upload_manager.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';

/// Whether the scheduler may start its timers (the interval, the retry).
/// A host's widget tests turn them off (`TrackLiteTesting.disableTimers`):
/// a test fails if a timer is still pending when it ends.
@internal
bool schedulerTimersEnabled = true;

/// Decides *when* uploads run, so the app never has to call `flush()`.
///
/// | Trigger | When |
/// |---|---|
/// | `interval` | every `flushInterval`, while the app is in the foreground |
/// | `threshold` | a write leaves `batchSize` events due: a full batch is ready |
/// | `paused` | the app goes to the background: its last chance before the OS may kill it |
/// | `reconnect` | the network comes back |
/// | `retryDue` | the earliest retry time arrives (one timer, re-armed after each run) |
///
/// None of them runs while offline or while the API key is rejected; each
/// respects backoff (only an explicit `flush()` ignores it). The scheduler
/// only *asks*: the uploader is single-flight, so triggers that pile up
/// join one run.
@internal
final class UploadScheduler {
  UploadScheduler({
    required this._upload,
    required this._dueCount,
    required this._nextRetryAt,
    required this._monitor,
    required this._lifecycle,
    required this.interval,
    required this.threshold,
    required this._paused,
    required this._logger,
    Clock? clock,
  }) : _clock = clock ?? const Clock();

  final Future<FlushResult> Function(UploadTrigger trigger) _upload;
  final Future<int> Function() _dueCount;
  final Future<DateTime?> Function() _nextRetryAt;
  final NetworkMonitor _monitor;
  final AppLifecycle _lifecycle;
  final Duration interval;
  final int threshold;
  final bool Function() _paused;
  final TrackLiteLogger _logger;
  final Clock _clock;

  final _subscriptions = <StreamSubscription<bool>>[];
  Timer? _interval;
  Timer? _retry;
  bool _running = false;

  void start() {
    if (_running) return;
    _running = true;
    _subscriptions
      ..add(_lifecycle.watchForeground().listen(_foregroundChanged))
      // The monitor's stream starts with the current value: only a
      // `false → true` after it is a reconnect.
      ..add(_monitor.watch().skip(1).listen(_onlineChanged));
    if (_lifecycle.isForeground) _startForegroundTimers();
  }

  Future<void> stop() async {
    _running = false;
    _interval?.cancel();
    _retry?.cancel();
    await Future.wait([for (final s in _subscriptions) s.cancel()]);
    _subscriptions.clear();
  }

  /// The recorder stored [inserted] events: a full batch may be ready.
  Future<void> stored(int inserted) async {
    if (!_running || inserted == 0) return;
    if (await _dueCount() >= threshold) await _trigger(UploadTrigger.threshold);
  }

  void _foregroundChanged(bool foreground) {
    if (foreground) {
      _startForegroundTimers();
    } else {
      // Timers don't run in the background; the background task takes
      // over. Send what's waiting while the app still can.
      _interval?.cancel();
      _retry?.cancel();
      unawaited(_trigger(UploadTrigger.paused));
    }
  }

  void _onlineChanged(bool online) {
    if (online) unawaited(_trigger(UploadTrigger.reconnect));
  }

  void _startForegroundTimers() {
    if (!schedulerTimersEnabled) return;
    _interval?.cancel();
    _interval = Timer.periodic(
      interval,
      (_) => unawaited(_trigger(UploadTrigger.interval)),
    );
    unawaited(_armRetry());
  }

  Future<void> _trigger(UploadTrigger trigger) async {
    if (!_running) return;
    if (!_monitor.isOnline) {
      _logger.debug('${trigger.name}: offline, nothing attempted');
      return;
    }
    if (_paused()) {
      _logger.debug('${trigger.name}: paused (the API key was rejected)');
      return;
    }
    await _upload(trigger);
    await _armRetry();
  }

  /// One timer for the earliest retry: when it fires, the events whose wait
  /// is over are due, and the run re-arms it for the next.
  ///
  /// Only for a time still ahead. A retry time already past belongs to an
  /// event that is due now, and the interval or a reconnect sends it: an
  /// event whose server is unreachable keeps its old retry time (no attempt
  /// is counted), and re-arming "at once" for it would loop as fast as the
  /// uploads fail.
  Future<void> _armRetry() async {
    final next = await _nextRetryAt();
    _retry?.cancel();
    if (!_running || next == null || !_lifecycle.isForeground) return;
    if (!schedulerTimersEnabled) return;
    final wait = next.difference(_clock.now());
    if (wait <= Duration.zero) return;
    _retry = Timer(wait, () => unawaited(_trigger(UploadTrigger.retryDue)));
  }
}
