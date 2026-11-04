# Roadmap

TrackLite is a learning project: six phases built a complete, tested SDK around a fake backend. These are the next steps a real analytics SDK would take, roughly in order of value.

---

## A real backend

- **An HTTP transport,** as a separate package (`tracklite_http`), so the core SDK doesn't depend on `http` or `dio`:
  - gzip the JSON body;
  - the API key in a header, never in the URL;
  - map responses to the error table: timeouts and DNS to `ServerUnreachable`, 5xx and 429 to `ServerFailure`, 401/403 to `ApiKeyRejected`, other 4xx to `RequestRejected`.
- **`Retry-After`:** read it on a 429 or 503, and wait the larger of it and the backoff.
- **Jitter** on every backoff (50–100 % of the wait), so a million phones don't all come back in the same second.
- **429 as its own kind:** back off the whole client, not just the batch.
- **A transport factory for the background isolate:** objects can't cross isolates, so today the background task always uses the default transport. A top-level function the host registers (like the `workmanager` dispatcher) would build its own.
- **Clock-skew correction on the server:** each batch carries `sentAt`, so the server can shift every event's time by the difference between `sentAt` and its own clock.

## Privacy and consent

- **Opt-out:** `TrackLite.setEnabled(false)` stops tracking and **deletes the queue**; `true` starts again with a new anonymous id.
- **Consent before the first event:** a config option to buffer (or drop) events until the app says the user agreed.
- **A privacy section** in the README: what is stored, for how long, what leaves the device, and how to delete it.
- **Property allow-lists,** so a property named `email` can't be sent by accident.

## More analytics

- **Sessions:** a session id on every event, a new one after 30 minutes in the background, and `session_start` / `session_end` events.
- **Super properties:** properties sent with every event (`app_version`, `plan`), set once.
- **User properties:** `setUserProperties({...})`, sent as their own event type.
- **Automatic context:** the OS, the device model, the locale, the app version (with `package_info_plus` and `device_info_plus`, as optional add-ons).
- **Sampling** (keep 10 % of a noisy event), and **per-event priority** (a `purchase` goes first, and is never dropped by the cap).

## The SDK itself

- **Publish to pub.dev:** the dry run already passes in CI. A real release would add a `CHANGELOG` discipline per pull request, an `example/` app and API docs (`dart doc`).
- **A web implementation:** a federated plugin with IndexedDB storage (drift supports web with `drift_flutter`'s web options), `navigator.sendBeacon` on page hide instead of `workmanager`, and `navigator.onLine` for the monitor.
- **Desktop:** drift and the queue work already; background uploads would need a platform-specific scheduler, or none.
- **Metrics about the SDK:** how long events wait, how often uploads fail, how big the queue gets, sent as the SDK's own (sampled) events.
- **A larger default batch on Wi-Fi,** and no uploads on a metered connection when the app says so.

## The sample app

- **An event inspector:** tap a recent event to see its full properties, id and history.
- **A "replay crash" button:** kill the app mid-upload on purpose, to show the at-least-once path without relaunching from a debugger.
