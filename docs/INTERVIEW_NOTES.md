# Interview Notes

Questions this project answers, with short answers and where to look.

---

## SDK design

**How is designing an SDK different from designing an app?**
An SDK runs inside someone else's app, where its developer can't see it and its user didn't choose it. So it must never crash or block the host, its dependencies become the host's, and its public API is a promise: changing it breaks other people's code. See [SDK_DESIGN.md](SDK_DESIGN.md).

**How do you keep a Dart package's API small and stable?**
One library that exports a fixed list with `show`; everything else in `lib/src/`, marked `@internal`; `public_member_api_docs`; and a test that uses every exported name and switches over the sealed result with no `default`. An API change is then always a failing test, so a decision.

**Why a static facade *and* an interface?**
Most apps want one line anywhere (`TrackLite.track`). Apps with DI want to inject and fake it. The facade is a thin shell over one `TrackLiteClient`; `TrackLite.instance` hands that client to a DI container.

**What should an SDK do when the developer makes a mistake?**
Depends when. A bad config at `initialize` throws an `ArgumentError` naming every rule: it fails in development. A bad event at runtime is refused, counted and logged in debug mode, never thrown: an analytics call must not crash a user's app.

**What happens to calls made before `initialize` finishes?**
They're buffered (100 events), then replayed in order with the time they were made. `track()` in `main()` before `await initialize` isn't lost.

**Why no `freezed`, no `get_it` in the SDK?**
Its dependencies become every host's. A generated public model ties the SDK's API to a generator's version; a DI container or a state-management package is the app's choice to make.

**How would a host send events to its own backend?**
Implement `AnalyticsTransport.upload(UploadBatch)` and throw the right `TransportException` kind for each failure. The SDK owns the queue, batching and retries; the transport only moves bytes.

---

## The pipeline

**Walk me through `track()`.**
Validate → stamp (UUID, UTC time, the identity now) → queue in memory → a microtask drain writes the frame's calls in one transaction → a trigger → claim a batch in one statement → send → mark `sent` in one transaction, or apply the error table. See [EVENT_PIPELINE.md](EVENT_PIPELINE.md).

**Why store every event before sending it?**
Because the app can be killed at any moment, and the network can be gone for days. An event in memory is one crash from lost. Stored first, every later step can fail and retry.

**Why not insert each event as it's tracked?**
100 `track()` calls in a frame would be 100 commits. A microtask drain batches them into one transaction, in call order, and the host never waits for the disk.

**How do you stop two uploaders sending the same events?**
A claim is one statement: `UPDATE … SET status = 'sending', claim_token = ? WHERE seq IN (SELECT … LIMIT n)`. SQLite runs one write at a time, so a second uploader (another trigger, or the background isolate) gets the next events. Inside the app, the uploader is also single-flight.

**What delivery guarantee does TrackLite give?**
At least once. `sent` is written after the server confirms; if the app dies in between, the claim expires after 5 minutes and the batch goes again. The server keeps each event id once, so the duplicate is harmless. Exactly once over a network isn't possible without the two sides committing together.

**How do you keep the queue from growing forever?**
Bounds everywhere: unsent events capped at 10,000 (oldest dropped, counted); `sent` rows kept 24 hours; the upload log at 100 runs. Totals live in counters, so pruning doesn't change them.

**Why order by `seq` and not by timestamp?**
Two events can share a millisecond, and a device's clock can move back (a manual change, a time-zone bug, NTP). Insertion order is the truth.

---

## Retries

**What counts as a retry attempt?**
Only a server error (5xx). Unreachable doesn't count: the server never saw the batch, and five blips on a train shouldn't kill an event. A 401 is the key's fault: automatic uploads pause. A 400 is the event's fault: `failed` at once. See [RETRY_STRATEGY.md](RETRY_STRATEGY.md).

**Why exponential backoff?**
When a server struggles, every phone retrying on a fixed interval keeps it down. Doubling (1, 2, 4… minutes, at most an hour) makes the load fall the longer the outage lasts. A real backend would add jitter and `Retry-After`.

**Why is backoff per event, not per client?**
An event that failed four times has waited longer than one tracked a minute ago. Each stores its own `next_attempt_at`; the claim takes only the due ones.

**What happens after the last retry?**
The event is `failed`, kept with its last error, and counted. Nothing automatic touches it again; `debug.retryFailed()` revives every failed event as if new.

**Does `flush()` respect backoff?**
No. A developer who calls `flush()` wants it now. Every automatic trigger respects it.

**A bug you found in the retry logic?**
The retry timer re-armed "at once" for a retry time already past. Unreachable doesn't move an event's retry time, so it looped as fast as the uploads failed. The timer is now only for a time still ahead; due events go with the interval or a reconnect. A test in fake time hung until it was fixed, and a mutation that brought the bug back hung the same way.

---

## Background work and lifecycle

**When does TrackLite upload?**
Every 30 s in the foreground; when a full batch is due; when the app goes to the background; on reconnect; when a retry is due; about every 15 minutes in the background (`workmanager`); and on `flush()`. Never offline.

**How does the background task know the config?**
It starts in a fresh isolate with nothing. `initialize` saves the config as JSON in the database; the dispatcher reads it, builds a client, uploads once, and closes. Objects (a transport, a monitor) can't cross isolates, so it uses the defaults.

**The background isolate and the app both open the database. Is that safe?**
drift's `shareAcrossIsolates` gives both one connection through a shared isolate, so writes are serialized and the app's streams see the background's changes. The claim is atomic either way.

**What if the host app already uses `workmanager`?**
A process has one dispatcher. The host sets `backgroundUploads: false` and calls `TrackLite.runBackgroundUpload()` from its own periodic task.

**Why upload when the app goes to the background?**
It's the last moment the app surely runs. iOS may suspend or kill it any time after; the background task is a safety net the OS may not run for hours.

---

## Testing

**How do you test an SDK full of timers, I/O and time?**
Seams everywhere: a `Clock`, an id generator, the transport, the network monitor, the lifecycle, the `workmanager` boundary. Tests use an in-memory database, a `ScriptedTransport` (with a gate to hold a request mid-flight), and `fake_async` for timers. See [TESTING.md](TESTING.md).

**How do you know the tests are any good?**
Mutation checks: every phase broke its key rules on purpose, one at a time. 236 checks over six phases; every miss became a test, and one equivalent mutation is documented. Most misses were tests passing by luck, like one retry time, so "earliest" and "latest" agreed.

**How does a host test an app that uses TrackLite?**
`package:tracklite/testing.dart`: an in-memory database (widget tests can't open a file), a switch for the SDK's timers (a test fails if one is pending at its end), and a `FakeNetworkMonitor`. Or inject `TrackLiteClient` and pass a fake.

**How do you keep the sample from depending on SDK internals?**
The Cubits depend on the app's own ports (`AnalyticsService`, `AnalyticsDebug`); adapters implement them. A test fails if anything else imports `package:tracklite`.

---

## Trade-offs

**What would you do differently for production?**
A real HTTP transport in its own package (gzip, `Retry-After`, jitter), consent and opt-out that deletes the queue, sessions and super properties, a transport factory for the background isolate, and publishing to pub.dev. See [ROADMAP.md](ROADMAP.md).

**What's the one way TrackLite can lose an event?**
A database that can't be written at all (a full disk). That drain is logged and dropped; the SDK can't count it, because it can't write the counter either. It chooses not to fail the host app over analytics.
