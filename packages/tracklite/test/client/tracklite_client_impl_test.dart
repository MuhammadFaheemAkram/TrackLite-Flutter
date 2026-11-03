import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:tracklite/tracklite.dart';

void main() {
  late List<(LogLevel, String)> logs;

  TrackLiteClientImpl clientWith({required bool debugMode}) =>
      TrackLiteClientImpl(
        config: TrackLiteConfig(apiKey: 'demo_key', debugMode: debugMode),
        logger: TrackLiteLogger(
          enabled: debugMode,
          sink: (level, message, {error, stackTrace}) =>
              logs.add((level, message)),
        ),
      );

  setUp(() => logs = []);

  test('create validates the config first', () {
    expect(
      () => TrackLiteClient.create(const TrackLiteConfig(apiKey: ' ')),
      throwsArgumentError,
    );
  });

  test('create builds a client whose logger follows debugMode', () async {
    final client = await TrackLiteClient.create(
      const TrackLiteConfig(apiKey: 'demo_key', debugMode: true),
    ) as TrackLiteClientImpl;

    expect(client.logger.enabled, isTrue);
  });

  group('in debug mode', () {
    test('each call is logged, with the user it applies to', () {
      final client = clientWith(debugMode: true);

      client
        ..track('screen_opened', properties: {'screen': 'Home'})
        ..setUserId('user_123')
        ..track('purchase')
        ..clearUser();

      expect(logs, [
        (LogLevel.debug, 'track("screen_opened", {screen: Home}) for anon'),
        (LogLevel.debug, 'setUserId("user_123")'),
        (LogLevel.debug, 'track("purchase", {}) for user_123'),
        (LogLevel.debug, 'clearUser()'),
      ]);
    });

    test('calls after shutdown are ignored, with a warning each', () async {
      final client = clientWith(debugMode: true);
      await client.shutdown();
      logs.clear();

      client
        ..track('late')
        ..setUserId('u')
        ..clearUser();

      expect(logs, [
        (LogLevel.warning, 'track("late") after shutdown(): ignored'),
        (LogLevel.warning, 'setUserId after shutdown(): ignored'),
        (LogLevel.warning, 'clearUser after shutdown(): ignored'),
      ]);
      expect(client.userId, isNull);
    });
  });

  test('without debug mode, nothing is logged', () async {
    final client = clientWith(debugMode: false)
      ..track('a')
      ..setUserId('u');
    await client.shutdown();
    client.track('late');

    expect(logs, isEmpty);
  });

  test('flush: NothingToSend while running, NotInitialized after', () async {
    final client = clientWith(debugMode: false);
    expect(await client.flush(), isA<NothingToSend>());

    await client.shutdown();
    await client.shutdown();

    expect(await client.flush(), isA<NotInitialized>());
  });

  test('an error inside a call is logged, never thrown at the app', () {
    final client = TrackLiteClientImpl(
      config: const TrackLiteConfig(apiKey: 'demo_key', debugMode: true),
      logger: TrackLiteLogger(
        enabled: true,
        sink: (level, message, {error, stackTrace}) {
          // The debug line fails (a broken sink); the error line must still
          // arrive and nothing escape.
          if (level == LogLevel.debug) throw StateError('sink broke');
          logs.add((level, '$message: $error'));
        },
      ),
    );

    expect(() => client.track('boom'), returnsNormally);
    expect(logs, [(LogLevel.error, 'track failed: Bad state: sink broke')]);
  });
}
