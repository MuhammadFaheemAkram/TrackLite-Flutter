# Phase 2 — Event Storage Layer

## Phase Goal

Make the SDK keep the promise in its one rule: **an event is written to the SDK's own database before anything else happens.** Phase 2 stores every `track()` call, and nothing is sent yet: the uploads are Phase 3. What this phase solves:
- **a queue that survives:** drift, in the SDK's own file, with the statuses the pipeline will move events through;
- **`track()` that never waits:** validated and stamped at once, written by a queue in the background, in call order;
- **inputs that can't poison the queue:** limits checked at `track()`, so a bad event is refused once, with a reason, instead of failing every upload;
- **limits on growth:** a bounded queue, and a bounded buffer for calls made before the SDK has started;
- **an identity:** a stored anonymous id, the user id, and a reset that doesn't link two people;
- **a first look inside:** the debug tools' stats, shown live on the sample's Dashboard.

---

## What Was Implemented

- **The database** (`TrackLiteDatabase`, schema v1, exported):
  - **`events`:**
    - `seq` (the insertion order) and `id` (a UUID, unique);
    - name, timestamp, user id, anonymous id, properties (JSON);
    - status, attempts, next attempt, claim token and time, sent time, last error.
  - **`CHECK`s:**
    - the four statuses, attempts ≥ 0, a JSON object, UTC times;
    - `sending` exactly when claimed, `sent` exactly when it has a send time.
  - An index on `(status, seq)`.
  - **`meta`:** the identity and the running totals (tracked, dropped, rejected).
  - `EventDao` (insert, unsent count, drop the oldest unsent) and `MetaDao` (read, write, remove, a one-statement counter).
  - One stats query that watches both tables.
- **`EventValidator`:**
  - a name of 1–64 characters (trimmed);
  - ≤ 25 properties, keys of 1–40 characters not starting with `$`;
  - values that are a `String` (≤ 255), a finite `num` or a `bool`.

  Pure and total: an answer, never an exception.
- **`EventRecorder`**, a serial write queue:
  - `record()` validates, stamps (id, time, the identity *now*) and queues;
  - a microtask later, one drain writes everything queued so far in **one transaction**, then the next batch;
  - it caps the queue (`maxQueueSize`: the oldest unsent are dropped, counted) and keeps the totals;
  - `idle`, and `close` (store, then refuse).
- **`IdentityStore`:**
  - the anonymous id, created and stored on the first start;
  - the user id, persisted;
  - `clear()` removes the user **and starts a new anonymous id**.
