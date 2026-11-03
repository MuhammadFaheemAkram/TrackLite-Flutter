import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

/// One event an [AnalyticsService] was asked to track. A value: two with the
/// same name and properties are equal (a record holding a `Map` wouldn't be,
/// since maps compare by identity).
@immutable
final class Tracked {
  const Tracked(this.event, [this.properties = const {}]);

  final String event;
  final Map<String, Object> properties;

  @override
  bool operator ==(Object other) =>
      other is Tracked &&
      other.event == event &&
      mapEquals(other.properties, properties);

  @override
  int get hashCode =>
      Object.hash(event, Object.hashAllUnordered(properties.keys));

  @override
  String toString() => 'Tracked($event, $properties)';
}

/// An [AnalyticsService] that remembers what it was asked to do, so a test
/// can check which events a screen sent without starting an SDK. Its queue
/// is whatever the test [emit]s.
class RecordingAnalytics implements AnalyticsService {
  final List<Tracked> events = [];
  final List<String?> identities = [];
  final _queue = StreamController<QueueStats>.broadcast();

  void emit(QueueStats stats) => _queue.add(stats);

  @override
  Stream<QueueStats> watchQueue() => _queue.stream;

  @override
  void track(String event, {Map<String, Object> properties = const {}}) =>
      events.add(Tracked(event, properties));

  @override
  void identify(String userId) => identities.add(userId);

  @override
  void reset() => identities.add(null);
}
