# Phase 5 — Dashboard + SDK Tools

## Phase Goal

Make the SDK's inner life visible, and finish the sample. Phase 5 adds what a support build or a debug screen needs, then builds the full Dashboard on it:
- **the SDK's debug tools:**
  - recent events and the upload log, as live streams;
  - "retry failed";
  - stats that also say when the next retry is due, what the last upload did, and whether the SDK is online and uploading right now;
- **screen tracking** with a navigator observer, and the rule for what it can't see (switching tabs);
- **the sample's real screens:**
  - Profile (sign in and out);
  - the full Dashboard: queue, actions, uploads, network, a demo server whose failure rate and speed can be set, totals, identity, recent events, the upload log.

---

## What Was Implemented

- **SDK 0.5.0 (public):**
  - **`TrackLiteDebug`:**
    - `watchRecentEvents({limit})` (newest first, any status);
    - `watchUploads({limit})`, returning the new `UploadRecord`;
    - `retryFailed()`: `failed` back to `pending`, attempts and wait cleared; it returns how many.
  - **`TrackLiteStats`:** `nextRetryAt`, `lastUpload`, `isOnline`, `isUploading` (optional, with defaults, so a host's fakes don't break).
  - **`TrackLiteNavigatorObserver`:**
    - tracks `screen_opened {screen: <route name>}` when a **named page route** is pushed, popped back to, or replaces another;
    - skips a navigator's first route, popups and unnamed routes;
    - takes an optional client and `screenName` function;
    - never sends arguments.
  - **`FakeAnalyticsServer.watchStats()`.**
- **SDK internals:**
  - **the stats query** also reads the earliest retry time and the newest upload's id, and watches `uploads` too;
  - **`DatabaseDebug`** combines the database's stats with the monitor's and the uploader's live state through **`combineLatest3`**, the SDK's own small helper. It builds fresh source streams per listener (`Stream.multi`), so the result can be listened to more than once, like drift's;
  - **`UploadManager.watchUploading()`;**
  - `EventDao.watchNewest`, `retryFailed`; `UploadDao.watchNewest`, `byId`; `UploadRowMapper`.
- **The sample:**
  - **Ports:**
    - `AnalyticsService` keeps the everyday calls and gains `watchIdentity()`;
    - **`AnalyticsDebug`** (a port of its own) has the Dashboard's tools;
    - **`DemoBackend`** has the demo server's knobs.

    Each has its adapter (`TrackLiteAnalyticsService`, `TrackLiteAnalyticsDebug`, `FakeServerDemo`).
  - **Models:** `AnalyticsIdentity`, `RecentEvent` (with a properties summary), `UploadRun`, `UploadOutcome`, `ServerFailures`, `ServerSpeed`, `DemoServerState`.
  - **The fake server is the app's own:** created in DI and given to the SDK as its transport, so the Dashboard can set its failure rate and speed.
  - **Screen tracking:**
    - the shell reports tab screens (at start and on every tap of the bar);
    - every branch's navigator has the SDK's observer, for screens inside a tab;
    - the routes have names.
  - **Profile:** `ProfileCubit` follows the identity analytics reports. Sign in sets the user first, then tracks `signed_in`; sign out tracks `signed_out`, then resets.
  - **The Dashboard,** split into sections:
    - **Queue:** the counts, a progress line while uploading, Flush now, Retry failed (on only with failed events), Track 100 events;
    - **Uploads:** the last one in words, the next retry, the network and Device offline;
    - **Demo server:** failures 0 / 10 / 50 / 100 %, speed Fast / Normal / Slow, and what it received;
    - **Totals and Identity;**
    - **Recent events:** each with its properties, time, errors, retry time and a `StatusChip`;
    - **Upload log.**

    One-time messages are a sealed `DashboardEffect` (flushed, retried, tracked), worded by `effectWords`.
  - **Design system:** `StatusChip` (an icon and a word in a status color, on an outline).

---

## SDK Concepts Demonstrated

