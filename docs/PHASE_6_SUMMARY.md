# Phase 6 — Documentation & CI

## Phase Goal

Finish the project so someone else can understand, run, trust and extend it:
- **the design docs:** the architecture, the SDK's design, the event pipeline, the retry strategy, testing, learning and interview notes, a roadmap, and screenshots;
- **the open-source files:** CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, the project's CHANGELOG, and the GitHub issue and PR templates;
- **the final READMEs:** the repository's and the SDK package's (what pub.dev would show);
- **CI confirmed current,** and simulated from a clean copy of the tree;
- **close-out:** a mutation pass of the key rules against the finished suites, a release-build launch, the background task on the Android emulator, and screenshots on the iPhone simulator.

---

## What Was Implemented

- **Docs** (`docs/`):
  - [ARCHITECTURE](ARCHITECTURE.md): the SDK's layers and who knows whom, storage, the three concurrency rules, the sample's ports and adapters, the native comparison;
  - [SDK_DESIGN](SDK_DESIGN.md): the public API and why it's small, the facade and the client, the extension points, developer errors against device errors, dependencies, versioning, the host's setup;
  - [EVENT_PIPELINE](EVENT_PIPELINE.md): `track()` to the server step by step, every status and transition in one table, and the delivery guarantee with the crash walked through;
  - [RETRY_STRATEGY](RETRY_STRATEGY.md): the error table, the backoff, why unreachable doesn't count, the 401 pause and the 400, the dead state, expired claims, what the demo shows, and what a real backend would add;
  - [TESTING](TESTING.md): tests per area in both packages, how they're built, and every phase's mutation checks;
  - [LEARNING_NOTES](LEARNING_NOTES.md), [INTERVIEW_NOTES](INTERVIEW_NOTES.md), [ROADMAP](ROADMAP.md), [SCREENSHOTS](SCREENSHOTS.md) (12 shots: light, dark, failures, offline, AX3 text).
- **Repository files:** `CONTRIBUTING.md` (the SDK's and the sample's rules, the setup, schema changes, releasing a version), `CODE_OF_CONDUCT.md`, `SECURITY.md` (what the SDK stores, where, for how long, and advice for a host), `CHANGELOG.md` (one release per phase, 0.1.0–0.6.0), `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/bug_report.md` and `feature_request.md`.
- **The READMEs:**
  - **the repository's:** complete; screenshots, installation (git or path, the iOS setup, INTERNET for a real transport), an event's life, batching, retries and background in short, 389 tests and 236 mutation checks, the full native comparison, every doc;
  - **the SDK's:** 0.6.0; the delivery guarantee and what can leave the queue unsent (always counted); the configuration in full, with `retry`, `transport` and `networkMonitor`.
- **SDK 0.6.0:** documentation only, no API or behaviour change. `dartdoc_options.yaml` makes a broken doc reference, a broken link or an ambiguous reference an **error**.
- **CI:** a new last step, **`dart doc --dry-run`** in `packages/tracklite`. A planted `[NoSuchThing]` failed it (`error: unresolved doc reference`, exit 1); the real docs build with 0 warnings and 0 errors.
- **The sample:** at large text, a recent event's status chip goes **under** its details instead of beside the name (see *Notes*).
- **5 new tests (389 in total: 211 SDK, 178 sample):** the prune keeping old unsent events; `SegmentedChoice` at normal and large text; the event chip beside the name, and under it at large text.

---

## SDK Concepts Demonstrated

- **Documentation is part of an SDK's API.** A host developer reads the README, the doc comments and the changelog before the code. Each is checked: `public_member_api_docs` (every public member documented), `dart doc` with broken references as errors, `pub publish --dry-run` (the README, CHANGELOG and LICENSE that ship), and `version_test.dart` (the code, pubspec and changelog agree).
- **A stated delivery guarantee.** "At least once" with deduplication by id, written down with the crash walked through, and a list of the only ways an event can leave the queue unsent, each counted.
- **A contract for extension:** the transport's error table is documented as the contract between the SDK and any backend.
- **Versioning by what a host would notice:** 0.6.0 changes no API and no behaviour, and the changelog says so.
- **A security policy for an SDK:** what is stored, where, for how long; the key masked in logs; advice for a host (no personal data in properties, HTTPS, an ingestion key is public).

