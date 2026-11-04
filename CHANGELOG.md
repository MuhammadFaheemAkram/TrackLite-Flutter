# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Conventional Commits](https://www.conventionalcommits.org/).

This is the project's changelog: the SDK, the sample app, the docs and CI, one release per build phase. The SDK package has its own, for its users: [`packages/tracklite/CHANGELOG.md`](packages/tracklite/CHANGELOG.md). Its versions match these.

## [Unreleased]

_All six build phases are complete. See [`docs/ROADMAP.md`](docs/ROADMAP.md) for what's next._

## [0.6.0] — 2026-11-04 — Phase 6: Documentation & CI

### Added
- **Docs:** ARCHITECTURE, SDK_DESIGN, EVENT_PIPELINE, RETRY_STRATEGY, TESTING (tests per area and every mutation check), LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS (light, dark, failures, offline, large text); the Phase 6 summary.
- **Open-source files:** CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, this CHANGELOG, and the GitHub issue and PR templates.
- **CI builds the SDK's API docs** (`dart doc --dry-run`); `dartdoc_options.yaml` makes a broken doc reference an error.
- 5 tests (389 in total): the prune keeping old unsent events, the segments and the event chip at large text. 24 mutation checks, 236 over the six phases.

### Fixed
- **At large text, an event's status chip broke its name mid-word** (`screen_op` / `ened`) on the Dashboard. Past 130 % text, the chip now goes under the details.

### Changed
- The README and the SDK's README are final. The SDK is 0.6.0 (documentation only: no API or behaviour change).

## [0.5.0] — 2026-11-04 — Phase 5: Dashboard + SDK Tools

### Added
- **The SDK's debug tools:** recent events, the upload log, `retryFailed()`; `TrackLiteStats` with the next retry, the last upload, online and uploading, live.
- **`TrackLiteNavigatorObserver`:** `screen_opened` for named page routes pushed, popped back to or replaced.
- **The sample:** Profile (sign in and out, the anonymous id); the Dashboard (the queue, uploads, the demo server's knobs and stats, totals, identity, recent events, the upload log; Flush now, Retry failed, Track 100 events); tab tracking by the shell; the app's ports split into analytics, debug and demo backend.
- `FakeAnalyticsServer.watchStats()`.

## [0.4.0] — 2026-11-04 — Phase 4: Retry + Background Uploads

### Added
- **Retries with backoff:** a 5xx counts an attempt and waits `RetryPolicy` (1 minute, doubling, at most an hour); past `maxRetries`, `failed`. Unreachable doesn't count; a 401 pauses automatic uploads.
- **`NetworkMonitor`** over `connectivity_plus`; offline, nothing is attempted. The sample's **Device offline** switch.
- **Automatic uploads:** the interval, a full batch, the app going to the background, a reconnect, a retry coming due.
- **Background uploads** with `workmanager` (about every 15 minutes), the SDK's dispatcher, and `runBackgroundUpload()` for an app with its own; the iOS host setup.
- `TrackLiteTesting.disableTimers()` and `FakeNetworkMonitor`.

## [0.3.0] — 2026-11-04 — Phase 3: Analytics Processing Pipeline

### Added
- **Uploads:** `flush()` sends every pending event in batches, oldest first, one run at a time; atomic claims; `sent` kept 24 hours; failures keep the events and stop the run.
- **At least once:** expired claims are sent again; the server drops duplicates by id.
- **`AnalyticsTransport`** and **`FakeAnalyticsServer`** (latency, failures, a key check, dedupe, stats).
- **Schema v2:** the upload log, with a tested migration from v1.
- The sample's Dashboard: Flush now, and what came of it.

## [0.2.0] — 2026-11-04 — Phase 2: Event Storage Layer

### Added
- **Events are stored** with drift in the SDK's own `tracklite.sqlite`: validated, stamped, one transaction per frame, in call order; the queue bounded and counted.
- **Calls before `initialize`** are kept and replayed with their own times.
- **Identity:** a stored anonymous id, rotated by `clearUser`.
- **`TrackLite.debug.watchStats()`** and the sample's live queue card.
- `package:tracklite/testing.dart` with an in-memory database; a fallback to memory if the file can't open.

## [0.1.0] — 2026-11-03 — Phase 1: SDK Foundation

### Added
- **The pub workspace:** the SDK (`packages/tracklite`) and the sample app (`sample_app`), one lockfile, FVM-pinned Flutter 3.47.6.
- **The public API's shape:** `TrackLite`, `TrackLiteClient`, `TrackLiteConfig` with its rules, `TrackLiteEvent`, `EventStatus`, `FlushResult`; one library with `show` lists, a public-API test, `public_member_api_docs`.
- **The sample's shell:** Home, Shop (with product pages), Profile and Dashboard tabs; its design system, navigation, DI and the `AnalyticsService` port.
- **CI:** generated code current, format, analyze, both packages' tests, `pub publish --dry-run`.
