import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';

/// A flush's outcome in words, for the SnackBar.
String flushWords(FlushOutcome outcome) => switch (outcome) {
  FlushSent(:final events, :final requests) =>
    'Sent ${_count(events, 'event')} in ${_count(requests, 'request')}.',
  FlushNothingToSend() => 'Nothing to send: the queue is empty.',
  FlushOffline() => "You're offline. Events wait until you're back.",
  FlushFailed(:final reason, :final waiting) =>
    'Sending failed ($reason). ${_count(waiting, 'event')} still waiting.',
  FlushKeyRejected() => 'The server rejected the API key.',
  FlushNotRunning() => "Analytics isn't running.",
};

String _count(int n, String noun) => '$n ${n == 1 ? noun : '${noun}s'}';
