# Phase 1 — SDK Foundation

## Phase Goal

Lay the ground every later phase builds on, before a single event is stored:
- **the repository's shape:** a pub workspace with two packages, the SDK (`packages/tracklite`) and a sample app that depends on it (`sample_app`), resolved together, analyzed together, tested apart;
- **the SDK's public API, as a promise:**
  - the names a host app can use;
  - the rules it keeps (never throw at runtime; fail fast on a bad config);
  - the tests that make any change to either visible;
- **the sample app's shell:** four tabs, a product inside the Shop tab, the design system with the colors an event's status will use, and an analytics port the screens already call.

Phase 1 stores nothing and sends nothing. What it fixes is the contract: which names exist, what each call promises, and how the sample app reaches the SDK without depending on it.

---

## What Was Implemented

- **The workspace:**
  - a root `pubspec.yaml` with `workspace: [packages/tracklite, sample_app]` (one lockfile, one `.dart_tool/`);
  - `.fvmrc` (3.47.6);
  - one `analysis_options.yaml` (strict casts, inference, raw types; `implementation_imports` and `depend_on_referenced_packages` as errors);
  - `.gitignore`, the MIT license and CI.
- **The SDK package** (`tracklite` 0.1.0):
  - **`lib/tracklite.dart`:** the whole public API, each export with a `show` list.
  - **`TrackLite`**, the static facade:
    - `initialize`: validates, shares one start between concurrent calls (the first config wins), and ignores a second call while running (without validating it);
    - `track`, `setUserId`, `clearUser`, `flush`, `shutdown` (which waits for a start in progress), `instance`, `version`.
  - **`TrackLiteClient`**, the interface the facade forwards to, with `create(config)` as the hand-written composition root.
  - **`TrackLiteConfig`:**
    - the API key, `batchSize`, `flushInterval`, `maxRetries`, `maxQueueSize`, `backgroundUploads` and `debugMode`;
    - `problems` and `validate()` (an `ArgumentError` naming every broken rule);
    - value equality, and a `toString` that masks the key.
  - **`TrackLiteEvent`** and **`EventStatus`** (`pending`, `sending`, `sent`, `failed`), and the six **`FlushResult`** cases.
  - **Internals** (`lib/src/`, `@internal`):
    - `TrackLiteClientImpl`, which logs each call and catches anything thrown inside one;
    - `TrackLiteLogger`, silent without `debugMode`, `dart:developer` otherwise.
  - **Library hygiene:**
    - an `analysis_options.yaml` adding `public_member_api_docs` and `type_annotate_public_apis`;
    - its own README, CHANGELOG and LICENSE;
    - `example/main.dart`;
    - `pub publish --dry-run` clean, with 0 warnings.
- **The sample app** (`tracklite_sample`, app ID `co.bitfuse.flutter.tracklite` on both platforms, "TrackLite"):
  - **The design system:**
    - `AppTheme` from an indigo seed (`#3F51B5`, the fidelity variant);
    - `AppColors`: `pending`, `sending`, `sent`, `failed`, `offline`;
    - tokens, `LoadingView`, `EmptyStateView`, `SectionHeader`, `SegmentedChoice`, `prefersStackedLayout`.
  - **Navigation:**
    - typed routes, with a four-branch `StatefulShellRoute` (`/home`, `/shop` with its child `:productId`, `/profile`, `/dashboard`);
    - "Page not found";
    - re-tapping a tab returns it to its first screen.
  - **The analytics port:**
    - `AnalyticsService` (domain), with `track`, `identify` and `reset`;
    - `TrackLiteAnalyticsService` (data), the adapter;
    - `AppModule` registers `TrackLite.instance`.
  - **Screens:**
    - **Home:** `HomeCubit`, whose three buttons track `button_clicked`.
    - **Shop:** the `ProductCatalog`, four products in code.
    - **Product:** `ProductCubit` (`@factoryParam`). **Buy** tracks `purchase` with `product_id`, `price` and `currency`, and shows a SnackBar.
    - **Profile and Dashboard:** placeholders with their final app bars.
  - **`main.dart`:** `TrackLite.initialize` first, then `configureDependencies()`, then `runApp`.
- **README v1** and this summary.

---

## SDK Concepts Demonstrated

- **The public API is one library.**
  - `lib/tracklite.dart` exports with `show` lists; everything else is in `lib/src/` and marked `@internal`.
  - Dart has no `internal` keyword like Kotlin or Swift. Its convention is `src/`, and the analyzer enforces it with `implementation_imports`.
  - A test lists the exported names, so a new public name is a reviewed change.
