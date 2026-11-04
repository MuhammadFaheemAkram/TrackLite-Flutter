# SDK Design

An app is written for its users. An SDK is written for other developers, and it runs inside their apps, where they can't see it and can't fix it. Every rule below follows from that.

---

## The public API, and why it's small

```dart
await TrackLite.initialize(const TrackLiteConfig(apiKey: 'demo_key'));
TrackLite.track('purchase', properties: {'price': 20, 'currency': 'USD'});
TrackLite.setUserId('user_123');
TrackLite.clearUser();
final FlushResult result = await TrackLite.flush();
await TrackLite.shutdown();
```

That is the whole everyday API: six calls. The rest is for integrators: `debug` (the debug tools), `instance` (the client, for DI), `version`, `runBackgroundUpload()`, the navigator observer, and the types the calls take and return.

**Every public name is a promise.** Once an app uses it, removing or changing it breaks that app, so a name is public only when an integrator needs it:
- **One library** (`package:tracklite/tracklite.dart`) exports a fixed list with `show`. A second (`package:tracklite/testing.dart`) is for an app's tests.
- **Everything else is in `lib/src/`**, and every declaration there is `@internal`: importing it is an analyzer warning in the host.
- **`public_api_test.dart`** imports only the public library, uses every exported name, and switches over `FlushResult` with no `default`. A name added, removed or renamed is a failing test, so it is always a decision, never an accident.
- **`public_member_api_docs`** is on: every public member has a doc comment.
- **Hand-written models**, with no generated code in the public API: a `freezed` upgrade in the SDK must never become a breaking change for its users.

---

## The facade and the client

| | `TrackLite` (static) | `TrackLiteClient` (interface) |
|---|---|---|
| For | most apps: one line anywhere | apps with dependency injection |
| How | `TrackLite.track(...)` | register `TrackLite.instance`, depend on the interface |
| Tests | `TrackLiteTesting` and an in-memory database | pass a fake client |

The facade is a thin shell over one client:
- **Before `initialize` finishes**, calls are kept (up to 100 events) and replayed in order with the time they were made. A `track()` in `main()` before `await initialize` isn't lost.
- **A second `initialize` is ignored** (not even validated): the first one wins, and every caller awaits the same start.
- **After `shutdown`**, calls are ignored and `flush()` returns `NotInitialized`.

The sample app shows the DI route: its Cubits depend on the app's own `AnalyticsService`, and one adapter implements it with `TrackLiteClient`.

---

## Extension points

| Point | Default | Why an app replaces it |
|---|---|---|
| `TrackLiteConfig.transport` (`AnalyticsTransport`) | `FakeAnalyticsServer` | send to a real backend |
| `TrackLiteConfig.networkMonitor` (`NetworkMonitor`) | `ConnectivityNetworkMonitor` (`connectivity_plus`) | a reachability check of its own, a demo switch, tests |
| `TrackLiteConfig.retry` (`RetryPolicy`) | 1 minute, doubling, at most an hour | a different backoff |
| `TrackLiteConfig.backgroundUploads` | on | the app has its own `workmanager` dispatcher: it calls `TrackLite.runBackgroundUpload()` |
| `TrackLiteNavigatorObserver(client:, screenName:)` | the facade's client, the route's name | DI, or names of its own |

**The transport's contract** is the error table: a transport throws `ServerUnreachable`, `ServerFailure(status)`, `ApiKeyRejected` or `RequestRejected(status, reason)`, and the SDK decides what happens to the batch. A transport that throws anything else is treated as unreachable, logged, and nothing is lost. See [RETRY_STRATEGY.md](RETRY_STRATEGY.md).

---

## Errors: the developer's and the device's

| Kind | Example | What the SDK does |
|---|---|---|
| **A developer's mistake, found at start** | `batchSize: 0`, a blank key | `initialize` throws one `ArgumentError` naming every broken rule. It fails in development, never on a user's phone. |
| **A developer's mistake, at a call** | an event name of 70 characters, a `DateTime` property | refused, counted (`rejected`), and logged in debug mode. Never thrown. |
| **The device's problem** | no network, a full disk, a server error, a killed app | handled: kept, retried, counted, logged. `flush()` reports a `FlushResult`. |

`track()`, `setUserId()` and `clearUser()` are synchronous `void` methods: they validate, stamp and queue, then return. They never throw and never wait for the disk or the network. **An analytics SDK must never be the reason an app crashes or stutters.**

Without `debugMode`, the SDK logs nothing. With it, every call and decision goes to `dart:developer`'s log under the name `TrackLite`, at the `logging` package's levels (FINE, WARNING, SEVERE). The API key is masked in `TrackLiteConfig.toString()`, so a config printed in a crash report doesn't leak it.

---

## Dependencies

Every dependency of the SDK becomes a dependency of every app that adds it, and their versions must agree. So the SDK:
- **keeps the list short:** `drift`, `drift_flutter`, `uuid`, `clock`, `connectivity_plus`, `workmanager`, `meta`;
- **uses carets on a major** (`drift: ^2.35.3`), never pins: the app's lockfile picks the exact versions;
- **uses no DI container and no state-management package:** those are the app's choices;
- **stores in its own file** (`tracklite.sqlite`): never the app's database, never its migrations.

The sample app can use anything; it is an app.

---

## Versioning

- **Semantic versioning.** Before 1.0.0, each minor version (0.1.0 → 0.6.0) was one phase of the build.
- **The version is one constant**, `trackLiteVersion` in `src/version.dart`, exposed as `TrackLite.version` and sent with every batch (`UploadBatch.libraryVersion`), so a server can tell which SDK sent what. `version_test.dart` checks that the constant, `pubspec.yaml` and the top of `CHANGELOG.md` agree.
- **`pub publish --dry-run`** runs in CI. A warning fails it (exit code 65), so the package is always publishable.
- **The database schema** has its own version (v2), with every version exported and a migration test from each.

---

## The host's setup

- **Call `WidgetsFlutterBinding.ensureInitialized()`** before `initialize`: the SDK follows the app's lifecycle (an upload when the app goes to the background). Without a binding it falls back to "always in the foreground" and logs a warning.
- **Android:** nothing to add. A real transport needs `android.permission.INTERNET` in the **main** manifest (debug builds add it on their own, so only a release build shows it missing).
- **iOS background uploads:** `BGTaskSchedulerPermittedIdentifiers` with `dev.tracklite.upload` and `UIBackgroundModes` with `fetch` in `Info.plist`, and the task registered in `AppDelegate` (the SDK's README has the code).
- **An app with its own `workmanager`:** a process has one dispatcher. Set `backgroundUploads: false` and call `TrackLite.runBackgroundUpload()` from the app's own periodic task.
- **Tests:** `TrackLiteTesting.useInMemoryDatabase()` (a widget test can't open a file), `TrackLiteTesting.disableTimers()` (a test fails if a timer is pending at its end), `FakeNetworkMonitor`, and `backgroundUploads: false`.
