import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';

// The version lives in three places: the pubspec (what pub publishes), the
// code (what every upload reports) and the changelog (what changed). They
// must agree, or a server's "which SDK sent this?" gets a wrong answer.
void main() {
  test('TrackLite.version is the pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);

    expect(TrackLite.version, version);
  });

  test('the changelog starts with this version', () {
    final changelog = File('CHANGELOG.md').readAsStringSync();
    final first = RegExp(
      r'^## (\S+)',
      multiLine: true,
    ).firstMatch(changelog)!.group(1);

    expect(first, TrackLite.version);
  });
}
