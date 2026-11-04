# Testing

```bash
fvm flutter analyze                                    # the whole workspace
fvm dart format --output=none --set-exit-if-changed .
(cd packages/tracklite && fvm flutter test)            # the SDK: 211 tests
(cd sample_app && fvm flutter test)                    # the sample: 178 tests
(cd packages/tracklite && fvm flutter pub publish --dry-run)
```

**389 tests**, all on the host: no device, no network, no real clock, no file system. CI runs the same commands on every push and pull request, after checking that the committed generated code is current and complete.

---

## The SDK (211)

| Area | Tests | What they prove |
|---|---:|---|
| The facade and the client | 32 | `initialize` once (the first wins, a second isn't validated, two at once share one start); early calls replayed in order with their own times, up to 100; calls ignored after `shutdown`, which waits for a start or an upload in flight; `instance` and `debug` before start; the scheduler wired in; a database that can't open running in memory; an error inside a call logged, never thrown; nothing logged without debug mode |
| Config, public API, version | 19 | Every config rule and its message, all broken rules in one error; the key masked in `toString`; the exported names, exactly; an exhaustive `switch` over `FlushResult`; the version in code, `pubspec.yaml` and `CHANGELOG.md` agreeing |
| Recording and identity | 31 | Every validation limit at its edge; stamps (id, UTC time, the identity at the call); one transaction per drain, all or nothing; call order across events and identity changes; the cap (oldest unsent dropped, counted); the anonymous id kept, and rotated by `clearUser` |
| Storage | 29 | Every `CHECK`; the queries (due, earliest retry, counts, newest); the v1 → v2 migration from the exported schema; the mapper |
| Uploads | 42 | Batching (100 events, 5 requests, oldest first); single-flight; atomic claims; expired claims; the error table, kind by kind; success in one transaction; the prune (sent only, after a day); the upload log and its limit; the fake server (latency, failures, the key, JSON round-trip, dedupe, live stats) |
| Retries and scheduling | 25 | The backoff (doubling, capped, no overflow); every trigger (interval, threshold, paused, reconnect, retry due); none offline or after a 401; the retry timer only for a time ahead; the lifecycle with and without a binding; the network monitor (the first value, a change right after start) |
| Background | 13 | The dispatcher's function on a real database (a fake `workmanager` boundary): backoff respected, offline, a corrupt config, a database that won't open; the saved config; two uploaders on one database never sending the same event; registration on, off, and on a platform that can't |
| Debug tools and screen tracking | 20 | Live stats (counts, identity, next retry, last upload, online, uploading), listened to more than once; recent events; the upload log; `retryFailed`; `combineLatest3`; the navigator observer (push, pop, replace; first routes, popups and unnamed routes skipped; a host's names) |

## The sample (178)

| Area | Tests | What they prove |
|---|---:|---|
| Accessibility tour | 29 | Every screen and state (Profile signed in, the Dashboard after failures), light and dark, at 200 % text: no overflow, tap targets ≥ 48 × 48, a label on everything tappable, text contrast |
| App flows | 13 | The real SDK end to end on an in-memory database: Buy → the Dashboard shows it → Flush → Sent; a failing server, Retry failed after the sixth server error; Track 100 events uploading by itself; Device offline and the reconnect; screen tracking (`shop`, `product`, `shop`); sign in and out |
| Design system | 43 | Both themes; every status color at WCAG AA, in both; the large-text rule; segments stacking at large text; money |
| Navigation and shell | 12 | Typed locations, the tabs, the product inside Shop; named routes; tab tracking |
| Adapters | 19 | `TrackLiteAnalyticsService`, `TrackLiteAnalyticsDebug`, `FakeServerDemo`, `DemoNetworkMonitor`, field by field |
| Cubits | 19 | Home, Product, Profile, Dashboard: what each tracks, in what order (identify before `signed_in`, `signed_out` before reset), the Dashboard's combined state and one-time effects |
| Views | 36 | Every screen in every state with `MockCubit`: the Dashboard's sections, its words, the event chip under the name at large text |
| Domain, DI, boundary | 7 | The catalog; the real DI graph builds; **only the adapters, DI and `main` import `package:tracklite`** |

---

## How the tests are built

**In the SDK** (`packages/tracklite/test/helpers/`):
- **`openTestClient` and `testConfig`:** a real client on an in-memory database, with an instant server, a `FakeNetworkMonitor` and background uploads off.
- **`ScriptedTransport`:** answers each upload with the next scripted outcome (a response or a `TransportException`), and can hold a request at a gate, to test what happens *during* an upload.
- **`FakeAppLifecycle`, `FakeBackgroundUploads`:** the lifecycle and `workmanager` at the boundary.
- **Time and ids:** a `Clock` the test moves (`testNow`), `SequentialIds`, and `fake_async` for the scheduler's timers.
- **`LogRecorder`:** captures what the SDK would log, so a test can check a warning.

**In the sample** (`sample_app/test/helpers/`):
- **Fakes of the app's ports:** `RecordingAnalytics` (with `Tracked` values compared by `mapEquals`), `FakeAnalyticsDebug`, `FakeDemoBackend`, `FakeDeviceNetwork`.
- **`pumpSample`:** the real composition root, with `startSdk` (the real SDK on an in-memory database, `TrackLiteTesting.disableTimers()`), `testServer` and `testDevice`.
- **Views:** `MockCubit` from `bloc_test`, one state per test; a tall surface where a lazy list must build everything.
- **Flows:** a 5000 × 3 surface; `settleStorage` gives drift's writes real time (`runAsync`) between frames.

**What the SDK offers a host's tests** (`package:tracklite/testing.dart`): `TrackLiteTesting.useInMemoryDatabase()`, `TrackLiteTesting.disableTimers()` and `FakeNetworkMonitor`. The sample's own tests use them, so they are tested as a host would use them.

---

## Mutation checks

Every phase broke its key rules on purpose, one at a time, and ran the whole suite: a rule the tests don't catch isn't tested. **236 checks over six phases; 235 caught, and one equivalent.** The equivalent one is "the upload doesn't wait for the recorder": drift runs one statement at a time, so the claim queues behind the write anyway. The wait stays, as the rule the code promises, with a comment.

| Phase | Checks | Misses at first, and what changed |
|---|---:|---|
| 1 — Foundation | 28 | two facade guards each hid the other's removal (the start is shared by construction now); a SnackBar test that sent the same state twice; one mutation rewritten |
| 2 — Event storage | 47 | "no transaction" (a drift `batch` is atomic by itself: the test now fails a meta write in the same drain); "`flush()` doesn't wait for the writes" (a read queued behind the write: the test checks nothing is pending) |
| 3 — The pipeline | 43 | the upload log's limit; `sent` read from the kept rows; `flush()` respecting backoff; the equivalent one; two retargeted (formatting) |
| 4 — Retries, background | 50 | the earliest retry time (one retry time can't tell earliest from latest); the background runner's catch-all; the no-binding fallback (tested only in the sample); three retargeted |
| 5 — Dashboard, tools | 44 | `retryFailed` keeping the attempts or the wait (the failed events came from a 400); the earliest retry and the newest upload in the stats; the stats not watching the log; an empty route name; one retargeted at the generated routes |
| 6 — Final pass | 24 | the prune deleting old **unsent** events (no test had one older than a day); the segments not stacking at large text |

The full lists are in each phase's summary. Phase 6 re-checked the key rules against the finished suites:

- **Stored first:** the cap dropping the newest; one event over the cap kept; sign out keeping the anonymous id; the key printed in full.
- **Uploads:** a claim taking `sending` events too; a claim ignoring backoff; newest first; expired claims never released; the prune deleting unsent events; the uploader trying offline; the server not deduplicating.
- **Retries:** unreachable counting an attempt; a 401 not pausing; a 400 retried; `maxRetries` off by one; the backoff not doubling; the backoff uncapped.
- **Scheduling:** the threshold one batch late; no upload on the way to the background; the first online value taken as a reconnect; the scheduler asking while offline.
- **The sample:** a Cubit importing the SDK; the event chip beside the name at large text; the segments at large text.

---

## Proving a new test can fail

Break the rule it guards (in the code, not the test), run it, and see it fail; then put the rule back. A test that can't fail documents nothing.
