# Phase 4 — Retry + Background Uploads

## Phase Goal

Until Phase 3, events left the phone only when the app called `flush()`, and a failure simply put them back. Phase 4 makes the SDK look after itself:
- **retries with exponential backoff,** with a precise rule for what counts as an attempt and what happens after the last one;
- **network awareness:** offline, nothing is attempted, and the reconnect sends what waited;
- **automatic triggers,** so a host app never has to call `flush()`;
- **background uploads** with `workmanager`, so events leave even when the app isn't running;
- **two isolates on one database** (the app and the background task) without sending anything twice.

---

## What Was Implemented

- **`RetryPolicy`** (public):
  - `delayAfter(attempt)` is `base × 2^(attempt−1)`, capped at `maxDelay` (1 minute doubling, an hour at most by default);
  - pure, total, and safe from overflow at any attempt;
  - its rules are reported by the config.
- **The error table**, applied by `UploadManager`:

  | Error | The events | Attempts |
  |---|---|---|
  | unreachable | back to `pending`, due as before | not counted |
  | 5xx | `pending` until `now + delayAfter(attempts)`; past `maxRetries`, `failed` | +1, per event |
  | 401 | back to `pending`; automatic uploads pause until the next `initialize` | not counted |
  | 400 | `failed` at once | — |

  Each event waits its own backoff: one retried before waits longer than one sent for the first time.
- **`NetworkMonitor`** (public):
  - `ConnectivityNetworkMonitor` (`connectivity_plus`, the default), and `FakeNetworkMonitor` (in `testing.dart`);
  - `TrackLiteConfig.networkMonitor`;
  - offline, `upload()` returns `Offline` at once. A manual flush offline is logged; an automatic trigger offline isn't even asked for.
