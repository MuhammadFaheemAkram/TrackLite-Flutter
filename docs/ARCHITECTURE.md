# Architecture

TrackLite is two packages in one **pub workspace**: the SDK (`packages/tracklite`) and a sample app that integrates it (`sample_app`). They follow different rules, because an SDK's choices become every host app's choices.

| | The SDK | The sample app |
|---|---|---|
| Who it's for | other developers, inside their apps | users (a demo) |
| Dependencies | few, with wide caret ranges: `drift`, `drift_flutter`, `uuid`, `clock`, `connectivity_plus`, `workmanager`, `meta` | the usual stack: `flutter_bloc`, `freezed`, `get_it` + `injectable`, `go_router`, `material_ui` |
| DI | none: a hand-written composition root (`TrackLiteClientImpl.open`) | `get_it` + `injectable` |
| Generated code | drift's only, all behind `lib/src/` | routes, states, DI |
| Public surface | one library with `show` lists, plus `testing.dart` | none (an app) |

---

## The layers of the SDK

```
            the host app
                 │  TrackLite.track / setUserId / clearUser / flush / debug
                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│ TrackLite (static facade)  ──▶  TrackLiteClient (interface)          │  public
│                                       ▲                              │
└───────────────────────────────────────┼──────────────────────────────┘
                                        │ implements
┌───────────────────────────────────────┼──────────────────────────────┐
│ TrackLiteClientImpl   (the composition root: builds and owns the rest)│  lib/src/
│                                                                      │  @internal
│   EventValidator ─▶ EventRecorder ─────▶ TrackLiteDatabase (drift)   │
│   IdentityStore ──┘  (serial queue,       events · meta · uploads    │
│                       one transaction        ▲          ▲            │
│                       per drain)             │          │            │
│                                              │          │            │
│   UploadScheduler ──asks──▶ UploadManager ───┘          │            │
│   (interval, threshold,     (single-flight, claims,     │            │
│    paused, reconnect,        batches, the error table,  │            │
│    retry due)                the log)                   │            │
│        ▲      ▲                   │                     │            │
│  AppLifecycle  NetworkMonitor     ▼                     │            │
│                            AnalyticsTransport           │            │
│                            (FakeAnalyticsServer)        │            │
│                                                         │            │
│   DatabaseDebug ── one watched query + online + uploading ───────────┘
│   BackgroundUploads (workmanager) ─▶ trackLiteBackgroundDispatcher   │
└──────────────────────────────────────────────────────────────────────┘
```

**Who knows whom:**
- **The facade** knows only the `TrackLiteClient` interface and how to start one. It buffers calls made before `initialize` finishes (100 events) and replays them with their own times.
- **The client** builds every part, wires them together, and closes them in reverse order at `shutdown`. It is the only class that knows the whole graph. No service locator: the constructors say what each part needs.
- **The recorder** knows the database, never the network. **The uploader** knows the database and the transport, never the UI or the timers. **The scheduler** knows *when*, never *how*: it calls a function (`uploads.upload`) and reads two others (`dueCount`, `nextRetryAt`).
- **The database** knows rows, never public models; mappers turn rows into `TrackLiteEvent` and `UploadRecord`.

Each boundary is an interface or a function, so each part is tested alone with a fake on the other side: `ScriptedTransport`, `FakeNetworkMonitor`, `FakeAppLifecycle`, `FakeBackgroundUploads`, a `Clock`, `SequentialIds`.

---

## The public API

One library, `package:tracklite/tracklite.dart`, exports a fixed list of names with `show`. Everything else is under `lib/src/`, marked `@internal`, so an analyzer warns any app that reaches in. `test/public_api_test.dart` lists the exported names and switches over `FlushResult` with no default, so any change to the API is a change to a test. See [SDK_DESIGN.md](SDK_DESIGN.md).

---

## Storage

Its own SQLite file, `tracklite.sqlite`, never the host's database (drift, schema v2, every version exported in `drift_schemas/` and migration-tested):

