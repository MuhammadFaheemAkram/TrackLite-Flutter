import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';

/// One event an [AnalyticsService] was asked to track. A value: two with the
/// same name and properties are equal (a record holding a `Map` wouldn't be,
/// since maps compare by identity).
@immutable
final class Tracked {
  const Tracked(this.event, [this.properties = const {}]);

  final String event;
  final Map<String, Object> properties;

  @override
  bool operator ==(Object other) =>
      other is Tracked &&
      other.event == event &&
      mapEquals(other.properties, properties);

  @override
  int get hashCode =>
      Object.hash(event, Object.hashAllUnordered(properties.keys));

  @override
  String toString() => 'Tracked($event, $properties)';
}

/// An [AnalyticsService] that remembers what it was asked to do, so a test
/// can check which events a screen sent without starting an SDK. Its
/// identity is whatever the test [emitIdentity]s.
class RecordingAnalytics implements AnalyticsService {
  final List<Tracked> events = [];
  final List<String?> identities = [];
  final _identity = StreamController<AnalyticsIdentity>.broadcast();

  void emitIdentity(AnalyticsIdentity identity) => _identity.add(identity);

  @override
  void track(String event, {Map<String, Object> properties = const {}}) =>
      events.add(Tracked(event, properties));

  @override
  void identify(String userId) => identities.add(userId);

  @override
  void reset() => identities.add(null);

  @override
  Stream<AnalyticsIdentity> watchIdentity() => _identity.stream;
}

/// An [AnalyticsDebug] whose streams the test drives, and whose actions it
/// scripts and counts.
class FakeAnalyticsDebug implements AnalyticsDebug {
  final _queue = StreamController<QueueStats>.broadcast();
  final _recent = StreamController<List<RecentEvent>>.broadcast();
  final _uploads = StreamController<List<UploadRun>>.broadcast();

  void emitQueue(QueueStats stats) => _queue.add(stats);

  void emitRecent(List<RecentEvent> events) => _recent.add(events);

  void emitUploads(List<UploadRun> runs) => _uploads.add(runs);

  /// What the next [flush] answers; [flushGate] holds it until completed.
  FlushOutcome flushOutcome = const FlushOutcome.nothingToSend();
  Completer<void>? flushGate;
  int flushes = 0;
  int retryFailedAnswer = 0;
  int retries = 0;

  @override
  Stream<QueueStats> watchQueue() => _queue.stream;

  @override
  Stream<List<RecentEvent>> watchRecentEvents() => _recent.stream;

  @override
  Stream<List<UploadRun>> watchUploads() => _uploads.stream;

  @override
  Future<FlushOutcome> flush() async {
    flushes++;
    await flushGate?.future;
    return flushOutcome;
  }

  @override
  Future<int> retryFailed() async {
    retries++;
    return retryFailedAnswer;
  }
}

/// A [DemoBackend] whose state the test drives, remembering the knobs set.
class FakeDemoBackend implements DemoBackend {
  final _state = StreamController<DemoServerState>.broadcast();
  final List<Object> set = [];

  void emit(DemoServerState state) => _state.add(state);

  @override
  Stream<DemoServerState> watch() => _state.stream;

  @override
  void setFailures(ServerFailures failures) => set.add(failures);

  @override
  void setSpeed(ServerSpeed speed) => set.add(speed);
}

/// A [DeviceNetwork] a test sets by hand, remembering the switch's calls.
class FakeDeviceNetwork implements DeviceNetwork {
  final _status = StreamController<NetworkStatus>.broadcast();
  final List<bool> switched = [];

  void emit(NetworkStatus status) => _status.add(status);

  @override
  Stream<NetworkStatus> watchStatus() => _status.stream;

  @override
  void simulateOffline(bool offline) => switched.add(offline);
}
