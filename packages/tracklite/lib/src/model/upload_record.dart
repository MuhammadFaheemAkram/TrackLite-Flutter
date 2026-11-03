import 'package:flutter/foundation.dart';

/// One upload run, as the upload log keeps it (the newest 100).
@immutable
final class UploadRecord {
  /// A run, as stored. Only the SDK creates these.
  const UploadRecord({
    required this.trigger,
    required this.startedAt,
    required this.finishedAt,
    required this.outcome,
    this.batches = 0,
    this.events = 0,
    this.error,
  });

  /// What started it: `manual` (a flush), `interval`, `threshold`,
  /// `paused`, `reconnect`, `retryDue` or `background`.
  final String trigger;

  /// When it started and ended, in UTC.
  final DateTime startedAt;

  /// When it ended, in UTC.
  final DateTime finishedAt;

  /// `uploaded`, `nothing`, `offline`, `failed` or `unauthorized`.
  final String outcome;

  /// Requests that succeeded.
  final int batches;

  /// Events the server accepted.
  final int events;

  /// Why it failed, if it did.
  final String? error;

  @override
  bool operator ==(Object other) =>
      other is UploadRecord &&
      other.trigger == trigger &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt &&
      other.outcome == outcome &&
      other.batches == batches &&
      other.events == events &&
      other.error == error;

  @override
  int get hashCode => Object.hash(
    trigger,
    startedAt,
    finishedAt,
    outcome,
    batches,
    events,
    error,
  );

  @override
  String toString() =>
      'UploadRecord($trigger, $outcome, $events events in $batches '
      'batches${error == null ? '' : ', $error'})';
}
