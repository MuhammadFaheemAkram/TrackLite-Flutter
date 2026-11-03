import 'package:flutter/foundation.dart';
import 'package:tracklite/src/model/event_status.dart';

/// One tracked event, as the SDK stores it.
///
/// Apps create events with `TrackLite.track`; they read them back only
/// through the debug tools, to see what the queue holds.
@immutable
final class TrackLiteEvent {
  /// An event as stored. Only the SDK creates these.
  const TrackLiteEvent({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.anonymousId,
    required this.properties,
    required this.status,
    this.userId,
    this.attempts = 0,
    this.nextAttemptAt,
    this.lastError,
  });

  /// A unique id (a UUID v4). The server uses it to drop duplicates, so an
  /// event uploaded twice (after a crash mid-upload) is counted once.
  final String id;

  /// What happened, such as `purchase`.
  final String name;

  /// When it was tracked, in UTC.
  final DateTime timestamp;

  /// The signed-in user when it was tracked, if any.
  final String? userId;

  /// The installation's anonymous id when it was tracked.
  final String anonymousId;

  /// The details: each value is a `String`, a finite `num` or a `bool`.
  final Map<String, Object> properties;

  /// Where it is in the pipeline.
  final EventStatus status;

  /// How many uploads of it the server failed.
  final int attempts;

  /// When an automatic upload may try it again (after a server error).
  final DateTime? nextAttemptAt;

  /// Why its last upload failed, if it did.
  final String? lastError;

  @override
  bool operator ==(Object other) =>
      other is TrackLiteEvent &&
      other.id == id &&
      other.name == name &&
      other.timestamp == timestamp &&
      other.userId == userId &&
      other.anonymousId == anonymousId &&
      mapEquals(other.properties, properties) &&
      other.status == status &&
      other.attempts == attempts &&
      other.nextAttemptAt == nextAttemptAt &&
      other.lastError == lastError;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    timestamp,
    userId,
    anonymousId,
    Object.hashAllUnordered([
      for (final MapEntry(:key, :value) in properties.entries)
        Object.hash(key, value),
    ]),
    status,
    attempts,
    nextAttemptAt,
    lastError,
  );

  @override
  String toString() =>
      'TrackLiteEvent($name, ${status.name}, id: $id, '
      'attempts: $attempts, properties: $properties)';
}
