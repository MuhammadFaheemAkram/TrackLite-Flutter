# tracklite

A small analytics SDK for Flutter apps, built to show how an SDK is designed:
- a minimal public API;
- a persistent event queue;
- batched uploads, and retries with exponential backoff;
- background uploads;
- a stated delivery guarantee: at least once.

It talks to a fake analytics server: this is a learning project, not a hosted service.

> **Status: 0.6.0, complete:** stored, uploaded in batches, retried with backoff, uploaded in the background; with debug tools and screen tracking.
> The [repository](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter) has the sample app and the design docs: [SDK design](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter/blob/main/docs/SDK_DESIGN.md), [the event pipeline](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter/blob/main/docs/EVENT_PIPELINE.md), [the retry strategy](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter/blob/main/docs/RETRY_STRATEGY.md).

## Usage

```dart
import 'package:tracklite/tracklite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrackLite.initialize(
    const TrackLiteConfig(apiKey: 'demo_key', debugMode: true),
  );
  runApp(const MyApp());
}

// Anywhere in the app:
TrackLite.setUserId('user_123');
TrackLite.track('purchase', properties: {'price': 20, 'currency': 'USD'});
final result = await TrackLite.flush();   // a FlushResult, never an exception
TrackLite.clearUser();
```

**With dependency injection,** register `TrackLite.instance` (a `TrackLiteClient`) and depend on the interface. Your tests can then pass a fake.

## Rules it keeps

- **`track()` returns at once and never throws.** A mistake is logged in debug mode, never thrown at your app.
- **A bad configuration is the one exception:** `initialize` throws an `ArgumentError` naming every broken rule, so you see it in development.
- **After `shutdown`, calls are ignored** and `flush()` returns `NotInitialized` (as it does before `initialize`).
- **Without `debugMode`, the SDK is silent.**
- **Stored first.** Each event is stored, in call order, in the SDK's own `tracklite.sqlite` (a frame's calls in one transaction) before any upload can see it.
- **Invalid events are refused and counted, never thrown.** The limits:
  - a name of 1–64 characters;
  - up to 25 properties, keys of 1–40 characters not starting with `$`;
  - values that are a `String` (≤ 255 characters), a finite `num` or a `bool`.
- **The queue is bounded:** past `maxQueueSize`, the oldest unsent events are dropped, and counted.
- **Calls before `initialize` finishes are kept** (up to 100 events) and replayed with the time they were made.
- **`clearUser()` starts a new anonymous id,** so the next person on the device isn't linked to the last.

## Installation

Add the package. Then, for **background uploads** (on by default, `backgroundUploads: true`):
- **Android:** nothing to add.
- **iOS:** permit and register the task, whose identifier is `dev.tracklite.upload`.
  - In `Info.plist`: `BGTaskSchedulerPermittedIdentifiers` with `dev.tracklite.upload`, and `UIBackgroundModes` with `fetch`.
  - In `AppDelegate`, before launching finishes:

    ```swift
    import workmanager_apple
    // in application(_:didFinishLaunchingWithOptions:)
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "dev.tracklite.upload",
      earliestBeginInSeconds: NSNumber(value: 15 * 60))
    WorkmanagerPlugin.registerLaunchHandlers()
    // where the engine registers its plugins:
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    ```
- **An app that already uses `workmanager`** (one dispatcher per app): set `backgroundUploads: false`, and call `await TrackLite.runBackgroundUpload();` from your dispatcher's periodic task.
- **A real transport** needs `android.permission.INTERNET` in the app's **main** manifest. Debug builds add it on their own, so only a release build would show it missing.

Call `WidgetsFlutterBinding.ensureInitialized()` before `TrackLite.initialize`: the SDK follows the app's lifecycle.

## Uploads

`flush()` sends every pending event to the transport, `batchSize` per request, oldest first, and returns a `FlushResult`:
- **Single-flight:** one upload runs at a time; a flush during one joins it.
- **Atomic claims:** a batch is claimed in one statement (`pending` → `sending`), so two uploaders never send the same event.
- **A failure stops the run and keeps the events:**
  - unreachable, a 5xx and a 401 put the batch back to `pending`;
  - a 400 marks it `failed`;
  - a 401 is reported as `Unauthorized`.
- **At least once:** a claim older than 5 minutes (an upload that died) is sent again, and the server drops duplicates by event id.

**Automatic uploads**, so you never have to call `flush()`:
- every `flushInterval` (30 s) in the foreground;
- when a full batch is waiting;
- when the app goes to the background;
- on reconnect;
- when a retry is due;
- in the background, about every 15 minutes.

**Offline, nothing is attempted.**

**Retries:**
- a server error waits `RetryPolicy` (1, 2, 4… minutes, at most an hour);
- past `maxRetries`, the event is `failed` (kept);
- an unreachable server doesn't count;
- a rejected key pauses automatic uploads until the next `initialize`;
- `flush()` ignores the waits.

The default transport is `FakeAnalyticsServer` (800 ms, 10 % failures). Send elsewhere with your own `AnalyticsTransport`:

```dart
class HttpTransport implements AnalyticsTransport {
  @override
  Future<UploadResponse> upload(UploadBatch batch) async {
    // POST jsonEncode(batch.toJson()) with batch.apiKey in a header;
    // throw ServerUnreachable / ServerFailure / ApiKeyRejected / RequestRejected.
  }
}

await TrackLite.initialize(
  TrackLiteConfig(apiKey: 'key', transport: HttpTransport()),
);
```

## The delivery guarantee: at least once

An event is marked `sent` only after the server accepts it. If the app dies between the two, the batch's claim expires (5 minutes) and it is sent again. So an event is **never lost to a crash, but may arrive twice**: every event carries an `id`, and a backend should keep each id once (the fake server does, and counts the duplicates). See [the pipeline](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter/blob/main/docs/EVENT_PIPELINE.md#the-delivery-guarantee-at-least-once).

**What can leave the queue without being sent, always counted:** an invalid event (`rejected`), the oldest unsent ones past `maxQueueSize` (`dropped`), and events the server refused or that failed more than `maxRetries` times (`failed`, kept until `retryFailed()`).

## Screen tracking

```dart
MaterialApp(navigatorObservers: [TrackLiteNavigatorObserver()]);
// go_router: GoRoute(name: 'product', …) and the route's `observers`.
```

It tracks `screen_opened {screen: <route name>}` for named page routes that are pushed, popped back to or replaced; never their arguments. It skips a navigator's **first** route (a tab, the app's home): switching to an open tab is no navigation, so track those where they're shown.

## Debug tools

```dart
TrackLite.debug.watchStats().listen((stats) {
  // counts: stats.pending, .sending, .sent, .failed, .dropped, .rejected, .tracked
  // identity: stats.userId, stats.anonymousId
  // now: stats.nextRetryAt, stats.lastUpload, stats.isOnline, stats.isUploading
});
TrackLite.debug.watchRecentEvents();   // the newest events, any status
TrackLite.debug.watchUploads();        // the upload log (UploadRecord)
await TrackLite.debug.retryFailed();   // failed events back in the queue
```

## Testing your app

```dart
import 'package:tracklite/testing.dart';

setUp(() async {
  TrackLiteTesting.useInMemoryDatabase(); // widget tests have no file system
  TrackLiteTesting.disableTimers();       // no timer pending when a test ends
  await TrackLite.initialize(
    TrackLiteConfig(
      apiKey: 'test',
      networkMonitor: FakeNetworkMonitor(), // set `.online = false` to go offline
      backgroundUploads: false,             // no workmanager in a test
    ),
  );
});
tearDown(TrackLite.shutdown);
```

Or depend on `TrackLiteClient` (register `TrackLite.instance`) and pass a fake.

## Configuration

| Option | Default | Range |
|---|---|---|
| `apiKey` | required | not blank |
| `batchSize` | 20 | 1–100 |
| `flushInterval` | 30 s | ≥ 1 s |
| `maxRetries` | 5 | 0–20 |
| `maxQueueSize` | 10,000 | ≥ `batchSize` |
| `retry` | `RetryPolicy()`: 1 min, doubling, at most 1 h | `base` > 0, `maxDelay` ≥ `base` |
| `backgroundUploads` | true | |
| `debugMode` | false | |
| `transport` | `FakeAnalyticsServer()` | any `AnalyticsTransport` |
| `networkMonitor` | `ConnectivityNetworkMonitor()` | any `NetworkMonitor` |

`initialize` checks every rule and throws one `ArgumentError` naming each broken one.

## License

MIT
