## 0.2.0

- **Events are stored.** `track()` validates and queues each event; one write queue stores everything queued in a frame in one transaction, in call order, in the SDK's own database (`tracklite.sqlite`).
- **Validation:** a name of 1–64 characters, up to 25 properties, keys of 1–40 characters not starting with `$`, and values that are a `String` (up to 255 characters), a finite `num` or a `bool`. An invalid event is dropped and counted as rejected, never thrown.
- **The queue is bounded** by `maxQueueSize`: past it, the oldest unsent events are dropped, and counted.
- **Calls made before `initialize` finishes** are kept (up to `TrackLite.earlyCallLimit` events) and replayed in order, with the time they were made.
- **Identity:** a stored anonymous id, created on the first start; `setUserId` persists, and `clearUser` also starts a new anonymous id.
- **Debug tools:** `TrackLite.debug.watchStats()` gives `TrackLiteStats` (tracked, pending, sending, sent, failed, dropped, rejected, the ids).
- **`package:tracklite/testing.dart`:** `TrackLiteTesting.useInMemoryDatabase()` for an app's widget tests.
- If the database file can't be opened, the session's events are kept in memory (logged), and `initialize` still succeeds.
- **Breaking:** `TrackLiteClient` has a new member, `debug`. Apps that implement the interface (a fake in their tests) add it.

## 0.1.0

- The public API's shape:
  - `TrackLite` (`initialize`, `track`, `setUserId`, `clearUser`, `flush`, `shutdown`, `instance`, `version`);
  - `TrackLiteClient`;
  - `TrackLiteConfig`, with its rules checked at `initialize`;
  - `TrackLiteEvent`, `EventStatus` and the six `FlushResult` cases.
- Calls are logged in debug mode. Events aren't stored or sent yet: that's 0.2.0 and 0.3.0.
