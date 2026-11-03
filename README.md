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
| 2 | Event storage: drift, the queue, validation, the anonymous id, `track()` stores events | ⏳ Next |
| 3 | The upload pipeline: the fake server, batching, statuses, at least once | |
| 4 | Retries and background uploads: backoff, the network monitor, the triggers, `workmanager` | |
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
| `FlushResult` | What a flush did: `Uploaded`, `NothingToSend`, `Offline`, `Failed`, `Unauthorized`, `NotInitialized` |

Everything else is in `lib/src/`, marked `@internal`, and out of reach.

**Rules the SDK keeps from version 0.1.0:**
- **No throws at the host.** `track()`, `setUserId()` and `clearUser()` return at once and never throw; `flush()` reports a result.
- **A bad configuration fails fast.** It is the one exception: `initialize` throws an `ArgumentError` naming every broken rule, in development.
- **Not running, nothing happens.** Before `initialize` and after `shutdown`, calls are ignored and `flush()` says `NotInitialized`.
- **Silent unless asked.** Without `debugMode`, the SDK logs nothing.

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

In Phase 1, Home's buttons and Buy already send their events, through the app's own `AnalyticsService` port; the SDK logs them in debug builds.

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
| UI | — | [`material_ui`](https://pub.dev/packages/material_ui) (Material 3), `cupertino_ui` | 1 |
| Navigation | — | `go_router` + `go_router_builder` (typed routes, `StatefulShellRoute`) | 1 |
| DI | none: a hand-written composition root | `get_it` + `injectable` | 1 |
| State | — | `flutter_bloc` Cubits, `freezed` states | 1 |
| Formatting | — | `intl` (prices) | 1 |
| Lints / CI | strict analysis + `public_member_api_docs`; `pub publish --dry-run` | strict analysis; `implementation_imports` as an error | 1 |
| Testing | `flutter_test` | `flutter_test`, `bloc_test`, `mocktail` | 1 |

Planned for the SDK: `drift`, `uuid`, `clock` (Phase 2); `connectivity_plus`, `workmanager` (Phase 4).

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
                                         EventRecorder ─▶ drift queue ─▶ UploadManager ─▶ fake server
                                                         (Phase 2)        (Phase 3–4)
```

- **The sample's Cubits never import the SDK.** They talk to `AnalyticsService`, the app's own port; one adapter implements it with TrackLite. A test checks that only the wiring imports `package:tracklite`.
- **The SDK has one public library** with `show` lists. A test checks the exported names, and switches over `FlushResult` with no default, so a change to the API is a visible change to a test.

```
TrackLite/                     # the repo root: a pub workspace (one lockfile)
├── packages/tracklite/        # THE SDK
│   ├── lib/tracklite.dart     # the public API (show lists)
│   ├── lib/src/               # everything else: tracklite.dart (the facade), client/, config/, model/, util/
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

**132 tests** after Phase 1:
- **The SDK (39):**
  - every config rule, just inside and just outside; all broken rules named at once; the API key masked in `toString`;
  - the facade before `initialize`, during it, twice (even with a bad config: ignored), at once (the first config wins), and after `shutdown`;
  - the client's logging (and its silence without debug mode), errors caught rather than thrown;
  - the event's value equality;
  - **the public API:** the exact exported names, each one used as a host would, an exhaustive switch over `FlushResult`;
  - the version, the same in the code, the pubspec and the changelog.
- **The sample (93):**
  - the theme and the status colors (each AA on every surface, in both themes);
  - typed routes;
  - navigation on the real DI graph (tabs, a product inside Shop, links, "Product not found", "Page not found");
  - the Cubits (`bloc_test`) and views (`MockCubit`), the adapter against a fake SDK client;
  - flows from tap to tracked event;
  - **the SDK boundary:** only the wiring imports `package:tracklite`;
  - **the accessibility tour:** every screen and state, light and dark, 200 % text.

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
| Sample state | ViewModel + StateFlow | `@Observable` | Cubit, behind an `AnalyticsService` port |
| CI | `android-ci.yml` | `ios-ci.yml` | `flutter-ci.yml` (+ `pub publish --dry-run`) |

The full table (the queue, concurrency, background work, retries) grows with the phases.

---

## 📚 Documentation

- [Phase 1 — SDK Foundation](docs/PHASE_1_SUMMARY.md)
- The SDK's own [README](packages/tracklite/README.md) and [CHANGELOG](packages/tracklite/CHANGELOG.md)

---

## 🗺️ Roadmap

The phases above. Ideas after them (a real HTTP transport, opt-out and consent, sessions, sampling) are collected in `docs/ROADMAP.md` in Phase 6.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse
