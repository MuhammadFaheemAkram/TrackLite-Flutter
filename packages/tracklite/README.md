# tracklite

A small analytics SDK for Flutter apps, built to show how an SDK is designed:
- a minimal public API;
- a persistent event queue;
- batched uploads, and retries with exponential backoff;
- background uploads;
- a stated delivery guarantee: at least once.

It talks to a fake analytics server: this is a learning project, not a hosted service.

> **Status: 0.3.0, events are uploaded.**
> Every `track()` call is stored in the SDK's own database, and `flush()` sends them in batches. Retries with backoff and automatic and background uploads come in 0.4.0.
> See the [repository](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter) for the plan, the sample app and the design docs.

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

## Uploads

`flush()` sends every pending event to the transport, `batchSize` per request, oldest first, and returns a `FlushResult`:
- **Single-flight:** one upload runs at a time; a flush during one joins it.
- **Atomic claims:** a batch is claimed in one statement (`pending` → `sending`), so two uploaders never send the same event.
- **A failure stops the run and keeps the events:**
  - unreachable, a 5xx and a 401 put the batch back to `pending`;
  - a 400 marks it `failed`;
  - a 401 is reported as `Unauthorized`.
- **At least once:** a claim older than 5 minutes (an upload that died) is sent again, and the server drops duplicates by event id.

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

## Debug tools

```dart
TrackLite.debug.watchStats().listen((stats) {
  // stats.pending, .sent, .failed, .dropped, .rejected, .tracked,
  // stats.userId, stats.anonymousId
});
```

## Testing your app

```dart
import 'package:tracklite/testing.dart';

setUp(() async {
  TrackLiteTesting.useInMemoryDatabase(); // widget tests have no file system
  await TrackLite.initialize(const TrackLiteConfig(apiKey: 'test'));
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
| `backgroundUploads` | true | |
| `debugMode` | false | |

## License

MIT
