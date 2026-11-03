import 'package:freezed_annotation/freezed_annotation.dart';

part 'flush_outcome.freezed.dart';

/// What sending the analytics queue did, in the app's own model.
@freezed
sealed class FlushOutcome with _$FlushOutcome {
  /// Everything waiting was sent.
  const factory FlushOutcome.sent({
    required int events,
    required int requests,
  }) = FlushSent;

  /// There was nothing to send.
  const factory FlushOutcome.nothingToSend() = FlushNothingToSend;

  /// The device is offline; nothing was tried.
  const factory FlushOutcome.offline() = FlushOffline;

  /// Sending failed; [waiting] events are still queued.
  const factory FlushOutcome.failed({
    required String reason,
    required int waiting,
  }) = FlushFailed;

  /// The analytics server refused the app's key.
  const factory FlushOutcome.keyRejected() = FlushKeyRejected;

  /// Analytics isn't running.
  const factory FlushOutcome.notRunning() = FlushNotRunning;
}
