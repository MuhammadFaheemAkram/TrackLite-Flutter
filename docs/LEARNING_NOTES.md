# Learning Notes

What building TrackLite taught, phase by phase: the decisions that mattered and the traps that cost time. The Flutter traps are also recorded in the shared conventions (`00-CONVENTIONS.md` §11), with their fixes.

---

## Designing an SDK

- **An SDK has two users,** the developer who integrates it and the person whose phone runs it, and neither can see inside it. So it must never crash the host, never block it, never fill its disk, and never lose data without counting it.
- **The public API is a promise.** One library with `show` lists, `@internal` on everything else, and a test that lists every exported name made each public change a decision. `FlushResult` was complete in Phase 1, before most of its cases could happen: adding a case to a sealed class later breaks every host's exhaustive `switch`.
- **Fail fast for the developer, never for the user.** A bad config throws at `initialize`, in development. A bad event at runtime is refused and counted.
- **Dependencies are the host's too.** Carets on a major, no DI container, no state management, no generated code in the public API, and its own database file.
- **Give the host a seam for everything it may need to replace:** the transport, the network monitor, the retry policy, the background dispatcher. Each one also made the SDK testable.
- **A testing library is part of the API.** A host's widget tests can't open a file and fail on a pending timer, so `testing.dart` offers an in-memory database and a switch for the timers, rather than a test flag in the main API.

---

## Queues and delivery

- **Store first, then send.** Writing the event before anything else is what makes every other guarantee possible: a crash, a kill or no network loses nothing.
- **One transaction per drain.** A microtask drain batches a frame's `track()` calls: 100 events, one commit.
- **Define what counts.** "Retry 5 times" is meaningless until you say what an attempt is. Only a server error counts; a network blip doesn't; a 401 is the key's fault, and a 400 the event's.
- **Bound everything.** The queue (10,000, oldest dropped, counted), the kept `sent` rows (24 h), the upload log (100), the early-call buffer (100). Counters survive the pruning, so totals stay true.
- **Exactly once isn't available over a network.** At least once plus deduplication by id is the honest guarantee, and expiring claims is what makes "at least" real after a crash.
- **One statement claims a batch.** `UPDATE … WHERE seq IN (SELECT … LIMIT n)` is atomic, so two uploaders (two triggers, or the background isolate) never send the same event.
- **Order by insertion, not time.** Two events can share a timestamp, and a device's clock can move back.

---

## Flutter and Dart

- **An `async` function runs synchronously up to its first `await`** (Phase 2): a `validate()` that threw there ran the `finally` before the caller had stored the future, and a failed start stuck forever. Validate before the start exists.
- **`async*` subscribes late** (Phase 4, §11.99): `yield current; yield* changes;` listens to the changes only after the first value is delivered, so a change in between is lost. A `StreamController` that subscribes in `onListen` (`startWith`) doesn't.
- **A combined stream must be broadcast-safe** (Phase 5): the first `combineLatest3` was single-subscription, and a second `watchStats().first` failed. `Stream.multi` with stream factories gives each listener its own sources.
- **Never arm a timer for a time already past** (Phase 4): an unreachable server doesn't move an event's retry time, so "re-arm at once" looped as fast as the uploads failed.
- **`AppLifecycleListener` needs a binding** (Phase 4): a host that skips `ensureInitialized()`, or a plain `test()`, threw. The SDK now logs and assumes the foreground.
- **`@visibleForTesting` is a warning across libraries** (Phase 2), and `pub publish --dry-run` fails on warnings (exit 65). CI on a clean copy found it.
- **drift:**
  - `shareAcrossIsolates` lets the background task's isolate and the app share one connection, so writes are serialized and the app's streams see the background's changes.
  - `julianday()` compares ISO-8601 text instants correctly; a `CHECK` that each ends in `Z` keeps them all UTC.
  - `CHECK` constraints in the table are the last line of defence: a bug fails at the insert, not at every upload.
  - Export every schema version (`make-migrations`) from the first one; a v1 → v2 migration test then comes for free.
- **A record compares its `Map` field by identity** (Phase 1): `expect(list, [('event', {...})])` fails even when equal. A small class with `mapEquals` doesn't.
- **A navigator's first route isn't a navigation** (Phase 5): the observer skips it, and the shell tracks tab switches itself.
- **At large text, a status chip beside a long identifier breaks the word** (Phase 6): `screen_op` / `ened`. The row now puts the chip under the details past the app's 130 % rule.

---

## Background work

- **A periodic task is a request, not a schedule.** WorkManager's minimum is 15 minutes, and iOS decides when (if ever) to run a `BGTaskScheduler` task. Foreground triggers do the real work; the background task is the safety net.
- **The background isolate starts with nothing.** `initialize` saves the config (as JSON in `meta`), and the dispatcher rebuilds a client from it. Objects can't cross into another isolate, so it uses the default transport and monitor: with the fake server, a server of its own, as if the real one had restarted. A real transport would need a factory the background isolate can call (on the [roadmap](ROADMAP.md)).
- **An entry point needs `@pragma('vm:entry-point')`.** Native code starts the dispatcher by name; without the annotation, a release build's tree shaking removes it.
- **One dispatcher per app.** An app that already uses `workmanager` turns the SDK's off and calls `runBackgroundUpload()` from its own.
- **Testing it on Android** needs a debuggable build (`run-as` can't read a release app's database) and patience: a forced run before the period is declined.

---

## Testing

- **Prove each test can fail.** Every phase broke its key rules on purpose, one at a time, against both suites. Most misses were tests that passed by luck:
  - two guards that each hid the other's removal;
  - a drift `batch` that is atomic on its own, so "no transaction" changed nothing visible;
  - a read that queued behind a write anyway;
  - a test with one retry time, so "earliest" and "latest" agreed;
  - failed events that came from a 400, so "keep the attempts" had none to keep.
- **One equivalent mutation, documented:** the upload waiting for the recorder. drift runs one statement at a time, so the claim queues behind the write anyway; the wait stays, as a rule rather than an accident.
- **Fakes at every boundary** (`ScriptedTransport` with a gate, `FakeNetworkMonitor`, `FakeAppLifecycle`, `FakeBackgroundUploads`, a `Clock`, `SequentialIds`) made every rule testable in fake time.
- **The real SDK in the sample's flows.** The sample's app flows run the real SDK on an in-memory database with an instant server, so "Buy → the Dashboard shows it → Flush → Sent" is tested end to end.
- **A test of the wrong client "passed" with nothing recorded** (Phase 5). Check that the thing a test observes is the thing the code uses.
- **Retarget a mutation that didn't apply** instead of dropping it: four were formatting, two were the wrong file (one rule lived in generated code).

---

## Process

- **Read only the native specs, then write a Flutter spec with explicit divergences.** The Android and iOS editions left a dozen things undefined: what counts as an attempt, what happens to `sending` after a crash, whether `flush()` respects backoff, what happens before `initialize`. Deciding each once, in a table, kept six phases consistent.
- **The Dashboard is the debugger.** Building the SDK's debug surface early (Phase 2's live queue) meant every later phase could be checked on a device in seconds.
