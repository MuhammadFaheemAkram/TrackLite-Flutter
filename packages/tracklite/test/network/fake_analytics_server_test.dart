import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/sdk.dart';

void main() {
  TrackLiteEvent event(String id) => TrackLiteEvent(
    id: id,
    name: 'tap',
    timestamp: testNow,
    anonymousId: 'anon',
    properties: const {'n': 1},
    status: EventStatus.sending,
  );

  UploadBatch batch(List<String> ids, {String apiKey = 'demo_key'}) =>
      UploadBatch(
        apiKey: apiKey,
        sentAt: testNow,
        libraryVersion: TrackLite.version,
        events: [for (final id in ids) event(id)],
      );

  test('the defaults are a realistic demo: 800 ms, 10 % failures', () {
    final server = FakeAnalyticsServer();

    expect(server.latency, const Duration(milliseconds: 800));
    expect(server.failureRate, 0.1);
    expect(server.reachable, isTrue);
  });

  test('stores each event once; a second copy is a duplicate', () async {
    final server = instantServer();

    expect(
      await server.upload(batch(['a', 'b'])),
      const UploadResponse(accepted: 2),
    );
    expect(
      await server.upload(batch(['b', 'c'])),
      const UploadResponse(accepted: 1, duplicates: 1),
    );

    expect(server.hasEvent('c'), isTrue);
    expect(
      server.stats,
      const FakeServerStats(requests: 2, accepted: 3, duplicates: 1),
    );
  });

  test('answers after its latency, not before', () {
    fakeAsync((async) {
      final server = FakeAnalyticsServer(failureRate: 0);
      UploadResponse? response;
      server.upload(batch(['a'])).then((r) => response = r);

      async.elapse(const Duration(milliseconds: 799));
      expect(response, isNull);
      async.elapse(const Duration(milliseconds: 1));
      expect(response, const UploadResponse(accepted: 1));
    });
  });

  test('unreachable: the request never arrives', () async {
    final server = instantServer()..reachable = false;

    await expectLater(
      server.upload(batch(['a'])),
      throwsA(isA<ServerUnreachable>()),
    );
    expect(server.stats, const FakeServerStats());
  });

  test('a blank or "invalid…" key is rejected (401)', () async {
    final server = instantServer();

    for (final key in ['  ', 'invalid_key']) {
      await expectLater(
        server.upload(batch(['a'], apiKey: key)),
        throwsA(isA<ApiKeyRejected>()),
      );
    }
    expect(server.stats.failures, 2);
    expect(server.hasEvent('a'), isFalse);
  });

  test('more than 100 events in one batch is a 400', () async {
    final server = instantServer();

    await expectLater(
      server.upload(batch([for (var i = 0; i < 101; i++) 'e$i'])),
      throwsA(
        isA<RequestRejected>()
            .having((e) => e.statusCode, 'status', 400)
            .having((e) => e.message, 'message', '101 events in one batch'),
      ),
    );
    expect(
      await server.upload(batch([for (var i = 0; i < 100; i++) 'e$i'])),
      const UploadResponse(accepted: 100),
    );
  });

  test('failureRate 1 always fails with a 500, and stores nothing', () async {
    final server = FakeAnalyticsServer(latency: Duration.zero, failureRate: 1);

    await expectLater(
      server.upload(batch(['a'])),
      throwsA(isA<ServerFailure>().having((e) => e.statusCode, 'status', 500)),
    );
    expect(server.hasEvent('a'), isFalse);
    expect(server.stats, const FakeServerStats(requests: 1, failures: 1));
  });

  test('a seeded random fails about the share it is told to', () async {
    final server = FakeAnalyticsServer(
      latency: Duration.zero,
      failureRate: 0.3,
      random: Random(7),
    );
    var failures = 0;
    for (var i = 0; i < 1000; i++) {
      try {
        await server.upload(batch(['e$i']));
      } on ServerFailure {
        failures++;
      }
    }

    expect(failures, inInclusiveRange(250, 350));
  });

  test('the batch body is what a real server would read', () {
    expect(batch(['a']).toJson(), {
      'sent_at': '2026-11-03T09:41:00.000Z',
      'library': {'name': 'tracklite', 'version': TrackLite.version},
      'events': [
        {
          'id': 'a',
          'name': 'tap',
          'timestamp': '2026-11-03T09:41:00.000Z',
          'user_id': null,
          'anonymous_id': 'anon',
          'properties': {'n': 1},
        },
      ],
    });
  });

  test('a transport error says what it is', () {
    expect(
      const ServerFailure(503).toString(),
      'ServerFailure: server error 503',
    );
    expect(
      const ServerUnreachable().message,
      'the server could not be reached',
    );
  });

  test('watchStats: now, then after every request it receives', () async {
    final server = instantServer();
    final seen = <int>[];
    final subscription = server
        .watchStats()
        .map((s) => s.requests)
        .listen(seen.add);
    await pumpEventQueue();

    await server.upload(batch(['a']));
    server.failureRate = 1;
    try {
      await server.upload(batch(['b']));
    } on ServerFailure {
      // expected
    }
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen, [0, 1, 2]);
  });
}