| Table | Holds | Notes |
|---|---|---|
| `events` | every event and where it is (`pending`, `sending`, `sent`, `failed`), its attempts, retry time, claim and last error | ordered by `seq` (insertion), never by time; `CHECK`s guard every column; `sent` rows kept 24 h |
| `meta` | the identity, the counters (`tracked_total`, `sent_total`, `dropped_total`, `rejected_total`), the saved config for the background task | counters survive pruning |
| `uploads` | the upload log: trigger, times, outcome, batches, events, error | the newest 100 kept |

Instants are UTC ISO-8601 text ending in `Z` (a `CHECK` enforces it); comparisons use `julianday()`. See [EVENT_PIPELINE.md](EVENT_PIPELINE.md).

---

## Concurrency

Dart runs one isolate's code on one thread, so inside the app the only interleaving is at an `await`. The SDK relies on three rules:

1. **One write queue.** Every change (an event, an identity change, a counter) goes through `EventRecorder`'s queue, in call order. A drain writes everything queued so far in **one transaction**: 100 `track()` calls in a frame are one commit.
2. **One upload at a time.** `UploadManager.upload` keeps the running future; a second caller joins it.
3. **Claims are one statement.** `UPDATE … WHERE seq IN (SELECT … LIMIT n)` marks a batch `sending` with a token. The background task runs in **another isolate**, sometimes while the app is open. With `shareAcrossIsolates`, both reach the file through one shared connection, so their writes are serialized and the app's streams see the background's changes. Two uploaders, in one isolate or two, always claim different events.

---

## The sample app

```
View ─▶ Cubit ─▶ AnalyticsService / AnalyticsDebug / DemoBackend / DeviceNetwork   (domain: the app's ports)
                         ▲
                         │ implements
         TrackLiteAnalyticsService · TrackLiteAnalyticsDebug · FakeServerDemo · DemoNetworkMonitor   (data: adapters)
                         │
                         ▼
                   package:tracklite
```

- **Ports and adapters.** The Cubits depend on the app's own interfaces. The adapters translate SDK types into app types (`QueueStats`, `RecentEvent`, `UploadRun`, `FlushOutcome`). `test/architecture/sdk_boundary_test.dart` fails if anything outside the adapters, the DI module and `main` imports `package:tracklite`.
- **Composition.** `AppModule` registers `TrackLite.instance`, the fake server (so the Dashboard can turn its knobs) and the sample's network monitor (the device's network plus a "Device offline" switch). `main` builds the graph, then calls `TrackLite.initialize` with the same objects.
- **Navigation.** `go_router` typed routes in a `StatefulShellRoute`. The shell tracks tab switches; each branch has a `TrackLiteNavigatorObserver` for the pages pushed inside it.
- **State.** One Cubit per screen with a `freezed` state. The Dashboard's Cubit combines four streams and sends one-time messages as a sealed `DashboardEffect`.

---

## The Flutter edition against the native ones

| Concept | Android | iOS | Flutter |
|---|---|---|---|
| Delivery | a library module | a local Swift Package | a Dart package in a pub workspace |
| Public API | `object TrackLite` | `enum TrackLite` (static) | `abstract final class TrackLite` + a `TrackLiteClient` interface |
| Queue | Room | SwiftData (an actor guards it) | drift, a serial write queue, atomic claims |
| Concurrency | coroutines, a `Mutex` | actors | one isolate's event loop + the serial queue; transactions across isolates |
| Background | WorkManager | `BGTaskScheduler` | `workmanager` (both) |
| Network | `NetworkMonitor` (a fake) | `NWPathMonitor` + a fake | `NetworkMonitor` over `connectivity_plus`; the sample injects a toggle |
| Retry | exponential backoff | the same | the same, with a rule for what counts and a dead state |
| Sample state | ViewModel + StateFlow | `@Observable` | Cubit, behind an `AnalyticsService` port |
| Tests | JUnit, Turbine, MockK, Room, WorkManager tests | Swift Testing, in-memory container | `flutter_test`, `fake_async`, in-memory drift, a public-API test |
| CI | `android-ci.yml` | `ios-ci.yml` | `flutter-ci.yml` (+ `pub publish --dry-run`) |