- **A debug surface is a product.** A support engineer asking "is the SDK sending?" needs the queue, the last upload and its error, the next retry and the network state, in one place. Here they are one stream (`watchStats`), plus the recent events and the log.
- **Live state and stored state, combined.** Online and uploading aren't in the database; the counts are. The stats combine three sources and emit whenever any changes, so a debug screen never shows "uploading" after the upload ended.
- **A stream is part of the API's behavior.** drift's streams can be listened to many times; a combined one built naively couldn't. The SDK's combined streams build their sources per listener, so the API behaves the same everywhere (tested).
- **Recovering the dead state.** `retryFailed()` puts given-up events back as new: no attempts, no wait. It doesn't send them: the next upload, or `flush()`, does. Keeping "requeue" and "send" apart keeps both predictable.
- **Screen tracking and its blind spot.**
  - A navigator observer sees pushes, pops and replacements, so it can't see a tab switch: an already-built tab just becomes visible.
  - So the rule is explicit. The observer skips a navigator's **first** route (the container's), and the container, here the shell, reports it.
  - Only route **names** are sent, never arguments: those can carry ids or personal data.
- **Public models that can grow.** `TrackLiteStats` gained four fields, all optional with defaults. A host's fake that constructs one still compiles; a required field would have broken it.
- **A vendor's debug tools behind the app's own port.** The Dashboard depends on `AnalyticsDebug`, a port separate from the everyday `AnalyticsService`. Screens that only track never see "retry failed".
- **Demo controls belong to the app.** The sample creates the fake server itself and passes it as the transport; the SDK sees only an `AnalyticsTransport`. That's the extension point working as designed.

---

## Flutter / Dart Concepts Demonstrated

- **`Stream.multi`** for a stream that gives each listener its own subscriptions.
- **`NavigatorObserver`**: `didPush`, `didPop`, `didReplace`; `PageRoute` versus popups; `RouteSettings.name`.
- **go_router names and branch observers:**
  - `TypedGoRoute(name: …)` gives each page's `settings.name`;
  - a branch's `static final List<NavigatorObserver> $observers` goes into its navigator;
  - there is also a widget test with a bare `Navigator`.
- **Sealed one-time effects** (`DashboardEffect`) with a serial, instead of one field per message.
- **`ListenableBuilder` on a `TextEditingController`** to enable a button only when the field has text, and `TextInputAction.done` to submit.
- **Splitting a long screen into section widgets,** each with only the state it needs.
- **Widget-test lessons:**
  - a test surface over 16,384 px tall can't be snapshotted during a page transition;
  - a button enabled by typing needs a `pump()` before the tap;
  - a hint text is also found by `find.text`.

---

## Event Flow

```
Shop tab tapped           → MainShell.onTabShown(shop) → AnalyticsService.track('screen_opened', {screen: shop})
product opened            → TrackLiteNavigatorObserver.didPush (named 'product') → TrackLite.track(...)
Back                      → didPop: the shop page is shown again → screen_opened {screen: shop}

Dashboard (DashboardCubit, five streams):
  AnalyticsDebug.watchQueue()        ← TrackLiteDebug.watchStats()
                                         = combineLatest3(db stats row (+ next retry, last upload),
                                                          monitor.watch(), uploader.watchUploading())
  AnalyticsDebug.watchRecentEvents() ← watchRecentEvents()  (EventDao.watchNewest)
  AnalyticsDebug.watchUploads()      ← watchUploads()       (UploadDao.watchNewest)
  DeviceNetwork.watchStatus()        ← DemoNetworkMonitor
  DemoBackend.watch()                ← FakeServerDemo ← FakeAnalyticsServer.watchStats() + the knobs

Retry failed → AnalyticsDebug.retryFailed() → failed → pending (attempts 0, no wait) → the next upload sends them
```

---

## Important Files Added

