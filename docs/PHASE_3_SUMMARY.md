# Phase 3 — Analytics Processing Pipeline

## Phase Goal

Send what Phase 2 stores. `flush()` now uploads every pending event in batches, oldest first, to a fake analytics server, and marks each one `sent`. The phase is about doing that **without losing or doubling anything**:
- **claims** that two uploaders can't share;
- **one run at a time**;
- **a stated delivery guarantee** (at least once), with the server deduplicating;
- **recovery** from an app killed mid-upload;
- **failures that keep the events** (Phase 4 adds backoff and the retry limits on top);
- **a schema change shipped as a migration**: the upload log is schema v2, and v1 databases upgrade in place on users' devices.

---

## What Was Implemented

- **The network boundary** (public):
  - `AnalyticsTransport.upload(UploadBatch) → UploadResponse`;
  - `UploadBatch` (API key, `sentAt`, the SDK version, the events) with `toJson()`, the body a real transport would `POST`;
  - `UploadResponse` (accepted, duplicates);
  - the sealed **`TransportException`**: `ServerUnreachable`, `ServerFailure` (5xx), `ApiKeyRejected` (401) and `RequestRejected` (4xx).
- **`FakeAnalyticsServer`** (public, the default transport):
  - latency (800 ms) and `failureRate` (10 %, with an injected `Random`), both changeable at any time;
  - `reachable`, and the API key check (blank, or starting `invalid` → 401);
  - the 100-event limit (→ 400);
  - **the body read through JSON**, as an HTTP server would;
  - **each event id kept once** (duplicates counted);
  - `FakeServerStats`.
- **`TrackLiteConfig.transport`:** `null` means the default server. Two configs are equal only with the same transport object.
- **Schema v2:**
  - the `uploads` log (trigger, times, outcome, batches, events, error), trimmed to the newest 100;
  - `stepByStep` migration from v1;
  - a migration test with real rows (events pending and failed, the identity, the totals).
- **`EventDao`:**
  - **`claim`:** one `UPDATE … WHERE seq IN (SELECT … ORDER BY seq LIMIT n)` that marks the oldest due events `sending` with a token, then reads them by token;
  - `releaseExpiredClaims`, `markSent`, `release`, `markFailed`, `pruneSent`, `waitingCount`.
- **`UploadManager`:**
  - **single-flight** (`_running ??= …`);
  - each run waits for the recorder, then puts back claims older than 5 minutes;
  - it claims and sends batch after batch, marking each `sent`, counting `sent_total` and pruning `sent` rows older than 24 hours, all in one transaction;
  - it stops at the first failure, and logs the run;
  - a failure's effect depends on its kind:
    - unreachable, a 5xx or a 401 → back to `pending` with the error;
    - a 400 → `failed`;
    - a transport that throws anything else → back to `pending`;
    - a database error → `Failed`, logged, with nothing thrown.
