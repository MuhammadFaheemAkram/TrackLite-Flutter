import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tracklite/src/model/event_status.dart';
import 'package:tracklite/src/model/tracklite_event.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

/// A stored row as the public model the debug tools show.
@internal
extension EventRowMapper on EventRow {
  TrackLiteEvent toEvent() => TrackLiteEvent(
    id: id,
    name: name,
    timestamp: timestamp,
    userId: userId,
    anonymousId: anonymousId,
    properties: decodeProperties(properties),
    status: EventStatus.values.byName(status),
    attempts: attempts,
    nextAttemptAt: nextAttemptAt,
    lastError: lastError,
  );
}

/// The properties as stored: a JSON object. Validated values (`String`,
/// finite `num`, `bool`) round-trip exactly; an int stays an int.
@internal
String encodeProperties(Map<String, Object> properties) =>
    jsonEncode(properties);

@internal
Map<String, Object> decodeProperties(String json) =>
    (jsonDecode(json) as Map<String, dynamic>).cast<String, Object>();