| Path | Purpose |
|---|---|
| `packages/tracklite/lib/src/model/upload_record.dart` | One upload run, public |
| `packages/tracklite/lib/src/navigation/tracklite_navigator_observer.dart` | Screen tracking for named page routes |
| `packages/tracklite/lib/src/util/combine.dart` | `combineLatest3`, per listener |
| `packages/tracklite/lib/src/storage/upload_mapper.dart` | A logged run as a record |
| `sample_app/lib/domain/analytics/analytics_debug.dart` | The Dashboard's port and its models |
| `sample_app/lib/domain/demo/demo_backend.dart` | The demo server's port, knobs and state |
| `sample_app/lib/data/analytics/tracklite_analytics_debug.dart` | The debug port, with the SDK |
| `sample_app/lib/data/analytics/fake_server_demo.dart` | The demo knobs on the SDK's fake server |
| `sample_app/lib/features/profile/cubit/` | Sign in and out |
| `sample_app/lib/features/dashboard/widgets/` | The Dashboard's sections |
| `sample_app/lib/features/dashboard/dashboard_words.dart` | Outcomes, effects, triggers in words |
| `sample_app/lib/core/design_system/widgets/status_chip.dart` | A status as an icon and a word |
| `sample_app/lib/core/common/time_text.dart` | `14:21:05` |

---

## Important Types Added

| Type | Responsibility | Why there |
|---|---|---|
| `UploadRecord` | A run as the log keeps it | Public: the debug tools return it |
| `TrackLiteNavigatorObserver` | Screen views for named pages | Public: hosts add it to navigators |
| `combineLatest3` | The latest of three streams, per listener | `src/util`, `@internal` |
| `AnalyticsDebug`, `RecentEvent`, `UploadRun` | The Dashboard's view of analytics | Sample, domain |
| `DemoBackend`, `DemoServerState` | The demo server | Sample, domain |
| `TrackLiteAnalyticsDebug`, `FakeServerDemo` | The ports with the SDK | Sample, data |
| `ProfileCubit` | Sign in and out, the identity shown | Sample, features |
| `DashboardEffect` | Flushed, retried, tracked | Sample, features |
| `StatusChip` | A small status, never color alone | Sample, design system |

---

## Folder Structure Changes

```
packages/tracklite/lib/src/
├── model/        + upload_record
├── navigation/   tracklite_navigator_observer        (new)
├── storage/      + upload_mapper
└── util/         + combine
sample_app/lib/
├── domain/analytics/analytics_debug.dart    domain/demo/demo_backend.dart
├── data/analytics/tracklite_analytics_debug.dart, fake_server_demo.dart
├── core/common/time_text.dart    core/design_system/widgets/status_chip.dart
└── features/profile/cubit/   features/dashboard/{widgets/, dashboard_words.dart}
```

---

## Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| The dashboard | total, pending, failed, sent, the user id, the last upload | + sending, Flush, network and failure-rate toggles | all of those, plus the next retry, uploading, the server's stats and speed, recent events, the upload log, Retry failed, Track 100 events |
| Its data | a ViewModel reading the SDK | `@Observable`, the SDK's queryable state | the SDK's debug streams, through the app's `AnalyticsDebug` port |
| Screen tracking | `track("home_screen_opened")` by hand | `onAppear` | `TrackLiteNavigatorObserver` (named pages) + the shell for tabs |
| User identification | `setUserId` | `setUserId` / `clearUser` | the same; `clearUser` rotates the anonymous id; Profile shows it |
| Demo toggles | — | network, failure rate | Device offline, failures 0–100 %, speed, through the app's own ports |
| Retrying failed events | "retry failed events" (repository) | — | `TrackLite.debug.retryFailed()` |

---

## Interview Notes

**Q: What belongs in an SDK's debug API, and why keep it apart from the main API?**
A: What someone needs to answer "is it working?": the queue's state, the last upload and its error, the next retry, the network, the recent events, and a way to requeue failures. It's kept in `TrackLite.debug`, so the everyday API (`track`, `flush`, identity) stays small, and an app can show it only in a debug build.

**Q: How do you combine stored and live state in one stream?**
A: Combine the latest of each source: the database's stats, the monitor's online state, the uploader's uploading state. Emit on any change once all have a value. Build the sources per listener, so the combined stream can be listened to more than once, like drift's own streams.

**Q: How does automatic screen tracking work in Flutter, and what does it miss?**
A: A `NavigatorObserver` sees routes pushed, popped and replaced, so it tracks the screen that becomes visible. It can't see a tab switch: the tab's navigator already exists and simply becomes visible. So the observer skips each navigator's first route, and the shell reports tabs. Only the route's name is sent, never its arguments.