- **The client** (`TrackLiteClientImpl.open`):
  - opens the database (and **falls back to memory, logged**, if the file can't be opened), loads the identity, and records through the queue;
  - checks user ids (1–255 characters);
  - `flush()` waits for the writes; `shutdown()` stores, then closes the file;
  - `debug`.
- **The facade:**
  - **calls made before `initialize` finishes are kept and replayed** in order, each with the time it was made;
  - at most `earlyCallLimit` (100) events: the oldest are dropped and counted; identity calls always stay;
  - nothing is kept between a `shutdown` and the next `initialize`;
  - `TrackLite.debug`.
- **Public API (0.2.0):**
  - `TrackLiteDebug` (`watchStats()`) and `TrackLiteStats`;
  - a second library, **`package:tracklite/testing.dart`**, with `TrackLiteTesting.useInMemoryDatabase()` for apps' widget tests;
  - `TrackLiteClient.debug`, a breaking change for implementers, recorded in the changelog.
- **The sample:**
  - the port's `watchQueue()` and the app's own `QueueStats`, mapped by the adapter;
  - `DashboardCubit`, and the Dashboard's Queue, Totals and Identity sections (`StatRow`: an icon, a word and a count, read as "Pending: 2");
  - the harness starts the real SDK in memory.

---

## SDK Concepts Demonstrated

- **Store first, send later.**
  - `track()` returns before anything touches the disk; a queue writes it a microtask later.
  - An app's frame is never held up by analytics, and an event exists on disk before any upload can look for it.
- **Group commit.** A burst of calls in one frame is one transaction: 100 taps are one commit, not 100. A reader sees none of them or all (tested).
- **Order is a property you keep.**
  - One queue for events *and* identity changes, so `track` then `setUserId` is stored in that order.
  - The identity is stamped at the call, not at the write.
  - The queue is ordered by an insertion `seq`, never by time: two events can share a millisecond, and a clock can move back.
- **Validate at the edge.**
  - A bad event is refused once, at `track()`, with a reason in the debug log, and counted as rejected.
  - Accepted, it would fail every upload that carried it, forever.
- **Every exit is counted.** Rejected, dropped (queue full), dropped early (buffer full): each has a counter, so "no silent loss" is checkable on a dashboard.
- **Bounded everything.**
  - The queue (`maxQueueSize`) and the early buffer (100 events) have limits.
  - An SDK that grows without limit, on a phone offline for weeks, becomes the host's bug.
- **Calls before `initialize`.**
  - Apps track from wherever they like, sometimes before the SDK has opened its file.
  - Those calls are kept, in order, with their own times, and replayed: dropped only past the limit, and counted then.
- **Privacy in the identity.** `clearUser()` rotates the anonymous id. Keeping it would link the next person on a shared device to the last one, as if they were the same user.
- **Degrade, don't fail.** If the database file can't be opened, the session's events live in memory (logged). `initialize` still succeeds, and the host never sees the failure.
- **The SDK's own file.** Never the host's database: neither can break the other's schema, and the schema version and exported history belong to the SDK.
- **A testing library.** `package:tracklite/testing.dart` gives apps a switch their tests need (an in-memory database), without putting test-only names in the everyday API.
- **Adding a member to a public interface breaks implementers.** `TrackLiteClient.debug` broke the sample's own fake client: the CHANGELOG says so, and 0.x is where that is allowed.

---

## Flutter / Dart Concepts Demonstrated

- **drift in a package:** its own `build.yaml`, `make-migrations` with the schema directory inside the package, `@internal` tables and DAOs.
- **`customConstraints` as invariants:** `(status = 'sending') = (claim_token IS NOT NULL AND claimed_at IS NOT NULL)` makes "a claim exists exactly while sending" impossible to break by a bug.
- **One query watching two tables** (`customSelect(..., readsFrom: {events, meta}).watchSingle()`), instead of combining streams (and adding a stream package to the SDK).
- **A counter in one statement:** `INSERT … ON CONFLICT (name) DO UPDATE SET value = value + excluded.value`.
- **`scheduleMicrotask` for batching:** calls in the same synchronous run join the queue before the drain starts.
- **An `async` function runs synchronously until its first `await`.** A `throw` before it runs the function's `finally` before the caller has even stored the returned future. Here `_starting ??= _start(config)` kept a failed start forever (see Notes).
- **Private named parameters** (`required this._recorder`, passed as `recorder:`), which `dart fix` applied.
- **`NativeDatabase.memory(setup: ...)`** to make a database that fails to open, and a temporary file to prove `shutdown` stores before it closes.
- **`withClock`** (package `clock`) to stamp calls with a chosen time in tests.
- **`implements` an interface from another package in tests:** the sample's fake `TrackLiteClient` and `TrackLiteDebug`.

---

## Event Flow

```
TrackLite.track('purchase', {price: 12.5})         (the host's frame; returns at once)
  ├─ SDK not started yet → kept in the early buffer, stamped now → replayed on start
  └─ running → TrackLiteClientImpl.trackAt
       → EventRecorder.record
            → validateEvent ── Rejected → AddToCounter(rejected_total) + a debug warning
            └─ Valid → InsertEvent(id: uuid, timestamp: now (UTC), userId, anonymousId, pending)
       → the queue ── scheduleMicrotask ──▶ drain: ONE transaction for everything queued
                                               ├─ meta writes and counters
                                               ├─ insert the events (seq in call order)
                                               ├─ tracked_total += n
                                               └─ over maxQueueSize → drop the oldest unsent, dropped_total += k
       → drift notifies → watchStats() → TrackLiteStats
            → (sample) adapter → QueueStats → DashboardCubit → "Pending: 2"
```

```
TrackLite.flush()   → waits for the queue → NothingToSend   (uploads: Phase 3)
TrackLite.shutdown() → stores what is queued → closes the file → later calls ignored
```

---

## Important Files Added

| Path | Purpose |
|---|---|
| `packages/tracklite/build.yaml` | drift options: UTC text dates, the schema directory |
| `packages/tracklite/lib/src/storage/tables.dart` | `events` and `meta`, with their `CHECK`s |
| `packages/tracklite/lib/src/storage/tracklite_database.dart` | The SDK's own database; the stats query; the opener |
| `packages/tracklite/lib/src/storage/{event_dao,meta_dao}.dart` | The queue's SQL; named values and counters |
| `packages/tracklite/lib/src/storage/event_mapper.dart` | Row → `TrackLiteEvent`; properties as JSON |
| `packages/tracklite/lib/src/recording/event_validator.dart` | The limits, checked at `track()` |
| `packages/tracklite/lib/src/recording/event_recorder.dart` | The serial write queue (group commit, the cap) |
| `packages/tracklite/lib/src/identity/identity_store.dart` | The anonymous id and the user id |
| `packages/tracklite/lib/src/debug/tracklite_debug.dart` | `TrackLiteDebug` and its database implementation |
| `packages/tracklite/lib/src/model/tracklite_stats.dart` | The stats snapshot |
| `packages/tracklite/lib/testing.dart` | The second public library: `TrackLiteTesting` |
| `packages/tracklite/drift_schemas/tracklite_database/drift_schema_v1.json` | Schema v1, kept to migrate from |
| `sample_app/lib/domain/analytics/queue_stats.dart` | The app's own queue model |
| `sample_app/lib/features/dashboard/cubit/` | `DashboardCubit`, `DashboardState` |
| `sample_app/lib/core/design_system/widgets/stat_row.dart` | An icon, a word and a count |
| `sample_app/test/app/dashboard_flow_test.dart` | The real SDK in memory: tap → stored → shown |

---

## Important Types Added

| Type | Responsibility | Why there |
|---|---|---|
| `TrackLiteDatabase`, `Events`, `MetaEntries` | The queue and the SDK's facts | `src/storage`, `@internal`: the schema is the SDK's own |
| `EventDao`, `MetaDao` | SQL for the queue, values and counters | `src/storage` |
| `EventRecorder` | Validate, stamp, queue; write in order, in one transaction | `src/recording`: the heart of "store first" |
| `PendingWrite` (`InsertEvent`, `SetMeta`, `AddToCounter`) | One queued change | `src/recording` |
| `Validation` (`Valid`, `Rejected`), `EventLimits` | The rules for an event | `src/recording`, pure |
| `IdentityStore` | Who the events are about; reset with rotation | `src/identity` |
| `DatabaseDebug` | The debug tools from the database | `src/debug` |
| `TrackLiteDebug`, `TrackLiteStats` | Seeing inside the SDK | Public: support and debug screens |
| `TrackLiteTesting` | Test switches for host apps | Public, in `testing.dart` only |
| `QueueStats`, `DashboardCubit` | The Dashboard's queue | Sample: the app's own words |
| `StatRow` | A labelled number, one semantics node | Sample design system |

---

## Folder Structure Changes

```
packages/tracklite/
├── build.yaml                                  (new)
├── drift_schemas/tracklite_database/drift_schema_v1.json
├── lib/
│   ├── testing.dart                            (new: the second public library)
│   └── src/
│       ├── storage/      tables, tracklite_database (+ .g), event_dao (+ .g), meta_dao (+ .g), meta_keys, event_mapper
│       ├── recording/    event_validator, event_recorder
│       ├── identity/     identity_store
│       ├── debug/        tracklite_debug
│       ├── model/        + tracklite_stats
│       └── testing/      tracklite_testing
└── test/  storage/  recording/  identity/  debug/  helpers/sdk.dart
sample_app/
├── lib/domain/analytics/queue_stats.dart
├── lib/features/dashboard/cubit/
├── lib/core/design_system/widgets/stat_row.dart
└── test/features/dashboard/  test/app/dashboard_flow_test.dart
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| The queue | Room: `EventEntity`, `EventDao`, `TrackLiteDatabase` | SwiftData `@Model EventEntity` in the SDK's own `ModelContainer` | drift: `Events`, `EventDao`, `TrackLiteDatabase` (`tracklite.sqlite`) |
| Thread safety | coroutines on a dispatcher | an **actor** guards the queue | one isolate's event loop + **a serial write queue**; transactions |
| Writes | one insert per `track()` | one save per event | **group commit:** a frame's calls in one transaction |
| Properties | `Map<String, String>` | `[String: String]` | `String`, `num`, `bool` values, validated (limits defined) |
| Invalid input | unspecified | unspecified | **refused at `track()`,** counted, logged |
| Queue size | unbounded | unbounded | **`maxQueueSize`**, oldest unsent dropped, counted |
| Before `initialize` | undefined | undefined | **kept and replayed** (100), with their own times |
| Identity | user id | user id | **+ an anonymous id**, rotated by `clearUser` |
| A broken database | unspecified | unspecified | **memory for the session**, logged; `initialize` still succeeds |
| Concurrency test | — | "concurrent `track` calls stay consistent" | 100 calls in a frame: all stored, in order, no duplicates, one transaction |

---

## Interview Notes

**Q: Why doesn't `track()` write to the database directly?**
A: Because the host's frame would wait for the disk. `track()` validates and stamps the event in memory, queues it, and returns. A microtask later, one drain writes everything queued in one transaction. The event is durable a moment later, and 100 calls in a frame cost one commit.

**Q: How do you keep events in order if writes are asynchronous?**
A: One queue, drained by one loop at a time. Each batch is written in queue order, and the next waits for it. Identity changes go through the same queue. The user id is stamped at the call, so a `setUserId` right after a `track` can't change that event. The table orders by an insertion `seq`, never by timestamp.

**Q: What happens to a call made before `initialize`?**
A: It's kept with the time it was made, and replayed in order once the SDK has started:
- at most 100 events; past that, the oldest are dropped, and counted;
- identity calls always stay, so replayed events get the right user;
- after a `shutdown`, calls are ignored, because the app asked the SDK to stop.

**Q: Why validate properties on the client?**
A: An invalid event the server rejects would fail every batch that carried it, and retrying wouldn't help. Rejected at `track()`, it fails once, with a reason a developer can read in debug mode, and it's counted.

**Q: Why does `clearUser()` change the anonymous id?**
A: The anonymous id links events across sessions. If it survived a sign-out, the next person's events on that device would be tied to the previous user's. Amplitude's and Mixpanel's `reset()` do the same.

**Q: What if the database can't be opened?**
A: The SDK logs the error and keeps that session's events in memory. Throwing from `initialize` would crash the host over analytics; in memory, the app works and loses only what wasn't uploaded before it quits.

**Q: How does a host app test with the real SDK?**
A: `import 'package:tracklite/testing.dart';`, then `TrackLiteTesting.useInMemoryDatabase()` before `TrackLite.initialize`. It's a second public library, so test-only switches never appear in the everyday API.

---

## Learning Checklist

- ✅ drift inside a package: its own file, schema v1 exported, `@internal` tables
- ✅ Invariants as `CHECK`s (claim ⇔ sending, sent time ⇔ sent)
- ✅ Validation at `track()`, rejected events counted
- ✅ A serial write queue with group commit, in call order
- ✅ A bounded queue and a bounded early buffer, every drop counted
- ✅ Calls before `initialize` replayed with their own times
- ✅ A persisted identity, rotated on `clearUser`
- ✅ A database that can't open → memory, not a crash
- ✅ `TrackLiteDebug.watchStats()` and the sample's live Dashboard
- ✅ A testing library for host apps
- □ Uploading: the fake server, batches, statuses (Phase 3)
- □ Retries and background uploads (Phase 4)

---

## Future Improvements

- **Phase 3:**
  - the fake server and the upload pipeline (claims, batches, `sent`);
  - `sent` and the totals pruned and counted;
  - the `uploads` log, as schema v2 with a tested migration.
- **A store that fails mid-session** (a full disk): the failed batch is logged and dropped today. A retry, or holding it in memory for the next drain, would keep it (on the roadmap).
- **Coalescing identity writes:** ten `setUserId` calls in a frame write ten times; only the last matters.

---

## Notes on This Phase

- **A bug the tests found:**
  - Moving `config.validate()` into `_start` made a bad config throw *before `_start`'s first `await`*. An `async` function runs synchronously up to there.
  - So its `finally` (`_starting = null`) ran before `_starting ??= _start(config)` had stored the failed future. The failed start then stayed in `_starting`, and every later `initialize` joined it.
  - Seven facade tests failed at once. `initialize` now validates before the start exists.
- **Spec adjustments:**
  - **The anonymous id rotation is here** (the spec had it in Phase 5), since `clearUser` already existed.
  - **`TrackLiteStats` has a `tracked` total** (the spec's "total tracked events"), kept as a counter.
  - **The testing library is new:** host apps' widget tests can't open a file, and the alternative, a test switch in the main API, would be worse.
  - **The fallback to memory is new.** The spec only said `initialize` doesn't throw at runtime.
  - **The SnackBar outlives its screen (§11.48):** Buy's SnackBar stays on the Dashboard for its 4 seconds. That's harmless here, so it was left alone.
- **On the simulator:**
  - the Dashboard showed the stored events, light and dark;
  - after a relaunch, `tracklite.sqlite` held the same events, UTC timestamps and the same anonymous id (read with `sqlite3`);
  - taps made during a tab switch don't register, so only the taps that did were stored. That's the simulator, not the SDK.
- **Mutation checks:** 47 rules broken on purpose, one at a time.
  - **44 were caught at first.** One more ("tests use the device database") was caught by its timeout: a widget test can't open the device's file, so it hangs.
  - **"No transaction" was missed.** A drift `batch` is atomic by itself, and its stream updates are merged, so "a reader sees none or all" couldn't tell. The test now queues a meta write with a failing insert and expects both rolled back: all or nothing across the whole drain.
  - **"`flush()` doesn't wait for the writes" was missed.** A read after it queued behind the write in drift's executor and passed anyway. The test now checks that nothing is pending the moment `flush()` returns (the recorder's `isIdle`, for tests only).
  - **47 of 47 caught.**
- **CI on a clean copy caught one more thing:** the recorder's `isIdle` was marked `@visibleForTesting`, but the client (another library) reads it. `invalid_use_of_visible_for_testing_member` is a warning, and the publish dry run fails on warnings (exit 65). Only the client's getter is test-only now.
