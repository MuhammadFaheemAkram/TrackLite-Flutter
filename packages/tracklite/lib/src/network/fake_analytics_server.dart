import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tracklite/src/connectivity/network_monitor.dart';
import 'package:tracklite/src/network/analytics_transport.dart';

/// What the fake server has seen.
@immutable
final class FakeServerStats {
  /// A snapshot of the server's counts.
  const FakeServerStats({
    this.requests = 0,
    this.accepted = 0,
    this.duplicates = 0,
    this.failures = 0,
  });

  /// Upload requests received (including those it then failed).
  final int requests;

  /// Distinct events stored.
  final int accepted;

  /// Events received again and dropped by id.
  final int duplicates;

  /// Requests that got an error back.
  final int failures;

  @override
  bool operator ==(Object other) =>
      other is FakeServerStats &&
      other.requests == requests &&
      other.accepted == accepted &&
      other.duplicates == duplicates &&
      other.failures == failures;

  @override
  int get hashCode => Object.hash(requests, accepted, duplicates, failures);

  @override
  String toString() =>
      'FakeServerStats(requests: $requests, accepted: $accepted, '
      'duplicates: $duplicates, failures: $failures)';
}

/// An analytics server in memory, the SDK's default transport: there is no
/// real backend in this project.
///
/// It behaves like one where it matters: it takes about [latency] to
/// answer, fails a share of requests ([failureRate]), can be
/// [reachable] or not, checks the API key and the batch size, reads the
/// request as JSON (what an HTTP body would carry), and **keeps each event
/// id once**: an event sent twice is dropped and counted as a duplicate,
/// which is what makes at-least-once delivery safe.
///
/// The knobs can change at any time; a demo screen can turn them.
class FakeAnalyticsServer implements AnalyticsTransport {
  /// A server; the defaults are a realistic demo: 800 ms, 10 % failures.
  FakeAnalyticsServer({
    this.latency = const Duration(milliseconds: 800),
    this.failureRate = 0.1,
    this.reachable = true,
    Random? random,
  }) : _random = random ?? Random();

  /// The largest batch it accepts.
  static const int maxBatchSize = 100;

  /// How long an answer takes.
  Duration latency;

  /// The share of requests that fail with a 500: 0 (never) to 1 (always).
  double failureRate;

  /// Whether requests reach it at all.
  bool reachable;

  final Random _random;
  final Set<String> _seen = {};
  int _requests = 0;
  int _duplicates = 0;
  int _failures = 0;

  /// What it has seen so far.
  FakeServerStats get stats => FakeServerStats(
    requests: _requests,
    accepted: _seen.length,
    duplicates: _duplicates,
    failures: _failures,
  );

  final _statsChanges = StreamController<FakeServerStats>.broadcast();

  /// What it has seen: now, then after every request.
  Stream<FakeServerStats> watchStats() =>
      startWith(() => stats, _statsChanges.stream);

  /// Whether it has stored the event with [id].
  bool hasEvent(String id) => _seen.contains(id);

  @override
  Future<UploadResponse> upload(UploadBatch batch) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (!reachable) throw const ServerUnreachable();
    _requests++;
    try {
      return _receive(batch);
    } on TransportException {
      _failures++;
      rethrow;
    } finally {
      _statsChanges.add(stats);
    }
  }

  UploadResponse _receive(UploadBatch batch) {
    final key = batch.apiKey.trim();
    if (key.isEmpty || key.startsWith('invalid')) throw const ApiKeyRejected();
    // Through JSON and back, as an HTTP body would be: whatever can't be
    // encoded fails here, as it would on a real server.
    final body = jsonDecode(jsonEncode(batch.toJson())) as Map<String, dynamic>;
    final events = body['events'] as List<dynamic>;
    if (events.length > maxBatchSize) {
      throw RequestRejected(400, '${events.length} events in one batch');
    }
    if (_random.nextDouble() < failureRate) throw const ServerFailure(500);

    var accepted = 0;
    var duplicates = 0;
    for (final event in events.cast<Map<String, dynamic>>()) {
      if (_seen.add(event['id'] as String)) {
        accepted++;
      } else {
        duplicates++;
      }
    }
    _duplicates += duplicates;
    return UploadResponse(accepted: accepted, duplicates: duplicates);
  }
}