**Q: Why does sign-in call `setUserId` before tracking `signed_in`, and sign-out track before `clearUser`?**
A: So both events carry the user. Reversed, `signed_in` would be anonymous, and `signed_out` would carry the new anonymous id, attributed to nobody.

**Q: How do you add fields to a public model without breaking hosts?**
A: Make them optional with defaults. A host's fake that builds `TrackLiteStats(anonymousId: …)` still compiles. A new required field, or a new member on an interface the host implements, breaks them: the changelog has to say so.

---

## Learning Checklist

- ✅ Debug streams: recent events, the upload log, stats with live state
- ✅ A combined stream that can be listened to many times
- ✅ `retryFailed()`: requeue, not send
- ✅ A navigator observer for named pages, and the shell for tabs
- ✅ Sign in and out, in the order that keeps both events attributed
- ✅ The full Dashboard, through the app's own ports
- ✅ The demo server's knobs, through the transport extension point
- ✅ `StatusChip`: never color alone
- □ The final docs, screenshots, CI from a clean copy, a release-build launch (Phase 6)

---

## Future Improvements

- **Phase 6:**
  - the final README and the docs (`SDK_DESIGN`, `EVENT_PIPELINE`, `RETRY_STRATEGY`, `ARCHITECTURE`, `TESTING`, learning and interview notes, `ROADMAP`, `SCREENSHOTS`);
  - the repo files;
  - CI simulated from a clean copy;
  - a release-build launch, and the background task on the Android emulator.
- **Relative times on the Dashboard** ("retry in 40 s"), with a ticker as in RoamReady.
- **A filter on Recent events** (by status), and paging past the newest 20.

---

## Notes on This Phase

- **Spec adjustments:**
  - **The identity rotation came in Phase 2;** this phase shows it (Profile).
  - **The sample's ports are split in three:** analytics (everyday), its debug tools (the Dashboard), and the demo backend. That keeps the everyday port small and the vendor-specific debugging out of normal screens.
  - **The sample creates the fake server** and passes it as the transport, so the demo knobs act on the SDK's real backend object. Before, the SDK made its own.
  - **Recent events carry a short properties summary** (`screen: product`), so screen tracking can be seen on the Dashboard.
- **Problems found while building:**
  - The first `combineLatest3` was single-subscription: a second `watchStats().first` failed "Stream has already been listened to". It also listened to source streams created once; it now builds them per listener.
  - Tab tracking means a fresh install has events already (the Dashboard's own screen). The flows now check their own events by name, not totals.
  - An observer test built its client after the observer had captured the old one, and "passed" with nothing recorded. It was fixed to check the real client.
- **On the iPhone simulator:**
  - **Track 100 events:** showed Sending 20 / Pending 82 with the progress line. One `threshold` run then sent all 102 events, in six requests (the demo server: 6 received).
  - **Failures at 100 %:** a flush said "Sending failed (server error 500). 4 events still waiting". The next retry was due a minute later. Each event showed "1 server error · retry at … · server error 500", and later a second, when the retry timer fired by itself.
  - **Profile:** signed in as `alex` (pasted, §11.69), then out. `signed_in` and `signed_out` both carry `alex`, and the anonymous id changed.
  - **Screen tracking:** Shop, then a product, then Back stored `shop`, `product`, `shop`.
  - **Light and dark** were checked; the status-bar override left from RoamReady's screenshots was cleared.
- **Mutation checks:** 44 rules broken on purpose, one at a time.
  - **35 were caught at first.**
  - **Two didn't apply** (formatting); retargeted, both were caught.
  - **Six were missed, and now have tests:**
    - **`retryFailed` keeping the attempts or the old retry wait:** the test's failed events came from a 400, so they had neither. The new one fails an event with a 5xx first, then a 400;
    - **the stats' earliest retry, and the newest upload:** the tests had only one of each. They now choose between two;
    - **the stats not watching the upload log:** a flush with nothing to send writes only the log, and the stats must still update;
    - **an empty route name:** now skipped, by test.
  - **One more was a test of the wrong file.** "The product route unnamed" edited the annotation, but the name lives in the generated routes. Retargeted at `app_routes.g.dart`, it was caught.
  - **44 of 44 caught.**
