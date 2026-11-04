# Security Policy

## Supported Versions

TrackLite is a learning/reference project. Security fixes are applied to the latest `main` only.

| Version | Supported |
|---------|:---------:|
| `main`  | ✅ |

## Reporting a Vulnerability

Please **do not** open a public issue for security problems.

Instead, email **muhammadfaheem004@gmail.com** with:

- a description of the issue and its impact;
- steps to reproduce (a proof of concept if possible);
- any suggested remediation.

You can expect an acknowledgement within a few business days.

## What the SDK Holds

TrackLite has **no backend and no real API key**. The default transport is a fake server inside the app: nothing leaves the device unless a host app passes its own `AnalyticsTransport`.

- **Events** (their names, properties, user id and anonymous id) live in the SDK's own SQLite database (`tracklite.sqlite`, drift) in the app's documents directory, never in the host's database. It is not encrypted at rest; it is protected by the operating system's app sandbox like any app's private files. Sent events are deleted after 24 hours; unsent ones are capped at 10,000; everything goes when the app is removed.
- **The identity:** the user id the host sets, and a random anonymous id (a UUID v4), stored in the same database. `clearUser()` removes the user id and starts a new anonymous id, so the next person on the device isn't linked to the last.
- **The configuration,** including the API key, is saved in the same database for the background task to read. The key is **masked** when a config is printed (`TrackLiteConfig.toString()`), so it doesn't leak into logs or crash reports.
- **Logs:** without `debugMode` the SDK logs nothing; with it, events and their properties go to `dart:developer`'s log. Don't enable it in a release build.
- **No user text reaches SQL as code:** every value is a bound parameter. Properties are validated (types, sizes, counts) and stored as JSON; the database's `CHECK`s refuse anything that slips through.
- **No personal data is collected automatically:** the SDK sends only what the host tracks, plus a time, the ids and its version.

### For a host app

- **Don't track personal data** (emails, names, precise locations) as event properties unless your privacy policy and your users' consent cover it. Opt-out and consent are on the [roadmap](docs/ROADMAP.md).
- **A real transport should use HTTPS** and send the API key in a header, never in the URL.
- **A key in an app binary is public:** treat it as an identifier for ingestion only, never as a secret that grants reads.

The practical attack surface is small. Reports about data handling, dependency issues or unsafe patterns are still very welcome.
