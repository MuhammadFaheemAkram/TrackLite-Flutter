import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

// The static facade: its lifecycle (initialize, shutdown) and what each call
// does when the SDK isn't running. It must never throw at the app, except
// for a bad configuration.
void main() {
  const config = TrackLiteConfig(apiKey: 'demo_key');

  setUpAll(TrackLiteTesting.useInMemoryDatabase);
  tearDownAll(TrackLiteTesting.useDeviceDatabase);
  tearDown(TrackLite.shutdown);

  TrackLiteDatabase database() =>
      (TrackLite.instance as TrackLiteClientImpl).database;

  Future<List<EventRow>> stored() async {
    await TrackLite.flush();
    return database().eventDao.all();
  }

  group('before initialize', () {
    test('flush says NotInitialized', () async {
      expect(await TrackLite.flush(), isA<NotInitialized>());
    });

    test('asking for the instance or the debug tools is a developer error', () {
      expect(() => TrackLite.instance, throwsStateError);
      expect(() => TrackLite.debug, throwsStateError);
    });

    test(
      'calls are kept and replayed in order, with their own times',
      () async {
        final first = DateTime.utc(2026, 11, 3, 9, 40);
        final second = DateTime.utc(2026, 11, 3, 9, 40, 5);

        final starting = TrackLite.initialize(config);
        withClock(Clock.fixed(first), () => TrackLite.track('app_opened'));
        TrackLite.setUserId('user_123');
        withClock(
          Clock.fixed(second),
          () => TrackLite.track('signed_in', properties: {'via': 'link'}),
        );
        await starting;

        final rows = await stored();
        expect(rows.map((row) => (row.name, row.timestamp, row.userId)), [
          ('app_opened', first, null),
          ('signed_in', second, 'user_123'),
        ]);
      },
    );

    test('past the limit, the oldest early events go, counted; identity '
        'calls stay', () async {
      final starting = TrackLite.initialize(config);
      TrackLite.setUserId('user_123');
      for (var i = 0; i < TrackLite.earlyCallLimit + 3; i++) {
        TrackLite.track('tap', properties: {'n': i});
      }
      await starting;

      final rows = await stored();
      expect(rows, hasLength(TrackLite.earlyCallLimit));
      expect(rows.first.properties, '{"n":3}');
      expect(rows.every((row) => row.userId == 'user_123'), isTrue);
      expect(await database().metaDao.read(MetaKeys.droppedTotal), '3');
    });

    test('shutdown does nothing', () async {
      await expectLater(TrackLite.shutdown(), completes);
    });
  });

  group('initialize', () {
    test('starts a client with the config', () async {
      await TrackLite.initialize(config);

      final client = TrackLite.instance;
      expect(client, isA<TrackLiteClientImpl>());
      expect((client as TrackLiteClientImpl).config, config);
      expect(await TrackLite.flush(), isA<NothingToSend>());
    });

    test('the debug tools are the running client\'s', () async {
      await TrackLite.initialize(config);
      TrackLite.track('tap');
      await TrackLite.flush();

      final stats = await TrackLite.debug.watchStats().first;
      expect(stats.pending, 1);
    });

    test('the facade forwards to the instance', () async {
      await TrackLite.initialize(config);
      final client = TrackLite.instance as TrackLiteClientImpl;

      TrackLite.setUserId('user_123');
      expect(client.userId, 'user_123');
      TrackLite.clearUser();
      expect(client.userId, isNull);
    });

    test('rejects a bad config, and the SDK stays stopped', () async {
      await expectLater(
        TrackLite.initialize(const TrackLiteConfig(apiKey: '')),
        throwsArgumentError,
      );

      expect(() => TrackLite.instance, throwsStateError);
      expect(await TrackLite.flush(), isA<NotInitialized>());
    });

    test('a second call while running is ignored', () async {
      await TrackLite.initialize(config);
      final first = TrackLite.instance;

      await TrackLite.initialize(
        const TrackLiteConfig(apiKey: 'other', debugMode: true),
      );

      expect(TrackLite.instance, same(first));
    });

    test('a second call is ignored without even checking its config', () async {
      await TrackLite.initialize(config);
      final first = TrackLite.instance;

      await expectLater(
        TrackLite.initialize(const TrackLiteConfig(apiKey: '')),
        completes,
      );

      expect(TrackLite.instance, same(first));
    });

    test('two calls at once share one start: the first config wins', () async {
      const second = TrackLiteConfig(apiKey: 'other', debugMode: true);

      await Future.wait([
        TrackLite.initialize(config),
        TrackLite.initialize(second),
      ]);

      expect((TrackLite.instance as TrackLiteClientImpl).config, config);
    });
  });

  group('shutdown', () {
    test('stops the client; calls are ignored again', () async {
      await TrackLite.initialize(config);
      final client = TrackLite.instance as TrackLiteClientImpl;

      await TrackLite.shutdown();

      expect(client.isClosed, isTrue);
      expect(() => TrackLite.instance, throwsStateError);
      expect(await TrackLite.flush(), isA<NotInitialized>());
      expect(() => TrackLite.track('late'), returnsNormally);
    });

    test(
      'calls between a shutdown and the next initialize are not kept',
      () async {
        await TrackLite.initialize(config);
        await TrackLite.shutdown();

        TrackLite.track('in_between');
        await TrackLite.initialize(config);

        expect(await stored(), isEmpty);
      },
    );

    test('during a start, waits for it, then stops what it started', () async {
      final starting = TrackLite.initialize(config);
      await TrackLite.shutdown();
      await starting;

      expect(() => TrackLite.instance, throwsStateError);
    });

    test('a new initialize after it starts a new client', () async {
      await TrackLite.initialize(config);
      final first = TrackLite.instance;
      await TrackLite.shutdown();

      await TrackLite.initialize(config);

      expect(TrackLite.instance, isNot(same(first)));
    });
  });
}