- **A facade and a client.**
  - `TrackLite.track(...)` is convenient: any file, no setup.
  - `TrackLiteClient` is injectable: an app with DI registers `TrackLite.instance`, depends on the interface, and its tests pass a fake. The sample's adapter test does exactly that.
- **Two kinds of error.**
  - **A developer's mistake fails fast:** an invalid config throws at `initialize`, with every broken rule named at once.
  - **Everything at runtime is swallowed and logged:** `track()` returns `void` and catches anything thrown inside it; `flush()` returns a result instead of throwing.
  - An analytics SDK that crashes the app it measures is worse than none.
- **Sealed results are part of the API.** An app can switch over `FlushResult` exhaustively, so adding a case later breaks every such app. All six cases exist from 0.1.0, and the public-API test switches over them with no default.
- **The SDK's dependencies are the host's.**
  - The SDK depends on `flutter` and `meta` only: no DI container, no `freezed`, no bloc.
  - Constraints are carets on a major, never pins.
  - A pub workspace is how the sample uses it: one resolution, as a real host would get.
- **Logs are opt-in.** Without `debugMode` the SDK is silent. With it, every call, including one ignored after `shutdown`, leaves a line under "TrackLite".
- **Secrets stay out of logs:** the config's `toString` masks the API key.
- **One version, three places.** `TrackLite.version` is what every upload will report. A test checks it against the pubspec and the changelog's first entry.
- **Publishable from day one.** `pub publish --dry-run` checks the pubspec, the README, CHANGELOG and LICENSE, and the files that would ship. A warning exits with 65, so CI fails on one.

---

## Flutter / Dart Concepts Demonstrated

- **Pub workspaces** (Dart 3.6+):
  - `workspace:` in the root and `resolution: workspace` in each member;
  - `build_runner build --workspace` from the root;
  - each package's own `analysis_options.yaml` including the root's.
- **`@internal`** (`package:meta`): a public class that is not part of the API. The analyzer flags its use from another package, and `public_member_api_docs` doesn't ask for its docs.
- **`abstract final class`** for a static-only facade (no instances, no subclasses); **`abstract interface class`** for the client (hosts may implement it, not extend it).
- **A shared `Future` for concurrent starts:** `_starting ??= create(config)`, so two `initialize` calls at once get one client.
- **The port-and-adapter pattern in a Flutter app.** The Cubits know only `AnalyticsService`. A test reads `lib/` and checks which files import `package:tracklite`.
- **A child route inside a tab:** `/shop/:productId` under `/shop`, so a product opens in the Shop tab and a link to one has the shop underneath. Back always has somewhere to go, so no Close fallback is needed.
- **Value equality for maps in tests:** a record holding a `Map` compares the map by identity. The test recorder's `Tracked` uses `mapEquals`, with an order-independent hash.

---

## Event Flow

```
Home: tap "Share"
  → HomeCubit.tapped(share)
  → AnalyticsService.track('button_clicked', {button: share})      (the app's port)
  → TrackLiteAnalyticsService → TrackLiteClient.track(...)         (the adapter → the SDK)
  → TrackLiteClientImpl: logs 'track("button_clicked", {button: share}) for anon'
                         (stored from Phase 2; uploaded from Phase 3)
```

```
TrackLite.flush()
  ├─ not initialized / shut down → NotInitialized
  └─ running                     → NothingToSend   (no queue yet)
```

---

## Important Files Added

| Path | Purpose |
|---|---|
| `pubspec.yaml` | The workspace: the SDK and the sample, one resolution |
| `analysis_options.yaml` | One set of rules; the SDK boundary as an error |
| `packages/tracklite/lib/tracklite.dart` | The public API, with `show` lists |
| `packages/tracklite/lib/src/tracklite.dart` | The static facade |
| `packages/tracklite/lib/src/client/tracklite_client.dart` | The client interface and its composition root |
| `packages/tracklite/lib/src/client/tracklite_client_impl.dart` | The client (logs, guards every call) |
| `packages/tracklite/lib/src/config/tracklite_config.dart` | The options and their rules |
| `packages/tracklite/lib/src/model/` | `TrackLiteEvent`, `EventStatus`, `FlushResult` |
| `packages/tracklite/lib/src/util/tracklite_logger.dart` | Debug-mode logging |
| `packages/tracklite/analysis_options.yaml` | Docs on every public member |
| `packages/tracklite/{README,CHANGELOG}.md`, `example/main.dart` | What pub.dev would show |
| `packages/tracklite/test/public_api_test.dart` | The exported names and their use |
| `packages/tracklite/test/version_test.dart` | One version in code, pubspec and changelog |
| `sample_app/lib/domain/analytics/analytics_service.dart` | The app's analytics port |
| `sample_app/lib/data/analytics/tracklite_analytics_service.dart` | The adapter to the SDK |
| `sample_app/lib/di/app_module.dart` | Registers `TrackLite.instance` |
| `sample_app/lib/core/design_system/theme/app_colors.dart` | The status colors |
| `sample_app/lib/core/navigation/app_routes.dart` | Typed routes: four tabs, a product |
| `sample_app/lib/features/{home,shop,product,profile,dashboard}/` | The screens |
| `sample_app/test/architecture/sdk_boundary_test.dart` | Only the wiring imports the SDK |
| `.github/workflows/flutter-ci.yml` | Codegen check, format, analyze, both test suites, publish dry run |

