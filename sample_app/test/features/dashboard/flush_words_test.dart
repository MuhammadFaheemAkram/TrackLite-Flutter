import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/features/dashboard/flush_words.dart';

void main() {
  test('every outcome in words, with singulars and plurals', () {
    expect(
      flushWords(const FlushOutcome.sent(events: 1, requests: 1)),
      'Sent 1 event in 1 request.',
    );
    expect(
      flushWords(const FlushOutcome.sent(events: 100, requests: 5)),
      'Sent 100 events in 5 requests.',
    );
    expect(
      flushWords(const FlushOutcome.nothingToSend()),
      'Nothing to send: the queue is empty.',
    );
    expect(
      flushWords(const FlushOutcome.offline()),
      "You're offline. Events wait until you're back.",
    );
    expect(
      flushWords(
        const FlushOutcome.failed(reason: 'server error 500', waiting: 12),
      ),
      'Sending failed (server error 500). 12 events still waiting.',
    );
    expect(
      flushWords(const FlushOutcome.keyRejected()),
      'The server rejected the API key.',
    );
    expect(
      flushWords(const FlushOutcome.notRunning()),
      "Analytics isn't running.",
    );
  });
}
