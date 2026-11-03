import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tracklite/src/config/tracklite_config.dart';
import 'package:tracklite/src/retry/retry_policy.dart';

/// The config as the background task needs it, saved by `initialize` in
/// `meta`.
///
/// A background isolate starts with nothing: not the app's objects, not
/// the config it passed. So the foreground saves what an upload needs (as
/// JSON); the background reads it back. The transport and the monitor
/// can't be saved (they are objects): the background uses the defaults.
@internal
String encodeConfig(TrackLiteConfig config) => jsonEncode({
  'api_key': config.apiKey,
  'batch_size': config.batchSize,
  'max_retries': config.maxRetries,
  'max_queue_size': config.maxQueueSize,
  'retry_base_ms': config.retry.base.inMilliseconds,
  'retry_max_ms': config.retry.maxDelay.inMilliseconds,
  'debug_mode': config.debugMode,
});

/// The saved config, with background uploads off (the background task
/// doesn't schedule itself).
@internal
TrackLiteConfig decodeConfig(String json) {
  final map = jsonDecode(json) as Map<String, dynamic>;
  return TrackLiteConfig(
    apiKey: map['api_key'] as String,
    batchSize: map['batch_size'] as int,
    maxRetries: map['max_retries'] as int,
    maxQueueSize: map['max_queue_size'] as int,
    retry: RetryPolicy(
      base: Duration(milliseconds: map['retry_base_ms'] as int),
      maxDelay: Duration(milliseconds: map['retry_max_ms'] as int),
    ),
    backgroundUploads: false,
    debugMode: map['debug_mode'] as bool,
  );
}
