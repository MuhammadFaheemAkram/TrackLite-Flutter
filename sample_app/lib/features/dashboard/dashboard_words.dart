import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';

/// A flush's outcome in words, for the SnackBar.
String flushWords(FlushOutcome outcome) => switch (outcome) {
  FlushSent(:final events, :final requests) =>
    'Sent ${count(events, 'event')} in ${count(requests, 'request')}.',
  FlushNothingToSend() => 'Nothing to send: the queue is empty.',
  FlushOffline() => "You're offline. Events wait until you're back.",
  FlushFailed(:final reason, :final waiting) =>
    'Sending failed ($reason). ${count(waiting, 'event')} still waiting.',
  FlushKeyRejected() => 'The server rejected the API key.',
  FlushNotRunning() => "Analytics isn't running.",
};

/// What the Dashboard says once, in words.
String effectWords(DashboardEffect effect) => switch (effect) {
  Flushed(:final outcome) => flushWords(outcome),
  Retried(count: 0) => 'No failed events to retry.',
  Retried(count: final n) => '${count(n, 'failed event')} back in the queue.',
  TrackedBurst(count: final n) =>
    'Tracked ${count(n, 'event')}: the SDK uploads them in batches.',
};

/// An upload run's outcome in a word or two.
String outcomeWords(UploadOutcome outcome) => switch (outcome) {
  UploadOutcome.uploaded => 'Uploaded',
  UploadOutcome.nothing => 'Nothing to send',
  UploadOutcome.offline => 'Offline',
  UploadOutcome.failed => 'Failed',
  UploadOutcome.keyRejected => 'Key rejected',
};

/// An upload trigger as people say it.
String triggerWords(String trigger) => switch (trigger) {
  'manual' => 'Flush',
  'interval' => 'Every 30 s',
  'threshold' => 'Full batch',
  'paused' => 'App in background',
  'reconnect' => 'Reconnected',
  'retryDue' => 'Retry due',
  'background' => 'Background task',
  _ => trigger,
};

/// `1 event`, `3 events`.
String count(int n, String noun) => '$n ${n == 1 ? noun : '${noun}s'}';