---

## Flutter / Dart Concepts Demonstrated

- **`dartdoc_options.yaml`:** `errors:` turns chosen dartdoc warnings into errors, so `dart doc --dry-run` fails CI on them.
- **Adaptive layout at large text:** the existing `context.prefersStackedLayout` rule (above 130 %) now also decides where a `ListTile`'s status chip goes.
- **Testing large text:** `tester.platformDispatcher.textScaleFactorTestValue = 2`, then compare widget rects (`tester.getRect`) to prove *where* something is, not just *that* it is.
- **Release builds:** `flutter build apk --release` and a launch, since tree shaking and the main manifest only show there.

---

## Event Flow

Nothing in the pipeline changed in Phase 6. The flows the docs describe, as seen while taking the screenshots:

```
Failures 100 %, Track 100 events              (docs/RETRY_STRATEGY.md, "What the demo shows")
  drain: 100 events, one transaction ─▶ onStored(100) ─▶ due ≥ 20 ─▶ threshold run
  claim 20 oldest ─▶ 500 ─▶ those 20: attempt 1, wait 1 min; the run stops; 80 untouched
  every 30 s: claim the 20 oldest *due* ─▶ 500 ─▶ stop      (5 runs to reach them all)
  a minute on: the first 20 are due again, and go before the untried ones; their wait doubles

Relaunch during an upload                     (docs/EVENT_PIPELINE.md, "the crash, step by step")
  2 events claimed (sending) ─▶ app killed ─▶ relaunch: "Sending 2"
  a run after 5 minutes ─▶ releaseExpiredClaims ─▶ pending ─▶ sent again ─▶ the server drops duplicates by id
```

---

## Important Files Added

| File | Purpose |
|---|---|
| `docs/ARCHITECTURE.md`, `SDK_DESIGN.md`, `EVENT_PIPELINE.md`, `RETRY_STRATEGY.md` | The design, in four documents |
| `docs/TESTING.md`, `LEARNING_NOTES.md`, `INTERVIEW_NOTES.md`, `ROADMAP.md`, `SCREENSHOTS.md` | Quality, lessons, questions, what's next, what it looks like |
| `docs/screenshots/*.png` | 12 screenshots from the iPhone 17 Pro simulator |
| `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md` | The open-source set |
| `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/*.md` | The GitHub templates, with the SDK's rules as a checklist |
| `packages/tracklite/dartdoc_options.yaml` | Broken doc references are errors |
| `sample_app/test/core/design_system/widgets/segmented_choice_test.dart` | Segments side by side, chips at large text |

**Changed:** both READMEs, the SDK's CHANGELOG, version and pubspec (0.6.0), `flutter-ci.yml` (the docs step), `event_lists.dart` (the chip at large text), `upload_manager_test.dart` and `dashboard_view_test.dart` (new tests).

---

## Important Types Added

None: Phase 6 changes no public or internal type.

---

## Folder Structure Changes

```
TrackLite/
├── CHANGELOG.md  CONTRIBUTING.md  CODE_OF_CONDUCT.md  SECURITY.md   # new
├── .github/
│   ├── workflows/flutter-ci.yml                                     # + dart doc --dry-run
│   ├── PULL_REQUEST_TEMPLATE.md                                     # new
│   └── ISSUE_TEMPLATE/{bug_report,feature_request}.md               # new
├── docs/
│   ├── ARCHITECTURE.md  SDK_DESIGN.md  EVENT_PIPELINE.md  RETRY_STRATEGY.md   # new
│   ├── TESTING.md  LEARNING_NOTES.md  INTERVIEW_NOTES.md  ROADMAP.md  SCREENSHOTS.md   # new
│   ├── PHASE_6_SUMMARY.md                                           # new
│   └── screenshots/                                                 # new: 12 PNGs
└── packages/tracklite/dartdoc_options.yaml                          # new
```

---

## Android / iOS Comparison

