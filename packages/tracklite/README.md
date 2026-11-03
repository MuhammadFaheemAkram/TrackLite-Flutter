# tracklite

A small analytics SDK for Flutter apps, built to show how an SDK is designed:
- a minimal public API;
- a persistent event queue;
- batched uploads, and retries with exponential backoff;
- background uploads;
- a stated delivery guarantee: at least once.

It talks to a fake analytics server: this is a learning project, not a hosted service.

> **Status: 0.1.0, the API's shape.**
> Calls are accepted and logged in debug mode; storing (0.2.0) and uploading (0.3.0) come next.
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
- **Before `initialize` finishes, and after `shutdown`, calls are ignored** and `flush()` returns `NotInitialized`.
- **Without `debugMode`, the SDK is silent.**

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
