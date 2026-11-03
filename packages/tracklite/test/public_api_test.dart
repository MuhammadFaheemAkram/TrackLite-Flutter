import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// The only imports an app has (the second in its tests). Nothing from
// lib/src/ here: this file sees the SDK exactly as a host does.
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

// The public API is a promise: a name in it can't change or go without a
// new major version. This file makes the promise visible. It uses every
// exported name (so removing or renaming one fails to compile), switches
// over FlushResult with no default (so adding a case fails to compile too),
// and lists the exports (so adding a name is a reviewed change to this
// test).
void main() {
  // The facade starts the real app lifecycle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final (path, names) in [
    ('lib/tracklite.dart', _exported),
    ('lib/testing.dart', _testing),
  ]) {
    test('$path exports exactly these names', () {
      final library = File(path).readAsStringSync();
      final shown = RegExp(r'show\s+([^;]+);')
          .allMatches(library)
          .expand((match) => match.group(1)!.split(','))
          .map((name) => name.trim())
          .toList();

      expect(shown, unorderedEquals(names));
      expect(shown, hasLength(names.length), reason: 'no name twice');
      expect(
        RegExp(r'^export ', multiLine: true).allMatches(library).length,
        RegExp(r'show\s').allMatches(library).length,
        reason: 'every export has a show list: nothing leaks by accident',
      );
    });
  }

  test('lib/ has only these two libraries', () {
    final libraries = Directory('lib')
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last);

    expect(libraries, unorderedEquals(['tracklite.dart', 'testing.dart']));
  });

  test('every name is usable from a host', () async {
    TrackLiteTesting.useInMemoryDatabase();
    addTearDown(TrackLiteTesting.useDeviceDatabase);
    final server = FakeAnalyticsServer(latency: Duration.zero, failureRate: 0);
    final NetworkMonitor monitor = FakeNetworkMonitor();
    final config = TrackLiteConfig(
      apiKey: 'demo_key',
      transport: server,
      networkMonitor: monitor,
      retry: const RetryPolicy(base: Duration(seconds: 30)),
      backgroundUploads: false,
    );
    expect(ConnectivityNetworkMonitor(), isA<NetworkMonitor>());
    await TrackLite.initialize(config);
    addTearDown(TrackLite.shutdown);

    final TrackLiteClient client = TrackLite.instance;
    TrackLite.setUserId('user_123');
    TrackLite.track('purchase', properties: {'price': 20});
    TrackLite.clearUser();
    client.track('screen_opened');

    final result = await TrackLite.flush();
    expect(describe(result), isNotEmpty);
    final TrackLiteDebug debug = TrackLite.debug;
    final TrackLiteStats stats = await debug.watchStats().first;
    expect(stats.tracked, 2);
    expect(TrackLite.earlyCallLimit, 100);
    final FlushResult background = await TrackLite.runBackgroundUpload();
    expect(describe(background), isNotEmpty);
    expect(TrackLite.version, matches(RegExp(r'^\d+\.\d+\.\d+$')));

    expect(server.stats, isA<FakeServerStats>());
    expect(server.stats.accepted, 2);

    // A host can write its own transport and throw the SDK's errors.
    final AnalyticsTransport custom = _HostTransport();
    final batch = UploadBatch(
      apiKey: 'k',
      sentAt: DateTime.utc(2026),
      libraryVersion: TrackLite.version,
      events: const [],
    );
    final UploadResponse response = await custom.upload(batch);
    expect(response.accepted, 0);
    for (final error in const <TransportException>[
      ServerUnreachable(),
      ServerFailure(500),
      ApiKeyRejected(),
      RequestRejected(400, 'bad'),
    ]) {
      expect(meaningOf(error), isNotEmpty);
    }

    final event = TrackLiteEvent(
      id: 'e1',
      name: 'purchase',
      timestamp: DateTime.utc(2026),
      anonymousId: 'a1',
      properties: const {},
      status: EventStatus.values.first,
    );
    expect(event.status, EventStatus.pending);
  });

  test('every FlushResult has a meaning', () {
    for (final result in const <FlushResult>[
      Uploaded(events: 40, batches: 2),
      NothingToSend(),
      Offline(),
      Failed(reason: 'Server error 500', remaining: 12),
      Unauthorized(),
      NotInitialized(),
    ]) {
      expect(describe(result), isNotEmpty);
    }
  });
}

const _exported = [
  'TrackLite',
  'TrackLiteClient',
  'TrackLiteConfig',
  'TrackLiteDebug',
  'TrackLiteStats',
  'TrackLiteEvent',
  'EventStatus',
  'AnalyticsTransport',
  'UploadBatch',
  'UploadResponse',
  'TransportException',
  'ServerUnreachable',
  'ServerFailure',
  'ApiKeyRejected',
  'RequestRejected',
  'FakeAnalyticsServer',
  'FakeServerStats',
  'RetryPolicy',
  'NetworkMonitor',
  'ConnectivityNetworkMonitor',
  'FlushResult',
  'Uploaded',
  'NothingToSend',
  'Offline',
  'Failed',
  'Unauthorized',
  'NotInitialized',
];

const _testing = ['TrackLiteTesting', 'FakeNetworkMonitor'];

/// What a host might show for each result. Exhaustive with no default: a
/// new case is a compile error here, as it would be in every such app.
String describe(FlushResult result) => switch (result) {
  Uploaded(:final events, :final batches) => 'Sent $events in $batches',
  NothingToSend() => 'Nothing to send',
  Offline() => 'Offline',
  Failed(:final reason, :final remaining) => '$reason; $remaining waiting',
  Unauthorized() => 'Check the API key',
  NotInitialized() => 'Not running',
};

class _HostTransport implements AnalyticsTransport {
  @override
  Future<UploadResponse> upload(UploadBatch batch) async =>
      UploadResponse(accepted: batch.events.length);
}

/// Sealed: a host's switch over the errors is exhaustive too.
String meaningOf(TransportException error) => switch (error) {
  ServerUnreachable() => 'not reached',
  ServerFailure(:final statusCode) => 'server error $statusCode',
  ApiKeyRejected() => 'bad key',
  RequestRejected(:final statusCode) => 'refused ($statusCode)',
};
