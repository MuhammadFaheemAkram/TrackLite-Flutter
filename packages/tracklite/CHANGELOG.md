## 0.6.0

- **Documentation:** the README is final (installation, the delivery guarantee, the configuration in full), and the repository's design docs explain the API, the pipeline and the retry strategy.
- **The API docs build cleanly,** checked in CI: `dartdoc_options.yaml` makes a broken doc reference an error.
- No API or behaviour change.

## 0.5.0

- **Debug tools:**
  - `watchRecentEvents()`: the newest events, any status;
  - `watchUploads()`: the upload log, as `UploadRecord`s;
  - `retryFailed()`: failed events back in the queue, as if new.
- **`TrackLiteStats` also says:**
  - when the next retry is due;
  - the last upload;
  - whether the SDK is online and uploading.

  It updates when any of them changes.
- **`TrackLiteNavigatorObserver`:** tracks `screen_opened {screen: <route name>}` for named page routes that are pushed, popped back to or replaced. It skips a navigator's first route, and never sends arguments.
- **`FakeAnalyticsServer.watchStats()`:** the server's counts, live.

## 0.4.0

- **Retries with backoff:**
  - `RetryPolicy` (1 minute, doubling, at most an hour), set by `TrackLiteConfig.retry`;
  - a server error (5xx) counts an attempt, and the event waits its backoff;
  - past `maxRetries`, it is `failed`, kept with its last error.
- **What isn't counted:**
  - an unreachable server, because it never saw the events;
  - a rejected API key (401), which pauses automatic uploads until the next `initialize`.
- **`NetworkMonitor`:**
  - the default is `ConnectivityNetworkMonitor` (`connectivity_plus`), and an app can pass its own (`TrackLiteConfig.networkMonitor`);
  - offline, nothing is attempted and `flush()` returns `Offline`.
- **Automatic uploads:**
  - every `flushInterval` in the foreground;
  - when a write leaves a full batch due;
  - when the app goes to the background;
  - on reconnect;
  - when the earliest retry wait ends.

  All respect backoff; an explicit `flush()` ignores it.
- **Background uploads** with `workmanager`, about every 15 minutes, with a network:
  - registered at `initialize` when `backgroundUploads` is true, and cancelled when false;
  - the task reads the config `initialize` saved;
  - an app with its own `workmanager` dispatcher calls `TrackLite.runBackgroundUpload()`;
  - iOS needs the task registered in the host (see the README).
- **The database is shared across isolates,** so the app and the background task can upload at once; claims keep them apart.
- `FakeNetworkMonitor` in `package:tracklite/testing.dart`.

## 0.3.0

- **Events are uploaded.** `flush()` stores what was tracked, then sends every pending event in batches of `batchSize`, oldest first, and reports a `FlushResult`.
- **One upload at a time:** a flush during an upload joins it.
- **Statuses:**
  - a batch is claimed (`pending` → `sending`, in one statement, so two uploaders never send the same event);
  - on success it is `sent`, with the total kept in a counter;
  - `sent` events are kept 24 hours, then pruned.
- **Failures keep the events and stop the run:**
  - unreachable, a 5xx and a 401 put the batch back to `pending`, with the error;
  - a 400 marks it `failed`;
  - a 401 is reported as `Unauthorized`.
- **At least once:**
  - a `sending` claim older than 5 minutes (the app died mid-upload) goes back to `pending` and is sent again;
  - the server drops duplicates by event id.
- **`AnalyticsTransport`:** the network boundary, with `UploadBatch` (and its JSON body), `UploadResponse` and the sealed `TransportException` (`ServerUnreachable`, `ServerFailure`, `ApiKeyRejected`, `RequestRejected`). Set it with `TrackLiteConfig.transport`.
- **`FakeAnalyticsServer`, the default transport:**
  - latency (800 ms) and a failure rate (10 %);
  - `reachable`, and an API key check (a blank key or one starting `invalid` is rejected);
  - the 100-event batch limit, deduplication by id, and `FakeServerStats`.
- **Schema v2** adds the `uploads` log (the newest 100 runs), with a tested migration from v1.
- `TrackLiteStats.sent` is now the total ever accepted.

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
