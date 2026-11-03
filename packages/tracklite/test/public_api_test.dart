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
    const config = TrackLiteConfig(apiKey: 'demo_key');
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
    expect(TrackLite.version, matches(RegExp(r'^\d+\.\d+\.\d+$')));

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
  'FlushResult',
  'Uploaded',
  'NothingToSend',
  'Offline',
  'Failed',
  'Unauthorized',
  'NotInitialized',
];

const _testing = ['TrackLiteTesting'];

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