| Topic | Android | iOS | Flutter |
|---|---|---|---|
| Docs | the native spec's README and design docs | the same | the same, plus an SDK README for pub.dev and a project changelog |
| API docs | KDoc / Dokka | DocC | dartdoc, **with broken references as errors in CI** |
| Package check | — | — | `pub publish --dry-run` (warnings fail) |
| CI | added in Phase 6 | added in Phase 6 | since Phase 1; Phase 6 adds the docs step |
| Large text | `sp` units | Dynamic Type | the text scaler, and a stacked layout past 130 % |

---

## Interview Notes

- **"How do you keep an SDK's documentation from rotting?"** Check it like code: every public member documented (a lint), the docs built in CI with broken references as errors, the README and changelog checked by the publish dry run, and the version checked across code, pubspec and changelog.
- **"What does a version bump mean if nothing changed in the code?"** Here 0.6.0 ships a finished README and doc config; the changelog says "no API or behaviour change", so a host knows upgrading is safe.
- **"What did the last mutation pass find?"** Two holes in a finished suite: the prune could have deleted old *unsent* events (no test had a pending event older than a day when a batch succeeded), and the segments' large-text layout had no test of its own.

---

## Learning Checklist

- [x] Why an SDK's README, doc comments and changelog are part of its API
- [x] How `dartdoc_options.yaml` makes doc warnings fail CI
- [x] How to state a delivery guarantee, and list the ways data can leave unsent
- [x] Why a mutation pass is worth running on a "finished" suite
- [x] How to test where a widget is at large text (`getRect`), not just that it's there
- [x] What a security policy covers for an SDK that stores user data on the device

---

## Future Improvements

See [ROADMAP.md](ROADMAP.md): a real HTTP transport (gzip, `Retry-After`, jitter), consent and opt-out, sessions and super properties, sampling, a transport factory for the background isolate, clock-skew correction, publishing to pub.dev, and a web implementation.

---

## Notes on This Phase

- **A layout fix the screenshots found:** at AX3 text, a recent event's status chip left its name a narrow column, and `screen_opened` broke mid-word (`screen_op` / `ened`). The accessibility tour passed (nothing overflowed), but it read badly. Past 130 % the chip now goes under the details, and two tests check where it is.
- **Seen on the simulator while taking the screenshots:**
  - **Batch by batch under failures:** with 100 % failures and a burst of 100, each run sent one batch of 20, got a 500 and stopped. The burst was attempted over five runs, oldest first, and the first batch's retries went before the untried events once their wait was over.
  - **"Next retry" a few seconds in the past:** an event can be due while a batch-limited run hasn't reached it yet. The scheduler arms its timer only for a time ahead (the Phase 4 rule), so the next interval sends it. This is documented in RETRY_STRATEGY, not changed.
  - **At least once:** relaunching mid-upload left "Sending 2" until the claim expired.
- **Close-out on Android:**
  - **A release build** (after the last code change) was installed with its data cleared and launched on the Pixel 10 Pro emulator (API 36).
  - **The background task:** the SDK's periodic job was registered (`#BackgroundWorker#` in `dumpsys jobscheduler`), and its first run ended `Worker result SUCCESS`. The Dashboard's last upload then read **"Background task · Uploaded, 1 event"**: the worker had sent Home's `screen_opened` from its own isolate, and the app's streams saw it.
  - **A release build's database can't be read** (`run-as` needs a debuggable app), so the Dashboard, not `sqlite3`, was the witness this time.
- **Mutation checks:** 24 key rules broken on purpose, one at a time, against both finished suites.
  - **22 were caught at first.**
  - **Two were missed, and now have tests:**
    - **the prune deleting old unsent events:** no test had a pending (or failed) event older than a day when a batch succeeded. The new one has both, with batches of 1, and expects `failed, sent, sent`;
    - **the segments not stacking at large text:** no test checked `SegmentedChoice` itself. It now has tests at 100 % and 200 %.
  - **24 of 24 caught.** **236 over the six phases;** 235 caught, 1 equivalent (Phase 3), documented in TESTING.
- **The simulator** was restored after the screenshots: the status-bar override cleared, the appearance light, the text size large.
