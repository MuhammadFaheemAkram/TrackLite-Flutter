import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_words.dart';

void main() {
  test('every flush outcome in words, with singulars and plurals', () {
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

  test('every effect in words', () {
    expect(
      effectWords(const DashboardEffect.flushed(FlushOutcome.offline())),
      "You're offline. Events wait until you're back.",
    );
    expect(
      effectWords(const DashboardEffect.retried(0)),
      'No failed events to retry.',
    );
    expect(
      effectWords(const DashboardEffect.retried(1)),
      '1 failed event back in the queue.',
    );
    expect(
      effectWords(const DashboardEffect.tracked(100)),
      'Tracked 100 events: the SDK uploads them in batches.',
    );
  });

  test('every trigger and outcome has words', () {
    for (final trigger in [
      'manual',
      'interval',
      'threshold',
      'paused',
      'reconnect',
      'retryDue',
      'background',
    ]) {
      expect(triggerWords(trigger), isNot(trigger));
    }
    expect(triggerWords('something_new'), 'something_new');
    expect(
      UploadOutcome.values.map(outcomeWords).toSet(),
      hasLength(UploadOutcome.values.length),
    );
  });
}
