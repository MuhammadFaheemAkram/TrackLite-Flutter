import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/tracklite.dart';

// The static facade: its lifecycle (initialize, shutdown) and what each call
// does when the SDK isn't running. It must never throw at the app, except
// for a bad configuration.
void main() {
  const config = TrackLiteConfig(apiKey: 'demo_key');

  tearDown(TrackLite.shutdown);

  group('before initialize', () {
    test('calls are ignored and flush says NotInitialized', () async {
      TrackLite.track('early');
      TrackLite.setUserId('u1');
      TrackLite.clearUser();

      expect(await TrackLite.flush(), isA<NotInitialized>());
    });

    test('asking for the instance is a developer error', () {
      expect(() => TrackLite.instance, throwsStateError);
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
