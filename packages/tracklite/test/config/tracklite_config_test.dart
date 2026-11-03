import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';

void main() {
  const valid = TrackLiteConfig(apiKey: 'demo_key');

  test('the defaults are the documented ones, and valid', () {
    expect(valid.batchSize, 20);
    expect(valid.flushInterval, const Duration(seconds: 30));
    expect(valid.maxRetries, 5);
    expect(valid.maxQueueSize, 10000);
    expect(valid.backgroundUploads, isTrue);
    expect(valid.debugMode, isFalse);
    expect(valid.problems, isEmpty);
    expect(valid.validate, returnsNormally);
  });

  group('each rule, just inside and just outside', () {
    for (final (rule, inside, outside) in [
      (
        'apiKey',
        const TrackLiteConfig(apiKey: 'k'),
        const TrackLiteConfig(apiKey: '  '),
      ),
      (
        'batchSize (low)',
        const TrackLiteConfig(apiKey: 'k', batchSize: 1),
        const TrackLiteConfig(apiKey: 'k', batchSize: 0),
      ),
      (
        'batchSize (high)',
        const TrackLiteConfig(apiKey: 'k', batchSize: 100),
        const TrackLiteConfig(apiKey: 'k', batchSize: 101),
      ),
      (
        'flushInterval',
        const TrackLiteConfig(apiKey: 'k', flushInterval: Duration(seconds: 1)),
        const TrackLiteConfig(
          apiKey: 'k',
          flushInterval: Duration(milliseconds: 999),
        ),
      ),
      (
        'maxRetries (low)',
        const TrackLiteConfig(apiKey: 'k', maxRetries: 0),
        const TrackLiteConfig(apiKey: 'k', maxRetries: -1),
      ),
      (
        'maxRetries (high)',
        const TrackLiteConfig(apiKey: 'k', maxRetries: 20),
        const TrackLiteConfig(apiKey: 'k', maxRetries: 21),
      ),
      (
        'maxQueueSize',
        const TrackLiteConfig(apiKey: 'k', batchSize: 50, maxQueueSize: 50),
        const TrackLiteConfig(apiKey: 'k', batchSize: 50, maxQueueSize: 49),
      ),
    ]) {
      test(rule, () {
        expect(inside.problems, isEmpty);
        expect(outside.problems, hasLength(1));
        expect(
          outside.validate,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains(outside.problems.single),
            ),
          ),
        );
      });
    }
  });

  test('validate names every broken rule at once', () {
    const config = TrackLiteConfig(apiKey: '', batchSize: 0, maxRetries: 99);

    expect(config.problems, [
      'apiKey must not be blank',
      'batchSize must be 1–100 (was 0)',
      'maxRetries must be 0–20 (was 99)',
    ]);
  });

  test('two configs with the same values are equal', () {
    const other = TrackLiteConfig(apiKey: 'demo_key');

    expect(other, valid);
    expect(other.hashCode, valid.hashCode);
    expect(
      const TrackLiteConfig(apiKey: 'demo_key', debugMode: true),
      isNot(valid),
    );
  });

  test('toString masks the API key', () {
    expect(valid.toString(), contains('apiKey: demo****'));
    expect(valid.toString(), isNot(contains('demo_key')));
    expect(
      const TrackLiteConfig(apiKey: 'abc').toString(),
      contains('apiKey: ****,'),
    );
  });

  test('the transport: none means the default server; equal only if the '
      'same object', () {
    final server = FakeAnalyticsServer();
    final a = TrackLiteConfig(apiKey: 'k', transport: server);

    expect(valid.transport, isNull);
    expect(
      valid.toString(),
      contains('transport: FakeAnalyticsServer (default)'),
    );
    expect(a, TrackLiteConfig(apiKey: 'k', transport: server));
    expect(
      a,
      isNot(TrackLiteConfig(apiKey: 'k', transport: FakeAnalyticsServer())),
    );
    expect(a.toString(), contains('transport: FakeAnalyticsServer,'));
  });
}