- **`UploadScheduler`:**
  - `interval` (every `flushInterval` in the foreground);
  - `threshold` (a write leaves a full batch due);
  - `paused` (the app goes to the background);
  - `reconnect` (the monitor's `false → true`);
  - `retryDue` (one timer for the earliest retry, re-armed after each run).

  None runs while offline or while the API key is rejected. It follows the lifecycle through `AppLifecycle` (`AppLifecycleListener`), which falls back to "always in the foreground" when there is no widgets binding.
- **Background uploads:**
  - `WorkmanagerUploads` registers a periodic task, `dev.tracklite.upload` (15 minutes, with a network, no initial delay), or cancels it when `backgroundUploads` is false;
  - the SDK's own `@pragma('vm:entry-point')` dispatcher;
  - `runBackgroundUpload()` opens the database, reads the config `initialize` saved in `meta` (`encodeConfig` / `decodeConfig`), uploads once respecting backoff, and closes;
  - **`TrackLite.runBackgroundUpload()`** is public, for hosts with their own dispatcher;
  - **the database opens with `shareAcrossIsolates`.**
- **The client:** owns the monitor (when it's the default), the scheduler, the lifecycle and the background registration (logged, never thrown), and shuts them all down.
- **`TrackLiteTesting.disableTimers()`:** a host's widget tests fail on a pending timer, and the SDK outlives the widget tree. Without timers, the event triggers still work.
- **The sample:**
  - **`DemoNetworkMonitor`** (data): the device's connectivity plus the Dashboard's **Device offline** switch, given to the SDK as its monitor and to the Dashboard as the `DeviceNetwork` port;
  - **the Dashboard's Network section:** Online, Offline (simulated) or Offline: no connection, and an adaptive switch;
  - **the iOS host setup:** `BGTaskSchedulerPermittedIdentifiers`, `UIBackgroundModes: fetch`, and `AppDelegate` registering the task and the plugins for the background engine;
  - `main()` builds the graph before `initialize`, so the SDK can get the app's monitor.

---

## SDK Concepts Demonstrated

- **Exponential backoff protects the server.** When it fails, every phone retries, and a fixed delay would make them all come back together, keeping it down. Doubling waits (1, 2, 4… minutes, capped) spread the load out as the failure lasts.
- **What counts as an attempt is a design decision.**
  - A 5xx means the server saw the batch and failed: count it.
  - Unreachable means the server never saw it: five network blips must not use up an event's retries.
  - A 401 is the app's configuration, not the event's fault: don't count it, and pause, since every automatic upload would get the same answer.
  - A 400 is final.
- **A dead state that keeps the data.** Past `maxRetries`, an event is `failed`: it leaves the queue's flow but stays in the database with its last error. "Retry failed" (Phase 5) can revive it.
- **An explicit flush ignores backoff;** automatic triggers respect it. The developer who asked "now" means now.
- **Triggers a host never writes:**
  - an interval in the foreground, and a full batch;
  - the app going to the background (the last chance before the OS may kill it);
  - the reconnect, and the earliest retry.

  All of them only *ask*: the uploader is single-flight, so triggers that pile up join one run.
- **A timer never fires "at once" for a time already past.** An unreachable server keeps an event's retry time (no attempt counted). Re-arming immediately for it would loop as fast as the uploads failed. The test suite found it (see Notes).
- **Network awareness is an interface.** The SDK uses `connectivity_plus` by default, but a host can pass its own monitor: the sample adds a demo switch, a host could add a reachability check. A connection isn't proof of the internet; an upload that fails then is "unreachable", which costs nothing.
- **Background work as an SDK:**
  - The SDK owns its dispatcher.
  - Only one `workmanager` dispatcher can exist per app, so a host that has one turns `backgroundUploads` off and calls `TrackLite.runBackgroundUpload()` from its own.
  - The background isolate starts with nothing, so `initialize` saves what it needs (the API key, batch size, retry policy) in the database.
  - Objects can't cross isolates, so the background uses the default transport and monitor.
- **Two isolates, one database.**
  - `shareAcrossIsolates` serializes both through one connection.
  - Claims (Phase 3) keep them from sending the same event: tested with two uploaders on one file, 100 events, each sent once.
- **Never fail the host, at any layer:**
  - no plugin (a test, an unsupported OS) means online and a logged warning;
  - no widgets binding means "always in the foreground" with a warning;
  - a failing background registration is logged.
- **A testing switch for what an SDK does that widget tests reject:** periodic timers that outlive the widget tree.

---

## Flutter / Dart Concepts Demonstrated

- **`workmanager`:**
  - `initialize(dispatcher)`, and `registerPeriodicTask` with `Constraints(networkType: connected)` and `ExistingPeriodicWorkPolicy.update`;
  - `cancelByUniqueName`;
  - `executeTask` in a `@pragma('vm:entry-point')` top-level function;
  - on iOS, `WorkmanagerPlugin.registerPeriodicTask` and `setPluginRegistrantCallback` in `AppDelegate`.
- **`AppLifecycleListener`** (`onResume`, `onPause`), behind an interface so tests and pure-Dart contexts don't need the binding.
- **`connectivity_plus` 7** (a list of results) and its platform interface, scripted in tests (§11.92).
- **"The current value, then changes" without `async*`.** A generator (`yield current; yield* changes;`) subscribes to `changes` only after its first value is delivered: a change in between is lost, and cancelling it while it waits in `await for` can hang. A `StreamController` subscribing in `onListen` has neither problem (`startWith`).
- **drift's `shareAcrossIsolates`** (`DriftNativeOptions`), and two `NativeDatabase` connections on one file in a test.
- **Scheduler tests in fake time with plain callbacks** (`fakeAsync`, `async.getClock`, `pendingTimers`): no database, so no fake-time drift traps.
- **Private named parameters** for the scheduler's and uploader's dependencies.

---

## Event Flow

```
Foreground (UploadScheduler, started by initialize):
  every 30 s ───────────────┐
  a write leaves 20 due ────┤
  app → background ─────────┤  offline? key rejected? → skip
  monitor false → true ─────┤
  earliest retry time ──────┘
        → UploadManager.upload(trigger)   (respects backoff; single-flight)
             └─ for a 5xx: each event: attempts + 1 → pending until now + 1, 2, 4… min (cap 1 h)
                                             → failed past maxRetries
        → re-arm the retry timer (only for a time still ahead)

Background (WorkManager / BGTaskScheduler, ~15 min, with a network):
  trackLiteBackgroundDispatcher → runBackgroundUpload()
     → open tracklite.sqlite (shared across isolates) → read meta.background_config
     → a client with no scheduler → upload(background) → close

TrackLite.flush()  → upload(manual, ignoreBackoff: true)
```

---

## Important Files Added

| Path | Purpose |
|---|---|
| `packages/tracklite/lib/src/retry/retry_policy.dart` | Exponential backoff, pure |
| `packages/tracklite/lib/src/connectivity/network_monitor.dart` | `NetworkMonitor`, `ConnectivityNetworkMonitor`, `FakeNetworkMonitor`, `startWith` |
| `packages/tracklite/lib/src/scheduling/upload_scheduler.dart` | The five automatic triggers |
| `packages/tracklite/lib/src/scheduling/app_lifecycle.dart` | Foreground / background, with a fallback |
| `packages/tracklite/lib/src/background/background_uploads.dart` | `workmanager` registration |
| `packages/tracklite/lib/src/background/background_runner.dart` | The dispatcher and one background upload |
| `packages/tracklite/lib/src/background/saved_config.dart` | The config the background task reads back |
| `packages/tracklite/test/scheduling/upload_scheduler_test.dart` | Every trigger in fake time |
| `packages/tracklite/test/background/background_test.dart` | The runner, the saved config, two uploaders on one file |
| `packages/tracklite/test/helpers/fakes.dart` | `FakeAppLifecycle`, `FakeBackgroundUploads` |
| `sample_app/lib/data/analytics/demo_network_monitor.dart` | The device's network plus the demo switch |
| `sample_app/lib/domain/network/device_network.dart` | The Dashboard's network port and model |
| `sample_app/ios/Runner/AppDelegate.swift`, `Info.plist` | The iOS host setup for background uploads |

---

## Important Types Added

| Type | Responsibility | Why there |
|---|---|---|
| `RetryPolicy` | How long to wait after the n-th failure | Public: hosts tune it |
| `NetworkMonitor`, `ConnectivityNetworkMonitor` | Online or not | Public: an extension point |
| `FakeNetworkMonitor` | A monitor set by hand | Public, in `testing.dart` |
| `UploadScheduler` | When uploads run | `src/scheduling`, `@internal` |
| `AppLifecycle`, `FlutterAppLifecycle`, `ForegroundOnly` | The app's foreground state | `src/scheduling`, `@internal` |
| `BackgroundUploads`, `WorkmanagerUploads` | The periodic task | `src/background`, `@internal` |
| `DemoNetworkMonitor` | The demo switch, as a monitor | Sample, data (imports the SDK) |
| `DeviceNetwork`, `NetworkStatus` | The Dashboard's view of it | Sample, domain |

---

## Folder Structure Changes

```
packages/tracklite/lib/src/
├── retry/          retry_policy
├── connectivity/   network_monitor
├── scheduling/     upload_scheduler, app_lifecycle
└── background/     background_uploads, background_runner, saved_config
packages/tracklite/test/  retry/  connectivity/  scheduling/  background/  helpers/fakes.dart
sample_app/
├── lib/domain/network/device_network.dart (+ .freezed)
├── lib/data/analytics/demo_network_monitor.dart
└── ios/Runner/{AppDelegate.swift, Info.plist}   (background task)
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Backoff | 1, 2, 4, 8 min; max retries | the same | the same, capped at an hour; **what counts is defined** (5xx yes, unreachable no, 401 pauses, 400 final) |
| After the last retry | `FAILED` | `failed` | `failed`, kept with its error |
| Network | `NetworkMonitor` + a fake | `NWPathMonitor` + a fake | `NetworkMonitor` over `connectivity_plus`; the host can pass its own |
| Background | WorkManager: `PeriodicWorkRequest` | `BGTaskScheduler` | `workmanager` (both), the SDK's dispatcher, `runBackgroundUpload()` for hosts with their own |
| Manual flush | `OneTimeWorkRequest` | a `Task` | `flush()` directly, ignoring backoff |
| Foreground triggers | — | — | interval, threshold, paused, reconnect, retry due |
| Two processes on the queue | WorkManager uniqueness | the actor | `shareAcrossIsolates` + atomic claims |
| Worker tests | WorkManager test helpers | — | the runner on a real file; the scheduler in fake time |

---

## Interview Notes

**Q: Why exponential backoff instead of retrying every minute?**
A: When a server fails, every client fails at once. With a fixed delay they all retry together, and keep it down. Doubling the wait spreads them out the longer the outage lasts; the cap keeps a long outage from delaying recovery by days.

**Q: Should a network error count as a retry attempt?**
A: Not here. An event that never reached the server isn't a problem event; counting unreachable failures would kill events after a few minutes in a tunnel. Only server errors (5xx) count toward `maxRetries`. A rejected key pauses automatic uploads instead, because every one would fail the same way.

**Q: How does an SDK do background work if the app might have its own `workmanager`?**
A: There can be one dispatcher per app. So the SDK registers its own by default, and offers `backgroundUploads: false` plus `TrackLite.runBackgroundUpload()` for an app that runs its own dispatcher. The background isolate starts empty, so `initialize` saves what it needs in the SDK's database.

**Q: What happens when the background task and the app upload at the same time?**
A: Both open the same database through drift's `shareAcrossIsolates`, which serializes their statements. A claim is one statement, so each uploader gets different events; a test runs two uploaders on one file with 100 events and checks each was sent once.

**Q: How do you test timers without waiting?**
A: The scheduler takes plain callbacks (upload, due count, next retry) and an injected clock. In `fakeAsync`, the test moves time and checks which triggers asked for an upload, with no database involved. It also checks that `stop` leaves no pending timer and no listener.

**Q: What did the tests find?**
A: Two real bugs:
- **A retry timer armed for a time already past:** it looped as fast as uploads failed.
- **A "current value, then changes" stream built with `async*`:** it lost a change made right after listening, and could hang on cancel.

Both are fixed, with tests (see Notes).

---

## Learning Checklist

- ✅ A pure, overflow-safe backoff policy
- ✅ The error table: what counts, what pauses, what is final
- ✅ A network monitor as an extension point, with a safe default
- ✅ Five automatic triggers, all respecting backoff and the network
- ✅ Background uploads with `workmanager`, the SDK's dispatcher, and a public entry for hosts
- ✅ The config saved for the background isolate
- ✅ Two isolates on one database, never sending the same event
- ✅ Fallbacks for a missing plugin or binding
- ✅ A testing switch for timers
- ✅ The sample's Device offline switch, through its own monitor and port
- □ The full Dashboard: identity, recent events, the upload log, demo controls (Phase 5)

---

## Future Improvements

- **Phase 5:**
  - `retryFailed()` and the debug streams (recent events, uploads);
  - the stats' next retry, online and uploading;
  - the Dashboard's demo controls (failure rate, latency), sign in and out, and screen tracking.
- **`Retry-After`** on a 429, and jitter on the backoff (for a real backend).
- **A reachability check** (a lightweight request) on top of the connectivity monitor.
- **Reading the background isolate's server stats** in the app: today it has its own fake server (§11.80).

---

## Notes on This Phase

- **Bugs the tests found:**
  - **A retry loop.** `_armRetry` armed a timer "at once" for a retry time already past. An unreachable server doesn't move an event's retry time, so every failure re-armed for the same past time, and the loop ran as fast as the uploads failed. In fake time the test hung. The timer is now armed only for a time still ahead; events already due go with the interval or a reconnect.
  - **A lost first change.** Both monitors' `watch()` was `async*` (`yield current; yield* changes;`), which subscribes to the changes only after the first value is delivered. A change made in between, here right after `start()`, was lost, and a cancel could hang. They now use a `StreamController` that subscribes in `onListen` (`startWith`, conventions §11.99).
  - **No binding.** `initialize` threw from `AppLifecycleListener` in a plain `test()`, and would in a host that skipped `ensureInitialized()`. It now logs and assumes the foreground.
- **Spec adjustments:**
  - **The 401 pause is in memory,** not a `meta` row: it lasts until the next `initialize`. A new client, including the background task's, tries again.
  - **`TrackLite.runBackgroundUpload()` returns a `FlushResult`.**
  - **`TrackLiteTesting.disableTimers()` is new:** the sample's widget tests failed on the SDK's 30-second interval timer, which outlives the widget tree.
  - **`FakeNetworkMonitor` joins `testing.dart`.**
- **On the iPhone simulator:**
  - **Device offline:** a tap stayed pending, and Flush now said "You're offline…".
  - **Reconnect:** switching it off sent the tap with no tap on Flush (upload log: `reconnect`, `uploaded`).
  - **Paused:** pressing Home claimed the next tap (`sending`). iOS then suspended the app during the fake server's 800 ms; when the app came back, the upload finished (`paused`, `uploaded`).
  - **The switch** is a native iOS one, and the database opened with isolate sharing.
- **On the Android emulator (Pixel 10 Pro, API 36):**
  - **Registration:** the periodic job was registered. Its first run, right after install, had nothing to send (`background`, `nothing`). A forced run before the next period was declined (§11.66).
  - **The background run:** after resetting WorkManager's database (the memory notes' procedure), the worker ran (`Worker result SUCCESS`). It uploaded the tap that Device offline had kept pending (`background`, `uploaded`), read from the app's database copied off the emulator.
- **Mutation checks:** 50 rules broken on purpose, one at a time.
  - **43 were caught at first.** One more was caught by its timeout: "a past retry fires at once" made the scheduler test loop forever, the very bug it guards.
  - **Three didn't apply:** formatting, and one wrong file. Retargeted, all were caught.
  - **Three were missed, and now have tests:**
    - **the earliest retry time:** read the latest instead. The new test has two retry times to choose between;
    - **the background runner's catch-all:** narrowed to one error type, its only test still passed. A corrupt saved config (a `FormatException`) now must give `Failed` too;
    - **the no-binding fallback:** it was tested only in the sample. The SDK now has a plain `test()` with no binding, in a file of its own, since a `testWidgets` declared anywhere in a file creates the binding.
  - **50 of 50 caught.**
