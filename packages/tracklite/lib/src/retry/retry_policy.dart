import 'package:flutter/foundation.dart';

/// How long an event waits before it is tried again after a server error:
/// exponential backoff.
///
/// With the defaults: 1, 2, 4, 8, 16, 32 minutes, then an hour each time.
/// Each failure doubles the wait, so a struggling server gets fewer and
/// fewer requests from every phone at once, instead of a flood that keeps
/// it down.
@immutable
final class RetryPolicy {
  /// A policy; [base] must be positive and [maxDelay] at least [base].
  const RetryPolicy({
    this.base = const Duration(minutes: 1),
    this.maxDelay = const Duration(hours: 1),
  });

  /// The wait after the first failure.
  final Duration base;

  /// The longest wait, however many failures.
  final Duration maxDelay;

  /// The wait after the [attempt]-th failure (1-based): `base × 2^(attempt−1)`,
  /// capped at [maxDelay]. Pure and total for any attempt ≥ 1; it never
  /// overflows, even at attempt 64.
  Duration delayAfter(int attempt) {
    if (attempt < 1) {
      throw ArgumentError.value(attempt, 'attempt', 'must be at least 1');
    }
    // Doubling 62 times overflows a 64-bit int; by then the cap has long
    // been reached, so stop doubling once the delay passes it.
    var delay = base;
    for (var i = 1; i < attempt && delay < maxDelay; i++) {
      delay *= 2;
    }
    return delay < maxDelay ? delay : maxDelay;
  }

  /// Every rule this policy breaks, in words; empty when valid.
  List<String> get problems => [
    if (base <= Duration.zero) 'retry.base must be positive (was $base)',
    if (maxDelay < base)
      'retry.maxDelay must be at least retry.base (was $maxDelay)',
  ];

  @override
  bool operator ==(Object other) =>
      other is RetryPolicy && other.base == base && other.maxDelay == maxDelay;

  @override
  int get hashCode => Object.hash(base, maxDelay);

  @override
  String toString() => 'RetryPolicy(base: $base, maxDelay: $maxDelay)';
}
