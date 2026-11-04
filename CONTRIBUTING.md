# Contributing to TrackLite (Flutter)

Thanks for your interest! TrackLite is a learning-focused reference project for SDK design, so contributions that improve clarity, correctness or teaching value are especially welcome.

## Ground Rules

- Be respectful. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- **The SDK's rules** (`packages/tracklite`):
  - **The public API is a promise.** A new public name goes in `lib/tracklite.dart`'s `show` list *and* `test/public_api_test.dart`, with a doc comment. Everything in `lib/src/` is `@internal`.
  - **`track()`, `setUserId()` and `clearUser()` never throw and never wait.** They validate, stamp, queue and return. Only `initialize` may throw, for a bad config.
  - **Stored first:** every change goes through the recorder's queue, and a drain is one transaction. Nothing reads the network before the event is in the database.
  - **One upload at a time,** and a batch is claimed in **one statement**. Don't split a claim into a `SELECT` then an `UPDATE`.
  - **Nothing leaves silently:** every exit from the queue is `sent` or counted (`rejected`, `dropped`, `failed`).
  - **The error table is the contract** (see [docs/RETRY_STRATEGY.md](docs/RETRY_STRATEGY.md)). A new failure kind needs a row there and a test.
  - **Times are UTC; "now" comes from the injected `Clock`,** never `DateTime.now()`. The queue is ordered by `seq`, never by time.
  - **Dependencies:** few, with a caret on a major. No DI container, no state management, no generated code in the public API. Explain any new one in the README's tech stack.
  - **Silent without `debugMode`.** Never log the API key.
- **The sample's rules** (`sample_app`):
  - **Cubits depend on the app's ports** (`AnalyticsService`, `AnalyticsDebug`, `DemoBackend`, `DeviceNetwork`), never on `package:tracklite`. Only the adapters in `data/`, the DI module and `main` import it (`test/architecture/sdk_boundary_test.dart` checks).
  - **UI:** import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`.
  - **Navigation happens in Views,** through typed routes with names (the SDK's observer tracks them).

## Development Setup

- Install [FVM](https://fvm.app), then run `fvm install`. It reads `.fvmrc`, which pins Flutter 3.47.6.
- iOS needs Xcode. Android needs the Android SDK and Java 17+ (Android Studio's bundled JDK works).
- From the root, `fvm flutter pub get` resolves the whole workspace (one lockfile). Then `cd sample_app && fvm flutter run`.
- **Trying the SDK:** the Dashboard's **Device offline** switch, the demo server's **Failures** and **Speed**, and **Track 100 events** show batching, retries and the reconnect in seconds.
- After changing annotated code (drift, freezed, injectable, typed routes), regenerate it **from the root**:

  ```bash
  fvm dart run build_runner build --workspace
  ```

  Generated files are committed, and CI fails if they are stale or missing.
- **Changing the SDK's database schema:**
  1. Bump `schemaVersion` in `tracklite_database.dart`.
  2. Run `fvm dart run drift_dev make-migrations` in `packages/tracklite`. It exports the new version to `drift_schemas/` and generates the steps and the migration tests.
  3. Write the new step in the migration strategy, and a test that the old data survives.
- **Releasing a new SDK version:** bump `trackLiteVersion` (`lib/src/version.dart`), `pubspec.yaml` and the top of `CHANGELOG.md` together (`test/version_test.dart` checks), and run `fvm flutter pub publish --dry-run`.
- **Before a release:** launch a **release** build once. Tree shaking, and the main manifest's permissions, only show there.

## Coding Conventions

- **Lints:** `fvm flutter analyze` must report **no issues**. The rules are `flutter_lints` plus strict casts, inference and raw types; the SDK adds `public_member_api_docs`.
- **Formatting:** `fvm dart format .` (the tall style).
- **The SDK:** a hand-written composition root (`TrackLiteClientImpl.open`); every part takes what it needs in its constructor, behind an interface or a function, so it can be tested with a fake.
- **The sample:** Pages create and provide a Cubit; Views render state and forward intents; one-time messages are a sealed effect.
- **Accessibility:** every tappable is at least 48 × 48 and has a label, text contrast meets WCAG AA in both themes, and color is never the only signal. Above 130 % text (`context.prefersStackedLayout`), side-by-side layouts stack. The accessibility tour (`test/app/accessibility_tour_test.dart`) checks this, so add new screens and states to it.
- **Comments** explain *decisions*, not obvious code.

## Commits

This project uses **[Conventional Commits](https://www.conventionalcommits.org/)**:

```
<type>(<scope>): <message>
```

Examples: `feat(pipeline): send batches oldest first`, `fix(retry): arm the timer only for a time ahead`, `test(upload): cover a claim that expired`, `docs(sdk): explain the delivery guarantee`.

## Pull Requests

1. Fork the repository and create a topic branch.
2. Make sure analyze, format and both packages' tests pass, and the publish dry run is clean:

   ```bash
   fvm flutter analyze
   fvm dart format --output=none --set-exit-if-changed .
   (cd packages/tracklite && fvm flutter test && fvm flutter pub publish --dry-run)
   (cd sample_app && fvm flutter test)
   ```
3. Update the docs, and the SDK's `CHANGELOG.md` for any change a host would notice.
4. Open a PR with a clear description of the change and its motivation.

## Tests

- **The SDK:** each part alone with fakes at its boundaries (`ScriptedTransport`, `FakeNetworkMonitor`, `FakeAppLifecycle`, `FakeBackgroundUploads`, a `Clock`, `SequentialIds`), on an in-memory database; `fake_async` for timers; `openTestClient` for the client end to end.
- **The sample:** Cubits with `bloc_test` and the fakes of the app's ports; Views with `MockCubit`, one state per test; app flows on the real SDK (`pumpSample`, `startSdk`).
- **Prove a new test can fail:** break the rule it guards and run it.

See [docs/TESTING.md](docs/TESTING.md).