---

## Important Types Added

| Type | Responsibility | Why there |
|---|---|---|
| `TrackLite` | The static facade; owns the one running client | The SDK's front door (public) |
| `TrackLiteClient` | The calls as an interface; `create` wires the parts | Public, so hosts can inject and fake it |
| `TrackLiteClientImpl` | Logs each call, ignores calls after shutdown, catches errors | `src/`, `@internal`: free to change |
| `TrackLiteConfig` | Options, rules, masked `toString` | Public: the one place a host configures the SDK |
| `FlushResult` (+ 6) | Every outcome of a flush | Public and sealed: exhaustive for hosts |
| `TrackLiteEvent`, `EventStatus` | An event as stored, and its status | Public: the debug tools will list events |
| `TrackLiteLogger` | Opt-in logs through a sink | `src/`, `@internal` |
| `AnalyticsService` | The app's analytics port | Sample, domain: the app's own words |
| `TrackLiteAnalyticsService` | The port, implemented with the SDK | Sample, data: the only SDK-aware class |
| `HomeCubit`, `ProductCubit` | Buttons and Buy → events | Sample, features |
| `ProductCatalog`, `Product` | The shop's data, in code | Sample, domain |
| `AppColors` | `pending`, `sending`, `sent`, `failed`, `offline` | Sample, design system |

---

## Folder Structure Changes

