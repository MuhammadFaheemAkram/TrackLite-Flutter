/// Where an event is in its life, from `track()` to the server.
///
/// ```
/// pending ──claim──▶ sending ──accepted──▶ sent
///    ▲                  │
///    └──── a retry ─────┤
///                       └──── too many server errors ──▶ failed
/// ```
enum EventStatus {
  /// Stored and waiting for an upload (now, or after a retry's wait).
  pending,

  /// Claimed by an upload that is in flight.
  sending,

  /// Accepted by the server. Kept for a while so the debug tools can show it.
  sent,

  /// Given up on after too many server errors. Kept, never deleted silently:
  /// it can be retried.
  failed,
}
