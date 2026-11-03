import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/data/analytics/fake_server_demo.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';

void main() {
  test("starts from the server's own settings (the closest choices)", () async {
    final demo = FakeServerDemo(FakeAnalyticsServer());

    expect(
      await demo.watch().first,
      const DemoServerState(
        failures: ServerFailures.some,
        speed: ServerSpeed.normal,
      ),
    );
  });

  test('the knobs change the server, and are shown', () async {
    final server = FakeAnalyticsServer();
    final demo = FakeServerDemo(server);
    final seen = <DemoServerState>[];
    final subscription = demo.watch().listen(seen.add);
    await pumpEventQueue();

    demo
      ..setFailures(ServerFailures.all)
      ..setSpeed(ServerSpeed.fast);
    await pumpEventQueue();
    await subscription.cancel();

    expect(server.failureRate, 1);
    expect(server.latency, const Duration(milliseconds: 100));
    expect(seen.last.failures, ServerFailures.all);
    expect(seen.last.speed, ServerSpeed.fast);
  });

  test('what the server receives is shown as it happens', () async {
    final server = FakeAnalyticsServer(latency: Duration.zero, failureRate: 0);
    final demo = FakeServerDemo(server);
    final seen = <int>[];
    final subscription = demo.watch().map((s) => s.accepted).listen(seen.add);
    await pumpEventQueue();

    await server.upload(
      UploadBatch(
        apiKey: 'k',
        sentAt: DateTime.utc(2026),
        libraryVersion: TrackLite.version,
        events: [
          TrackLiteEvent(
            id: 'e1',
            name: 'tap',
            timestamp: DateTime.utc(2026),
            anonymousId: 'a',
            properties: const {},
            status: EventStatus.sending,
          ),
        ],
      ),
    );
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen, [0, 1]);
  });
}