- **The client:**
  - `flush()` runs an upload that ignores backoff (Phase 4's retry times);
  - `shutdown()` waits for an upload in flight before closing the file;
  - `isUploading`.
- **`TrackLiteStats.sent`** is now the total ever accepted (rows are pruned).
- **The sample:**
  - the port's `flush()` and the app's own sealed `FlushOutcome` (freezed), mapped by the adapter;
  - `DashboardCubit.flush()` (one at a time, nothing emitted after close);
  - **Flush now** ("Sending…" while it runs) with the outcome in words (`flushWords`) in a SnackBar;
  - "Sent (ever)".

---

## SDK Concepts Demonstrated

- **At-least-once delivery, on purpose.**
  - Between "the server stored the batch" and "the device wrote `sent`" there is always a moment when the app can die.
  - **Exactly once** would need the phone and the server to commit together, which no network allows.
  - So the SDK sends again after a crash, and the server keeps each event id once. Duplicates cost nothing; a lost event can't be recovered.
- **Claims make concurrent uploaders safe.**
  - A claim is one statement: `UPDATE … SET status = 'sending', claim_token = ? WHERE seq IN (SELECT … LIMIT n)`.
  - A second uploader (Phase 4's background isolate) running the same statement gets the *next* events.
  - The token says whose they are, for the outcome.
- **Claims expire.**
  - A `sending` row whose upload died would otherwise be stuck forever.
  - After 5 minutes, a run puts it back to `pending`; the 5 minutes leave room for an upload still in flight elsewhere (tested both ways).
- **Single-flight.** One run at a time per client: a second `flush()` joins the first. Two runs of one client would claim separately and send in parallel, harder to reason about and kinder to nobody.
- **Stop at the first failure.** A failing server isn't sent the rest of the queue. The events stay, and the next trigger tries again (Phase 4).
- **The failure's kind decides the batch's fate.**
  - Unreachable, a 5xx or a 401 are worth another try: the batch goes back to `pending`.
  - A 400 means the server refused *these events*: sending them again would be refused again. They are marked `failed`, and kept.
  - The sealed `TransportException` makes the transport say which kind it is.
- **The transport is an extension point.**
  - `TrackLiteConfig.transport` takes any `AnalyticsTransport`.
  - The batch's `toJson()` is the contract with a server.
  - `sentAt` lets a server correct a device whose clock is off.
  - `library.version` says which SDK produced an event.
- **A fake that behaves like a server:**
  - latency, failures and reachability;
  - an API key check and a batch limit;
  - deduplication;
  - the body read through JSON, so anything that can't be encoded fails as it would on a real server.
- **Counters, not row counts.** `sent` rows are pruned after a day, so "sent, ever" lives in `sent_total`, updated in the same transaction as the rows.
- **An SDK's schema migrates on its users' devices.**
  - The upload log is schema v2, with a `stepByStep` migration and a test that upgrades a v1 database holding real events.
  - On the simulator, the database installed by Phase 2 upgraded in place, and both waiting events survived.

---

## Flutter / Dart Concepts Demonstrated

- **drift migrations:**
  - `make-migrations` generates the steps file, the versioned schemas and a migration test;
  - `stepByStep(from1To2: …)`;
  - `SchemaVerifier.testWithDataIntegrity` with real rows (§11.28: the generated template filled in).
- **SQLite claims:**
  - `UPDATE … WHERE seq IN (SELECT … ORDER BY seq LIMIT ?)`;
  - numbered parameters (`?1 … ?4`), reused within one statement;
  - `julianday` for time comparisons (§11.60).
- **Sealed exception hierarchies** for a public API: hosts throw them, and a `switch` over them is exhaustive (the public-API test has one).
- **`fake_async`** to prove the fake server answers after exactly its latency.
- **A gate (`Completer`) in a scripted transport** to hold an upload in flight, and test single-flight and "shutdown waits".
- **A seeded `Random`** to test a failure rate statistically: 1,000 requests at 30 % give 250–350 failures.
- **`@freezed sealed` unions** for the sample's `FlushOutcome`, and a `switch` that maps the SDK's results onto them.

---

## Event Flow

```
TrackLite.flush() / Dashboard "Flush now"
  → UploadManager.upload(manual, ignoreBackoff: true)          (joins a run already going)
       → recorder.idle                                         (everything tracked is stored first)
       → releaseExpiredClaims(now − 5 min)                     (an upload that died)
       → loop:
           claim(token, LIMIT batchSize)    pending → sending   (one statement)
           └─ none → done
           transport.upload(UploadBatch{key, sentAt, version, events})
           ├─ ok  → one transaction: sending → sent (sent_at), sent_total += n, prune sent > 24 h
           ├─ ServerUnreachable / ServerFailure / ApiKeyRejected → sending → pending (last_error); stop
           └─ RequestRejected (400)                              → sending → failed  (last_error); stop
       → uploads log: trigger, times, outcome, batches, events, error
  → FlushResult: Uploaded(events, batches) · NothingToSend · Failed(reason, remaining) · Unauthorized
```

```
A crash after the server stored a batch:
  rows stay `sending` → next run, 5 min later: back to pending → sent again
  → server: same ids → duplicates, dropped → rows `sent`               (at least once, no doubles)
```

---

## Important Files Added

| Path | Purpose |
|---|---|
| `packages/tracklite/lib/src/network/analytics_transport.dart` | The transport interface, the batch, the response, the errors |
| `packages/tracklite/lib/src/network/fake_analytics_server.dart` | The default transport: latency, failures, dedupe, stats |
| `packages/tracklite/lib/src/upload/upload_manager.dart` | Claims, batches, outcomes, single-flight, the log |
| `packages/tracklite/lib/src/storage/upload_dao.dart` | The upload log (newest 100) |
| `packages/tracklite/lib/src/storage/tracklite_database.steps.dart` | Generated: the versioned schemas for `stepByStep` |
| `packages/tracklite/lib/src/version.dart` | The SDK version, shared by the facade and the batches |
| `packages/tracklite/drift_schemas/tracklite_database/drift_schema_v2.json` | Schema v2 |
| `packages/tracklite/test/drift/tracklite_database/` | The migration test and the generated schemas |
| `packages/tracklite/test/helpers/scripted_transport.dart` | Scripted answers, a gate, the batches seen |
| `sample_app/lib/domain/analytics/flush_outcome.dart` | The app's own flush outcome |
| `sample_app/lib/features/dashboard/flush_words.dart` | An outcome in words |

---

## Important Types Added

| Type | Responsibility | Why there |
|---|---|---|
| `AnalyticsTransport` | Sends a batch | Public: the extension point for a real backend |
| `UploadBatch`, `UploadResponse` | A request and its answer | Public: what a transport works with |
| `TransportException` (+ 4) | Why an upload failed, by kind | Public and sealed: the kind decides the batch's fate |
| `FakeAnalyticsServer`, `FakeServerStats` | The default backend and what it saw | Public: the demo's server, and hosts' tests |
| `UploadManager`, `UploadTrigger` | Running uploads | `src/upload`, `@internal` |
| `Uploads`, `UploadDao` | The upload log | `src/storage` |
| `FlushOutcome`, `flushWords` | The sample's flush result and its words | Sample: domain and the Dashboard |

---

## Folder Structure Changes

```
packages/tracklite/
├── drift_schemas/tracklite_database/drift_schema_v2.json        (new)
├── lib/src/
│   ├── network/      analytics_transport, fake_analytics_server  (new)
│   ├── upload/       upload_manager                               (new)
│   ├── storage/      + upload_dao (+ .g), tracklite_database.steps
│   └── version.dart                                              (new)
└── test/  network/  upload/  drift/tracklite_database/  helpers/scripted_transport.dart
sample_app/lib/
├── domain/analytics/flush_outcome.dart (+ .freezed)
└── features/dashboard/flush_words.dart
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| The fake backend | `FakeAnalyticsApi`: delay, `FAILURE_RATE = 0.1` | `FakeAnalyticsService`: `Task.sleep`, `failureRate` | `FakeAnalyticsServer`: latency, failure rate, reachable, key check, batch limit, **dedupe by id** |
| The boundary | `AnalyticsApi.uploadEvents(List<EventDto>)` | `AnalyticsService.upload([EventDTO])` | `AnalyticsTransport.upload(UploadBatch)`: public, pluggable |
| Batching | `batchSize` per request | the same | the same, sent one after another, stopping at a failure |
| Statuses | `PENDING → SENDING → SENT / FAILED` | the same | the same, with **claim tokens**, and **expired claims** recovered |
| A crash mid-upload | `SENDING` stays | `sending` stays | claims expire (5 min); at least once; the server drops duplicates |
| Concurrent uploads | WorkManager uniqueness | the actor | **single-flight** per client; atomic claims across isolates |
| The upload log | — | — | the `uploads` table (schema v2, migrated) |
| Sent events | kept | kept | kept 24 h, then pruned; the total in a counter |

---

## Interview Notes

**Q: Why at-least-once instead of exactly-once delivery?**
A: Because there's always a gap between "the server stored it" and "the device recorded that". If the app dies in that gap, the device must either send again (maybe a duplicate) or not (maybe a loss). Exactly-once would need both sides to commit together, which a network can't give. So the SDK resends, and the server deduplicates by event id.

**Q: How do you stop two uploaders sending the same events?**
A: Claim them in one statement. `UPDATE … SET status = 'sending', claim_token = ? WHERE seq IN (SELECT seq … LIMIT n)` is atomic in SQLite, so a second uploader running it gets the next rows. The token identifies the claim for the outcome. Within one client, runs are also single-flight.

**Q: What happens to events that were `sending` when the app was killed?**
A: Their claim has a time. A run puts any claim older than 5 minutes back to `pending`, and they're sent again; the server drops the copies it already had. Five minutes is longer than any upload should take, so a claim that is still in flight elsewhere isn't stolen (both cases are tested).

**Q: Why stop the run at the first failed batch?**
A: If the server is failing or unreachable, sending the rest makes it worse and burns the battery. The events stay; the next trigger tries again. Phase 4 adds the backoff that spaces those tries.

**Q: Why does a 400 mark events `failed` but a 500 doesn't?**
A: A 500 says the server had a problem: the same batch may work next time. A 400 says the request itself is wrong: sending it again would be refused again, forever, blocking the queue behind it. So those events leave the queue as `failed`, are kept for the debug tools, and can be retried by hand.

**Q: How do you change an SDK's database schema?**
A: Bump `schemaVersion`, then export the new version with drift's `make-migrations`. Write the migration step (`from1To2: createTable(uploads)`), and test every upgrade path against the exported schemas, including real rows. The SDK's users have old databases on their phones; the upgrade happens there.

---

## Learning Checklist

- ✅ A public transport interface, with a sealed error type
- ✅ A fake server that behaves like one (latency, failures, key, limit, dedupe, JSON)
- ✅ Atomic claims with tokens; expired claims recovered
- ✅ Single-flight uploads, batch after batch, stopping at a failure
- ✅ At-least-once delivery, proven with a simulated crash
- ✅ Each failure kind's effect on the batch
- ✅ Sent rows pruned; totals in counters
- ✅ Schema v2 with a tested migration, and an in-place upgrade on the simulator
- ✅ The sample's Flush now, through the app's own port
- □ Backoff, retry limits, the 401 pause (Phase 4)
- □ Automatic triggers and background uploads (Phase 4)

---

## Future Improvements

- **Phase 4:**
  - the retry policy: attempts and `next_attempt_at` for server errors, `failed` after `maxRetries`, and the 401 pause;
  - the network monitor (offline → `Offline`, nothing attempted);
  - the triggers (interval, threshold, paused, reconnect, retry due) and `workmanager`.
- **Phase 5:** the upload log on the Dashboard (`watchUploads`), the server's stats and the demo controls.
- **A real HTTP transport:**
  - gzip;
  - `Retry-After` on a 429;
  - a request id for the server's own deduplication;
  - see the roadmap.

---

## Notes on This Phase

- **Spec adjustments:**
  - The pipeline handles each failure kind now: back to `pending`, `failed` for a 400, `Unauthorized` for a 401. Phase 4 adds the attempt counting, backoff, the retry limit and the 401 pause, as planned.
  - **`TrackLiteStats.sent` changed meaning:** from "rows still kept" to "accepted, ever", once rows began to be pruned.
  - **The SDK version** moved to `lib/src/version.dart`, so the uploader can stamp batches without importing the facade. `TrackLite.version` still reads it.
  - **The sample uses the default server** (800 ms, 10 % failures), so a demo flush can fail. Tests pass their own instant, reliable server through the harness.
- **On the simulator:**
  - the Phase 2 database (`user_version` 1, two pending events) upgraded to v2 in place: the `uploads` table was added and both events kept;
  - **Flush now** showed "Sending 2" during the 800 ms, then "Sent 2 events in 1 request." The database had both rows `sent`, one `manual` run logged, and `sent_total` 2;
  - an empty flush said "Nothing to send", light and dark.
- **Mutation checks:** 43 rules broken on purpose, one at a time.
  - **37 were caught at first.**
  - **Two didn't apply:** the formatter had wrapped those lines differently. Retargeted, both were caught.
  - **Three were missed, and now have tests:**
    - **the upload log's limit:** the test read `newest()`, which returns at most 100 anyway. It now counts every row;
    - **`TrackLiteStats.sent`** read from the kept rows instead of the counter: now checked after a prune;
    - **`flush()` respecting backoff:** an event with a future retry time must still go out on an explicit flush.
  - **One is equivalent:** "the upload doesn't wait for the recorder". drift's executor runs one statement at a time, so the claim queues behind the recorder's write anyway. The wait stays, as the rule the code promises, with a comment.
  - **42 of 43 caught, 1 equivalent.**
