/// What a `flush()` did. It never throws: every outcome is one of these.
///
/// The set is sealed, so an app can `switch` over it exhaustively. That also
/// makes adding a case a breaking change for every app that does, which is
/// why all six exist from the SDK's first version.
sealed class FlushResult {
  const FlushResult();
}

/// Every pending event was sent: [events] of them, in [batches] requests.
final class Uploaded extends FlushResult {
  /// The outcome of an upload that sent everything.
  const Uploaded({required this.events, required this.batches});

  /// How many events the server accepted.
  final int events;

  /// How many requests it took.
  final int batches;

  @override
  String toString() => 'Uploaded($events events, $batches batches)';
}

/// The queue had nothing to send.
final class NothingToSend extends FlushResult {
  /// The outcome of a flush with an empty queue.
  const NothingToSend();

  @override
  String toString() => 'NothingToSend()';
}

/// The device is offline: nothing was attempted, and the events wait.
final class Offline extends FlushResult {
  /// The outcome of a flush while offline.
  const Offline();

  @override
  String toString() => 'Offline()';
}

/// An upload failed; [remaining] events are still waiting.
final class Failed extends FlushResult {
  /// The outcome of an upload that failed part way.
  const Failed({required this.reason, required this.remaining});

  /// Why, in words for a log or a developer.
  final String reason;

  /// How many events are still waiting to be sent.
  final int remaining;

  @override
  String toString() => 'Failed($reason, $remaining remaining)';
}

/// The server rejected the API key. Automatic uploads pause until the next
/// `initialize`; the events are kept.
final class Unauthorized extends FlushResult {
  /// The outcome of a flush with an API key the server rejects.
  const Unauthorized();

  @override
  String toString() => 'Unauthorized()';
}

/// The SDK isn't running: `initialize` hasn't finished, or `shutdown` ran.
final class NotInitialized extends FlushResult {
  /// The outcome of a flush when the SDK isn't running.
  const NotInitialized();

  @override
  String toString() => 'NotInitialized()';
}
