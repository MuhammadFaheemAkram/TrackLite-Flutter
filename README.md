# 📈 TrackLite

[![Flutter CI](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/MuhammadFaheemAkram/TrackLite-Flutter/actions/workflows/flutter-ci.yml)
![Flutter 3.47.6](https://img.shields.io/badge/Flutter-3.47.6-02569B?logo=flutter)
![Dart 3.13](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A small **analytics SDK for Flutter apps**, and a sample app that integrates it. The goal is the SDK, not an app: a reusable Dart package with a minimal public API, a persistent event queue, batched uploads, retries with backoff and background uploads. It works like a simplified Firebase Analytics, Mixpanel, Amplitude or PostHog SDK.

It runs on **Android and iOS**. There is **no API key and no server**: the SDK talks to a fake analytics server, with a delay, a failure rate and an offline switch.

> **Why this repo exists**
>
> An app is written for its users; an SDK is written for other developers, and it lives inside their apps. That changes the rules:
> - the public API is a promise;
> - every dependency becomes theirs;
> - a crash is theirs;
> - a lost event is invisible.
>
> This project shows those rules applied, one phase at a time.
>
> It is the Flutter edition of an SDK that also exists natively for [Android](https://github.com/MuhammadFaheemAkram/TrackLite) and [iOS](https://github.com/MuhammadFaheemAkram/iTrackLite). Each phase ships with a beginner-to-intermediate friendly write-up in [`docs/`](docs/), which also shows how the Android and iOS editions approached the same step.

---

## 📏 The One Rule

```
An event is written to the SDK's own database before anything else happens.
Nothing is ever deleted until the server has accepted it (or the queue's limits say so, counted).
track() never throws, never blocks, and never awaits the network.
```

---

## 📋 Project Status

The SDK is built in **strict, reviewable phases**. Each phase ends with:
- a building sample app (Android + iOS);
- a clean analyzer and passing tests in both packages;
- a summary doc;
- exactly one commit.

| Phase | Scope | Status |
|------:|-------|:------:|
| 1 | SDK foundation: the workspace, the public API's shape, the config and its rules, the sample app's shell and screens, CI | ✅ Done |
| 2 | Event storage: drift, the queue, validation, the anonymous id, `track()` stores events | ✅ Done |
| 3 | The upload pipeline: the fake server, batching, statuses, at least once | ✅ Done |
| 4 | Retries and background uploads: backoff, the network monitor, the triggers, `workmanager` | ⏳ Next |
| 5 | The debug dashboard and SDK tools: identity, the debug surface, screen tracking | |
| 6 | Documentation & CI | |

---

## 🧩 Using the SDK

```dart
import 'package:tracklite/tracklite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrackLite.initialize(
    const TrackLiteConfig(apiKey: 'demo_key', debugMode: true),
  );
  runApp(const MyApp());
}

TrackLite.setUserId('user_123');
TrackLite.track('screen_opened', properties: {'screen': 'Home'});
TrackLite.track('purchase', properties: {'price': 20, 'currency': 'USD'});
final result = await TrackLite.flush(); // a FlushResult, never an exception
TrackLite.clearUser();
```

The public API is one library, [`package:tracklite/tracklite.dart`](packages/tracklite/lib/tracklite.dart):

| Name | What it is |
|---|---|
| `TrackLite` | The static facade: `initialize`, `track`, `setUserId`, `clearUser`, `flush`, `shutdown`, `instance`, `version` |
| `TrackLiteClient` | The same calls as an interface, for apps with dependency injection (and their fakes) |
| `TrackLiteConfig` | The API key and the options, with their rules checked at `initialize` |
| `TrackLiteEvent`, `EventStatus` | An event as stored, and where it is: `pending`, `sending`, `sent`, `failed` |
| `TrackLiteDebug`, `TrackLiteStats` | The debug tools (`TrackLite.debug.watchStats()`): the queue's counts, the totals, the ids |
| `AnalyticsTransport`, `UploadBatch`, `UploadResponse` | The network boundary: set `TrackLiteConfig.transport` to send to a real backend |
| `TransportException` (`ServerUnreachable`, `ServerFailure`, `ApiKeyRejected`, `RequestRejected`) | Why an upload failed; the kind decides what happens to the batch |
| `FakeAnalyticsServer`, `FakeServerStats` | The default transport: latency, a failure rate, an API key check, deduplication by event id |
| `FlushResult` | What a flush did: `Uploaded`, `NothingToSend`, `Offline`, `Failed`, `Unauthorized`, `NotInitialized` |

A second library, [`package:tracklite/testing.dart`](packages/tracklite/lib/testing.dart), is for an app's tests: `TrackLiteTesting.useInMemoryDatabase()`.

Everything else is in `lib/src/`, marked `@internal`, and out of reach.

**Rules the SDK keeps:**
- **No throws at the host.** `track()`, `setUserId()` and `clearUser()` return at once and never throw; `flush()` reports a result.
- **A bad configuration fails fast.** It is the one exception: `initialize` throws an `ArgumentError` naming every broken rule, in development.
- **Not running, nothing happens.** Before `initialize` and after `shutdown`, calls are ignored and `flush()` says `NotInitialized`.
- **Silent unless asked.** Without `debugMode`, the SDK logs nothing.
- **Stored first** (0.2.0):
  - `track()` validates, stamps and queues; one write queue stores a frame's calls in one transaction, in call order, in the SDK's own `tracklite.sqlite`.
  - An invalid event is refused and counted; past `maxQueueSize`, the oldest unsent are dropped and counted.
- **Early calls kept:** calls made before `initialize` finishes are replayed with their own times (up to 100 events).
- **An identity:** a stored anonymous id; `clearUser()` also starts a new one, so two people on one device aren't linked.
- **Uploaded in batches** (0.3.0):
  - `flush()` sends every pending event, `batchSize` per request, oldest first, one run at a time.
  - A batch is **claimed** in one statement (`pending` → `sending`), so two uploaders never send the same event.
  - A failure stops the run and keeps the events: back to `pending`, or `failed` for a refused (400) batch.
- **At least once:** a claim older than 5 minutes (the app died mid-upload) goes back to `pending` and is sent again; the server drops the duplicates by event id.

---

## ✨ The Sample App (the plan)

- 🏠 **Home:**
  - the screen is tracked when shown;
  - buttons track `button_clicked` and say what they sent.
- 🛍️ **Shop:**
  - four products, each opening a page (screen tracking by the SDK's navigator observer, Phase 5);
  - **Buy** tracks a `purchase` with its id, price and currency.
- 👤 **Profile:** sign in (`setUserId`), sign out (`clearUser`), and the anonymous id.
- 📊 **Dashboard:**
  - **The queue:** pending, sending, sent, failed, dropped and rejected counts.
  - **Uploads:** the last one, the next retry, and an upload log.
  - **Actions:** **Flush now**, **Retry failed**, **Track 100 events**.
  - **Demo controls:** Device offline, the server's failure rate, its latency.
- ♿ **Accessible:** dark mode and large text on every screen; never color alone. A test tour grows with the app and checks both.

After Phase 3, Home's buttons and Buy store their events through the app's own `AnalyticsService` port. The **Dashboard shows the queue live** (the counts by status, the totals, the ids), and **Flush now** sends it to the fake server, saying what happened.

---

## 🧰 Tech Stack

An SDK's dependencies become every host app's dependencies, so **the SDK and the sample follow different rules**:
- the SDK keeps its own list short, with wide version ranges;
- it uses no DI container, no state-management package, and no generated code in its public API;
- the sample app uses the usual stack.

| Area | SDK (`packages/tracklite`) | Sample (`sample_app`) | Since |
|------|----------------------------|-----------------------|:-----:|
| Toolchain | Flutter 3.47.6 · Dart 3.13, pinned with [FVM](https://fvm.app); one **pub workspace** | the same | 1 |
| Public models | hand-written immutable classes; `meta` (`@internal`) | — | 1 |
| The queue | [`drift`](https://pub.dev/packages/drift) + `drift_flutter` (its own `tracklite.sqlite`, schema v1 exported) | — | 2 |
| Ids and time | `uuid` (event and anonymous ids), `clock` (an injected "now") | — | 2 |
| UI | — | [`material_ui`](https://pub.dev/packages/material_ui) (Material 3), `cupertino_ui` | 1 |
| Navigation | — | `go_router` + `go_router_builder` (typed routes, `StatefulShellRoute`) | 1 |
| DI | none: a hand-written composition root | `get_it` + `injectable` | 1 |
| State | — | `flutter_bloc` Cubits, `freezed` states | 1 |
| Formatting | — | `intl` (prices) | 1 |
| Lints / CI | strict analysis + `public_member_api_docs`; `pub publish --dry-run` | strict analysis; `implementation_imports` as an error | 1 |
| Testing | `flutter_test` | `flutter_test`, `bloc_test`, `mocktail` | 1 |

Planned for the SDK: `connectivity_plus`, `workmanager` (Phase 4).

---

## 🏛️ Architecture

```
sample app                                    the SDK (package:tracklite)
──────────                                    ───────────────────────────
View ─▶ Cubit ─▶ AnalyticsService (port)
                        │
                        ▼
           TrackLiteAnalyticsService ──────▶ TrackLiteClient ◀── TrackLite (static facade)
             (the adapter, data layer)              │
                                                    ▼
                                         EventRecorder ─▶ drift queue ─▶ UploadManager ─▶ AnalyticsTransport
                                         (validate, one     (tracklite     (claim, batch,    (FakeAnalyticsServer)
                                          transaction        .sqlite)       sent / back to
                                          per frame)            │           pending, log)
                                                                └─▶ TrackLite.debug.watchStats() ─▶ the Dashboard
```

- **The sample's Cubits never import the SDK.** They talk to `AnalyticsService`, the app's own port; one adapter implements it with TrackLite. A test checks that only the wiring imports `package:tracklite`.
- **The SDK has one public library** with `show` lists. A test checks the exported names, and switches over `FlushResult` with no default, so a change to the API is a visible change to a test.

```
TrackLite/                     # the repo root: a pub workspace (one lockfile)
├── packages/tracklite/        # THE SDK
│   ├── lib/tracklite.dart     # the public API (show lists)
│   ├── lib/testing.dart       # the second public library, for apps' tests
│   ├── lib/src/               # everything else: the facade, client/, config/, model/, recording/, storage/, identity/, debug/, testing/, util/
│   ├── drift_schemas/         # every schema version, kept to migrate from
│   ├── example/main.dart      # the snippet pub.dev shows
│   └── README.md  CHANGELOG.md  LICENSE
├── sample_app/                # THE SAMPLE (a normal app)
│   └── lib/
│       ├── app/  core/{design_system,navigation,common}  di/
│       ├── domain/            # AnalyticsService (the port), Product, ProductCatalog
│       ├── data/              # TrackLiteAnalyticsService (the adapter)
│       └── features/          # shell, home, shop, product, profile, dashboard
├── analysis_options.yaml      # one set of rules (the SDK adds its own)
└── .github/workflows/flutter-ci.yml
```

**Navigation (sample):**

```
GoRouter (initialLocation: /home)
  └─ tab shell   StatefulShellRoute ── MainShell (NavigationBar)
                   /home · /shop (→ /shop/:productId, inside the tab) · /profile · /dashboard
```

---

## ▶️ How to Run

Prerequisites:
- [FVM](https://fvm.app);
- Xcode, for iOS;
- the Android SDK, with Java 17+ (Android Studio's bundled JDK works).

```bash
fvm install                       # the version pinned in .fvmrc (3.47.6)
fvm flutter pub get               # at the root: resolves the SDK and the sample together
cd sample_app && fvm flutter run  # pick an Android emulator or an iOS simulator
```

Generated code (`*.g.dart`, `*.freezed.dart`, `*.config.dart`) is committed. After changing annotated code, regenerate it from the root:

```bash
fvm dart run build_runner build --workspace
```

---

## ✅ Testing

```bash
fvm flutter analyze                                    # the whole workspace
fvm dart format --output=none --set-exit-if-changed .
(cd packages/tracklite && fvm flutter test)            # the SDK
(cd sample_app && fvm flutter test)                    # the sample
(cd packages/tracklite && fvm flutter pub publish --dry-run)
```

**263 tests** after Phase 3:
- **The SDK (140):**
  - **the config's rules,** including the transport;
  - **the database:** each `CHECK`, `seq` order, dropping the oldest unsent, the counters; **claims** (atomic, the limit, a second claim gets the rest, retries that wait), expired claims, outcomes and pruning, the upload log's limit;
  - **every schema upgrade path,** and v1 → v2 keeping real events;
  - the validator, the recorder (group commit, all or nothing), the identity;
  - **the fake server:** dedupe, latency in fake time, unreachable, the key check, the batch limit, a seeded failure rate, the JSON body;
  - **the uploader:**
    - 100 events in 5 batches, oldest first;
    - each failure kind and its effect;
    - a partial run;
    - a crash after the server stored a batch (resent, deduplicated);
    - single-flight;
    - pruning and the log;
    - a database failing mid-run;
  - the client, the facade (early calls, starts), the public API's exact names, the version.
- **The sample (123):**
  - the theme, routes and navigation;
  - the Cubits and views;
  - **the adapter,** mapping every `FlushResult`;
  - the flush wording;
  - **the real SDK in memory:** a purchase stored, flushed to the server, then shown as sent; a failing server keeping it pending;
  - the SDK boundary, and the accessibility tour.

CI runs on every push to `main` and every pull request:
- the FVM-pinned Flutter;
- generated code up to date and complete;
- format and analyze;
- each package's tests;
- **`pub publish --dry-run`:** a warning fails it (exit code 65).

---

## 📱 Same SDK on Other Platforms

| Edition | Stack | Repo |
|---------|-------|------|
| Android | Kotlin · a library module · Room · WorkManager · Compose sample | [MuhammadFaheemAkram/TrackLite](https://github.com/MuhammadFaheemAkram/TrackLite) |
| iOS | Swift 6 · a local Swift Package · SwiftData · actors · SwiftUI sample | [MuhammadFaheemAkram/iTrackLite](https://github.com/MuhammadFaheemAkram/iTrackLite) |
| **Flutter** | Dart · a package in a pub workspace · drift · Cubit sample | this repo |

| Concept | Android | iOS | Flutter |
|---|---|---|---|
| Delivery | a library module | a local Swift Package | a Dart package in a pub workspace |
| Public API | `object TrackLite` | `enum TrackLite` (static) | `abstract final class TrackLite` + a `TrackLiteClient` interface |
| Hiding internals | `internal` | `internal` | `lib/src/` + `show` lists + `@internal` |
| The queue | Room | SwiftData (an actor guards it) | drift, a serial write queue (one transaction per frame) |
| Uploads | `FakeAnalyticsApi`, batches | `FakeAnalyticsService`, batches | `AnalyticsTransport` + `FakeAnalyticsServer`; atomic claims, at least once, dedupe by id |
| Sample state | ViewModel + StateFlow | `@Observable` | Cubit, behind an `AnalyticsService` port |
| CI | `android-ci.yml` | `ios-ci.yml` | `flutter-ci.yml` (+ `pub publish --dry-run`) |

The full table (the queue, concurrency, background work, retries) grows with the phases.

---

## 📚 Documentation

- [Phase 1 — SDK Foundation](docs/PHASE_1_SUMMARY.md)
- [Phase 2 — Event Storage Layer](docs/PHASE_2_SUMMARY.md)
- [Phase 3 — Analytics Processing Pipeline](docs/PHASE_3_SUMMARY.md)
- The SDK's own [README](packages/tracklite/README.md) and [CHANGELOG](packages/tracklite/CHANGELOG.md)

---

## 🗺️ Roadmap

The phases above. Ideas after them (a real HTTP transport, opt-out and consent, sessions, sampling) are collected in `docs/ROADMAP.md` in Phase 6.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse
