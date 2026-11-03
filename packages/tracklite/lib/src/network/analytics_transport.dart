import 'package:flutter/foundation.dart';
import 'package:tracklite/src/model/tracklite_event.dart';

/// How batches reach an analytics server: the SDK's network boundary.
///
/// The SDK ships one, [FakeAnalyticsServer]. A real backend is another
/// implementation (an HTTP `POST` of [UploadBatch.toJson]), passed in
/// `TrackLiteConfig.transport`: nothing else in the SDK changes.
abstract interface class AnalyticsTransport {
  /// Sends [batch]. Completes with the server's answer, or throws a
  /// [TransportException] saying what went wrong.
  Future<UploadResponse> upload(UploadBatch batch);
}

/// One upload request: up to `batchSize` events, oldest first.
@immutable
final class UploadBatch {
  /// A batch, built by the SDK.
  const UploadBatch({
    required this.apiKey,
    required this.sentAt,
    required this.libraryVersion,
    required this.events,
  });

  /// The app's API key (a header for a real backend, not part of the body).
  final String apiKey;

  /// When the SDK sent it: a server can compare it with its own clock to
  /// correct the events' times for a device whose clock is off.
  final DateTime sentAt;

  /// The SDK's version (`TrackLite.version`), so the server knows which
  /// client produced the events.
  final String libraryVersion;

  /// The events, oldest first.
  final List<TrackLiteEvent> events;

  /// The request body, as JSON: what a real transport would send.
  Map<String, Object?> toJson() => {
    'sent_at': sentAt.toUtc().toIso8601String(),
    'library': {'name': 'tracklite', 'version': libraryVersion},
    'events': [
      for (final event in events)
        {
          'id': event.id,
          'name': event.name,
          'timestamp': event.timestamp.toUtc().toIso8601String(),
          'user_id': event.userId,
          'anonymous_id': event.anonymousId,
          'properties': event.properties,
        },
    ],
  };
}

/// What the server did with a batch.
@immutable
final class UploadResponse {
  /// An answer from the server.
  const UploadResponse({required this.accepted, this.duplicates = 0});

  /// Events stored for the first time.
  final int accepted;

  /// Events the server already had (sent again after a crash mid-upload),
  /// dropped by id. They count as delivered.
  final int duplicates;

  @override
  bool operator ==(Object other) =>
      other is UploadResponse &&
      other.accepted == accepted &&
      other.duplicates == duplicates;

  @override
  int get hashCode => Object.hash(accepted, duplicates);

  @override
  String toString() =>
      'UploadResponse(accepted: $accepted, duplicates: $duplicates)';
}

/// Why an upload failed. The kind decides what happens to the batch.
sealed class TransportException implements Exception {
  const TransportException(this.message);

  /// What went wrong, in words for a log.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server couldn't be reached (no route, a timeout): it never saw the
/// batch.
final class ServerUnreachable extends TransportException {
  /// The server couldn't be reached.
  const ServerUnreachable([super.message = 'the server could not be reached']);
}

/// The server saw the batch and failed (a 5xx): it may work next time.
final class ServerFailure extends TransportException {
  /// The server answered [statusCode].
  const ServerFailure(this.statusCode, [String? message])
    : super(message ?? 'server error $statusCode');

  /// The HTTP status, 500–599.
  final int statusCode;
}

/// The server rejected the API key (a 401). Sending again won't help until
/// the app has a valid key.
final class ApiKeyRejected extends TransportException {
  /// The server rejected the API key.
  const ApiKeyRejected([super.message = 'the API key was rejected']);
}

/// The server refused the batch itself (a 4xx other than 401): a client
/// bug. The same batch would be refused again.
final class RequestRejected extends TransportException {
  /// The server answered [statusCode].
  const RequestRejected(this.statusCode, String message) : super(message);

  /// The HTTP status, 400–499.
  final int statusCode;
}
