import 'package:flutter/foundation.dart';

/// A snapshot of the SDK's queue and identity, for debug tools.
@immutable
final class TrackLiteStats {
  /// A snapshot. Every count defaults to 0, so a fake in a host's tests
  /// names only what it needs (and new counts don't break it).
  const TrackLiteStats({
    required this.anonymousId,
    this.tracked = 0,
    this.pending = 0,
    this.sending = 0,
    this.sent = 0,
    this.failed = 0,
    this.dropped = 0,
    this.rejected = 0,
    this.userId,
  });

  /// Every event stored since the SDK was installed.
  final int tracked;

  /// Events waiting for an upload.
  final int pending;

  /// Events in an upload that is in flight.
  final int sending;

  /// Events the server accepted, ever.
  final int sent;

  /// Events given up on after too many server errors.
  final int failed;

  /// Events deleted unsent because the queue was full (or the buffer before
  /// `initialize` was).
  final int dropped;

  /// `track()` calls refused by validation, never stored.
  final int rejected;

  /// The signed-in user, if any.
  final String? userId;

  /// The installation's anonymous id; `clearUser` replaces it.
  final String anonymousId;

  @override
  bool operator ==(Object other) =>
      other is TrackLiteStats &&
      other.tracked == tracked &&
      other.pending == pending &&
      other.sending == sending &&
      other.sent == sent &&
      other.failed == failed &&
      other.dropped == dropped &&
      other.rejected == rejected &&
      other.userId == userId &&
      other.anonymousId == anonymousId;

  @override
  int get hashCode => Object.hash(
    tracked,
    pending,
    sending,
    sent,
    failed,
    dropped,
    rejected,
    userId,
    anonymousId,
  );

  @override
  String toString() =>
      'TrackLiteStats(tracked: $tracked, pending: $pending, '
      'sending: $sending, sent: $sent, failed: $failed, dropped: $dropped, '
      'rejected: $rejected, userId: $userId, anonymousId: $anonymousId)';
}
