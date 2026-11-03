import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/connectivity/network_monitor.dart';
import 'package:tracklite/src/network/analytics_transport.dart';
import 'package:tracklite/src/retry/retry_policy.dart';

/// How an app configures the SDK, once, at `TrackLite.initialize`.
///
/// Every value has a default except the API key. A value out of range is a
/// developer's mistake, so `initialize` rejects it with an [ArgumentError]
/// at once, in development, rather than misbehaving later on a user's phone.
@immutable
final class TrackLiteConfig {
  /// The configuration; see each field for its default and range.
  const TrackLiteConfig({
    required this.apiKey,
    this.batchSize = 20,
    this.flushInterval = const Duration(seconds: 30),
    this.maxRetries = 5,
    this.retry = const RetryPolicy(),
    this.maxQueueSize = 10000,
    this.backgroundUploads = true,
    this.debugMode = false,
    this.transport,
    this.networkMonitor,
  });

  /// The largest batch the server accepts in one request.
  static const int maxBatchSize = 100;

  /// The most server failures an event may be retried after.
  static const int maxRetriesLimit = 20;

  /// The shortest interval between automatic foreground uploads.
  static const Duration minFlushInterval = Duration(seconds: 1);

  /// Identifies the app to the analytics server. Must not be blank.
  final String apiKey;

  /// How many events one upload request carries: 1 to [maxBatchSize].
  final int batchSize;

  /// How often the SDK uploads while the app is in the foreground: at least
  /// [minFlushInterval].
  final Duration flushInterval;

  /// How many server failures an event survives before it is marked failed:
  /// 0 to [maxRetriesLimit]. (Failing to reach the server doesn't count.)
  final int maxRetries;

  /// How long an event waits after a server error before it is tried
  /// again: 1 minute, doubling, at most an hour by default.
  final RetryPolicy retry;

  /// The most unsent events kept; beyond it, the oldest are dropped (and
  /// counted). At least [batchSize].
  final int maxQueueSize;

  /// Whether the SDK schedules periodic uploads while the app is in the
  /// background. Turn it off if the app runs its own background dispatcher.
  final bool backgroundUploads;

  /// Whether the SDK logs what it does. Off, it is silent.
  final bool debugMode;

  /// Where batches go. `null` (the default) is a `FakeAnalyticsServer`
  /// with its demo settings: this project has no real backend.
  final AnalyticsTransport? transport;

  /// Whether the device is online. `null` (the default) is a
  /// `ConnectivityNetworkMonitor`; an app can pass its own (a demo switch).
  final NetworkMonitor? networkMonitor;

  /// Every rule this configuration breaks, in words; empty when valid.
  List<String> get problems => [
    if (apiKey.trim().isEmpty) 'apiKey must not be blank',
    if (batchSize < 1 || batchSize > maxBatchSize)
      'batchSize must be 1–$maxBatchSize (was $batchSize)',
    if (flushInterval < minFlushInterval)
      'flushInterval must be at least 1 second (was $flushInterval)',
    if (maxRetries < 0 || maxRetries > maxRetriesLimit)
      'maxRetries must be 0–$maxRetriesLimit (was $maxRetries)',
    ...retry.problems,
    if (maxQueueSize < batchSize)
      'maxQueueSize must be at least batchSize ($batchSize) '
          '(was $maxQueueSize)',
  ];

  /// Throws an [ArgumentError] naming every broken rule.
  void validate() {
    final problems = this.problems;
    if (problems.isNotEmpty) {
      throw ArgumentError('Invalid TrackLiteConfig: ${problems.join('; ')}.');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is TrackLiteConfig &&
      other.apiKey == apiKey &&
      other.batchSize == batchSize &&
      other.flushInterval == flushInterval &&
      other.maxRetries == maxRetries &&
      other.retry == retry &&
      other.maxQueueSize == maxQueueSize &&
      other.backgroundUploads == backgroundUploads &&
      other.debugMode == debugMode &&
      identical(other.transport, transport) &&
      identical(other.networkMonitor, networkMonitor);

  @override
  int get hashCode => Object.hash(
    apiKey,
    batchSize,
    flushInterval,
    maxRetries,
    retry,
    maxQueueSize,
    backgroundUploads,
    debugMode,
    identityHashCode(transport),
    identityHashCode(networkMonitor),
  );

  // The key is masked: a config printed in a log or a crash report must not
  // leak it.
  @override
  String toString() =>
      'TrackLiteConfig(apiKey: ${_masked(apiKey)}, batchSize: $batchSize, '
      'flushInterval: $flushInterval, maxRetries: $maxRetries, '
      'retry: $retry, '
      'maxQueueSize: $maxQueueSize, backgroundUploads: $backgroundUploads, '
      'debugMode: $debugMode, '
      'transport: ${transport?.runtimeType ?? 'FakeAnalyticsServer (default)'}, '
      'networkMonitor: '
      '${networkMonitor?.runtimeType ?? 'ConnectivityNetworkMonitor (default)'})';

  /// This config with the objects that can't be saved (the background task
  /// rebuilds the rest from JSON).
  @internal
  TrackLiteConfig withObjects({
    AnalyticsTransport? transport,
    NetworkMonitor? networkMonitor,
  }) => TrackLiteConfig(
    apiKey: apiKey,
    batchSize: batchSize,
    flushInterval: flushInterval,
    maxRetries: maxRetries,
    retry: retry,
    maxQueueSize: maxQueueSize,
    backgroundUploads: backgroundUploads,
    debugMode: debugMode,
    transport: transport ?? this.transport,
    networkMonitor: networkMonitor ?? this.networkMonitor,
  );

  static String _masked(String key) =>
      key.length <= 4 ? '****' : '${key.substring(0, 4)}****';
}