```
TrackLite/
├── pubspec.yaml  analysis_options.yaml  .fvmrc  LICENSE  README.md
├── .github/workflows/flutter-ci.yml
├── packages/tracklite/
│   ├── lib/tracklite.dart
│   ├── lib/src/{tracklite.dart, client/, config/, model/, util/}
│   ├── example/main.dart
│   ├── test/{config/, client/, model/, public_api_test.dart, tracklite_test.dart, version_test.dart}
│   └── README.md  CHANGELOG.md  LICENSE  analysis_options.yaml  pubspec.yaml
└── sample_app/
    ├── lib/{main.dart, app/, core/{common,design_system,navigation}/, di/, domain/{analytics,shop}/, data/analytics/,
    │        features/{shell,home,shop,product,profile,dashboard}/}
    ├── test/{app/, architecture/, core/, data/, di/, domain/, features/, helpers/}
    └── build.yaml  pubspec.yaml  android/  ios/
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Delivering the SDK | a library module (`tracklite/`) + a `sample-app` module | a local Swift Package (`Packages/TrackLite`) + a sample target | a package in a pub workspace (`packages/tracklite`) + `sample_app` |
| Hiding internals | Kotlin `internal` | Swift `internal` (the default) | `lib/src/` + `show` lists + `@internal`, enforced by `implementation_imports` |
| The entry point | `object TrackLite` | `enum TrackLite` with static methods | `abstract final class TrackLite` + `TrackLiteClient` |
| Config | `data class TrackLiteConfig` | `struct TrackLiteConfig: Sendable` | `final class TrackLiteConfig` (const, validated) |
| Flush interval | `flushIntervalMinutes = 15` | `Duration.seconds(900)` | `flushInterval = 30 s` in the foreground (background: Phase 4) |
| Results | unspecified | unspecified | a sealed `FlushResult` with six cases |
| Internal DI | Hilt "if practical" | none | none: a hand-written composition root |
| Sample state | ViewModel + StateFlow | `@Observable` | Cubits behind an `AnalyticsService` port |
| CI | `android-ci.yml` (Phase 6) | `ios-ci.yml` (Phase 6) | `flutter-ci.yml` from Phase 1, with a publish dry run |

---

## Interview Notes

**Q: How do you keep an SDK's public API small in Dart?**
A: There's no `internal` keyword, so:
- everything lives under `lib/src/`;
- one library at `lib/<package>.dart` exports only the public names, with `show` lists;
- the analyzer's `implementation_imports` flags any host that imports `src/` directly;
- `@internal` marks public-in-Dart classes that aren't API.

Here a test also lists the exports, so adding a name is a reviewed change.

**Q: Why both a static facade and a client interface?**
A: The facade is what most apps want: `TrackLite.track(...)` from anywhere. But statics can't be injected or faked. `TrackLiteClient` is the same calls as an interface: an app with DI registers `TrackLite.instance`, and its tests pass a fake.

**Q: When should an SDK throw?**
A: Only for a developer's mistake, as early as possible: an invalid config at `initialize`, naming every broken rule. At runtime, never:
- `track()` is `void` and catches everything;
- `flush()` returns a result.

The host's users must never pay for the SDK's bug.

**Q: Why is adding a case to a sealed class a breaking change?**
A: Because callers may `switch` over it exhaustively without a default. A new case makes their code fail to compile. So `FlushResult` has all six cases from the first version, and the public-API test has such a switch.

**Q: Why doesn't the SDK use `freezed`, `get_it` or `flutter_bloc`?**
A: Every dependency of a library becomes a dependency of every app that uses it, with version conflicts included. The SDK uses hand-written value classes and wires its parts by hand. The sample app uses the full stack, because an app can choose its dependencies.

**Q: Why does the sample app wrap the SDK in its own `AnalyticsService`?**
A: So the app's logic depends on the app's words, not a vendor's.
- Swapping or adding an analytics SDK changes one adapter class.
- Cubit tests use a recorder instead of a real SDK.
- A test enforces that only the wiring imports `package:tracklite`.

---

## Learning Checklist

- ✅ A pub workspace with an SDK package and a sample app
- ✅ A public API in one library with `show` lists; internals in `src/` and `@internal`
- ✅ A static facade over an injectable client interface
- ✅ A validated config that fails fast with every problem named
- ✅ Runtime calls that never throw, and a sealed result instead of exceptions
- ✅ Opt-in logging, with the API key masked
- ✅ `public_member_api_docs`, a public-API test, a version test
- ✅ `pub publish --dry-run` in CI
- ✅ The sample's analytics port, its adapter, and a boundary test
- ✅ Typed routes with a child route inside a tab
- ✅ Status colors tested for contrast; an accessibility tour from day one
- □ Storing events (Phase 2)
- □ Uploading them (Phase 3)

---

## Future Improvements

- **Phase 2:**
  - drift as the queue, `track()` storing `pending` events through a serial write queue;
  - validation (rejected events counted), the pre-init buffer, the anonymous id;
  - a live Queue card on the Dashboard.
- Generated API docs (`dart doc`) checked in CI, once the API has more to document (Phase 6).

---

## Notes on This Phase

- **From earlier projects:**
  - **ModularHub:** the workspace and its analyzer errors;
  - **RoamReady's Phase 1:** the sample's design system, navigation and test harness, with the package renamed;
  - `flutter create` derived the app IDs `co.bitfuse.flutter.tracklite_sample` and `co.bitfuse.flutter.trackliteSample`, both changed to `co.bitfuse.flutter.tracklite`.
- **Spec adjustments:**
  - **A blank API key** is a config error at `initialize`, not a 401 from the server. The fake server's 401 (Phase 3) is for a well-formed key it rejects.
  - **The public API grows by phase:** `TrackLiteDebug` (Phase 2), the transport and the retry policy (Phase 3–4), and `runBackgroundUpload` (Phase 4) arrive with their code. `FlushResult` is complete now, because adding a case later would break hosts.
  - **Phase 1 needs no Close fallback:** a product is a child of Shop, so a link to it always has the shop underneath.
  - **`intl`** came in Phase 1, for prices. `cupertino_ui` waits for its first iOS touch.
- **The dry run's exit code:** 0 when clean, 65 on a warning (checked by removing the repository link), so CI fails on either. A short description isn't a warning; pub.dev's scoring would flag it.
- **The docs lint and internal classes:** `public_member_api_docs` asked for docs on every member of every class in `src/`, and on primary constructors. `@internal` exempts what isn't API, and `FlushResult`'s cases became classic classes with documented constructors.
- **A test lesson:** `expect(list, [('event', {...})])` fails even when equal: a record compares its `Map` field by identity. The recorder stores a `Tracked` value with `mapEquals` instead.
- **Mutation checks:** 28 rules broken on purpose, one at a time, against both suites.
  - **24 were caught at first.**
  - **Three misses came from the facade guarding twice:** the "ignore a second `initialize`" check and the "first start wins" check each hid the other's removal.
    - The start is now shared by construction: `_start` sets the client before its future completes, and every caller awaits that one future.
    - New tests: a second call with a bad config is ignored (it isn't even validated), and two calls at once keep the first config.
  - **The fourth miss:** the SnackBar test sent the same state twice, but a second SnackBar just replaced the first. The test now dismisses it and re-sends the same message, expecting nothing.
  - One mutation (the "last start wins" check) no longer had code to break, and became "a finished start is never cleared".
  - **28 of 28 caught.**
