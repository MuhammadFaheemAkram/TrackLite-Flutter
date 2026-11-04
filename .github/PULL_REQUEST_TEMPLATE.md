<!-- Thanks for contributing to TrackLite! -->

## Summary

<!-- What does this PR change, and why? -->

## Changes

-

## Checklist

- [ ] `fvm flutter analyze` reports no issues.
- [ ] `fvm dart format --output=none --set-exit-if-changed .` passes.
- [ ] Both packages' tests pass (`packages/tracklite` and `sample_app`); new logic is covered by tests (rules at their edges, failure and offline paths).
- [ ] `fvm flutter pub publish --dry-run` in `packages/tracklite` is clean (a warning fails CI).
- [ ] Generated code is regenerated from the root and committed (`fvm dart run build_runner build --workspace`).
- [ ] **The public API:** a new or changed public name is in `lib/tracklite.dart`'s `show` list, `test/public_api_test.dart` and the SDK's README, with a doc comment.
- [ ] **The SDK's rules hold:** `track()` never throws or waits; events are stored first; one upload at a time; a claim is one statement; every exit from the queue is `sent` or counted.
- [ ] A new failure kind has a row in the error table (`docs/RETRY_STRATEGY.md`) and a test.
- [ ] A schema change bumps `schemaVersion` and ships with `make-migrations` output and a migration test.
- [ ] A new SDK dependency is justified (it becomes every host's), with a caret on a major.
- [ ] The sample's Cubits still depend only on the app's ports (the boundary test passes).
- [ ] UI changes work in dark mode and at large text sizes, and new screens or states are added to the accessibility tour.
- [ ] The SDK's `CHANGELOG.md` says what a host would notice; the version is bumped in code, pubspec and changelog together if releasing.
- [ ] A release build launches, if a plugin or native setup changed.
- [ ] Commit messages follow Conventional Commits.

## Screenshots (if UI changed)

| Before | After |
|--------|-------|
|        |       |
