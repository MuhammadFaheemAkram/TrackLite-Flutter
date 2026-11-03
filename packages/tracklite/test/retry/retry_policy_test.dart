import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';

void main() {
  const policy = RetryPolicy();

  test('the defaults: 1 minute, doubling, at most an hour', () {
    expect(policy.base, const Duration(minutes: 1));
    expect(policy.maxDelay, const Duration(hours: 1));
    expect(policy.problems, isEmpty);
  });

  test('1, 2, 4, 8, 16, 32 minutes, then the cap', () {
    expect(
      [for (var a = 1; a <= 8; a++) policy.delayAfter(a).inMinutes],
      [1, 2, 4, 8, 16, 32, 60, 60],
    );
  });

  test('the cap is exact when a doubling would pass it', () {
    const p = RetryPolicy(
      base: Duration(seconds: 10),
      maxDelay: Duration(seconds: 25),
    );

    expect(p.delayAfter(2), const Duration(seconds: 20));
    expect(p.delayAfter(3), const Duration(seconds: 25));
  });

  test('no overflow, however many attempts', () {
    expect(policy.delayAfter(64), const Duration(hours: 1));
    expect(policy.delayAfter(1 << 20), const Duration(hours: 1));
  });

  test('an attempt below 1 is a programming error', () {
    expect(() => policy.delayAfter(0), throwsArgumentError);
    expect(() => policy.delayAfter(-3), throwsArgumentError);
  });

  test('its rules, and the config reports them', () {
    const bad = RetryPolicy(
      base: Duration.zero,
      maxDelay: Duration(seconds: -1),
    );

    expect(bad.problems, hasLength(2));
    expect(
      const TrackLiteConfig(apiKey: 'k', retry: bad).problems,
      containsAll(bad.problems),
    );
  });

  test('equal by value', () {
    expect(const RetryPolicy(), policy);
    expect(policy.hashCode, const RetryPolicy().hashCode);
    expect(const RetryPolicy(base: Duration(seconds: 1)), isNot(policy));
    expect(policy.toString(), contains('maxDelay: 1:00:00'));
  });
}
