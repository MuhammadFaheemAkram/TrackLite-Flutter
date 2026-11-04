# Retry Strategy

What happens when an upload fails, and why each rule is the way it is.

---

## The error table

A transport reports a failure by throwing one of four `TransportException`s. The kind decides what happens to the batch. **The run stops at the first failure,** whatever the kind: a failing server isn't sent more.

| Error | Example | The events | Attempts | `flush()` returns |
|---|---|---|---|---|
| `ServerUnreachable` | no route, DNS, a timeout | back to `pending`, due as before | **not counted** | `Failed` |
| `ServerFailure` (5xx) | 500, 503 | `pending`, waiting `retry.delayAfter(attempts)`; past `maxRetries`, `failed` | **+1** | `Failed` |
| `ApiKeyRejected` (401) | a revoked key | back to `pending`; automatic uploads **pause** until the next `initialize` | not counted | `Unauthorized` |
| `RequestRejected` (400) | a malformed batch | **`failed` at once**, kept with the reason | — | `Failed` |
| anything else | a transport bug | back to `pending`, logged as an error | not counted | `Failed` |

And before any of them: **offline, nothing is attempted** (`flush()` returns `Offline`, and automatic triggers don't even ask).

---

## The backoff

```dart
const RetryPolicy(base: Duration(minutes: 1), maxDelay: Duration(hours: 1))
// after failure 1, 2, 3, 4, 5, 6, 7…: wait 1, 2, 4, 8, 16, 32, 60, 60… minutes
```

- **Exponential:** `base × 2^(attempt − 1)`, capped at `maxDelay`. When a server struggles, every phone at once backs off further each time, instead of a flood that keeps it down.
- **Per event,** stored in `next_attempt_at`. An event that has failed three times waits longer than one that failed once, even in the same queue.
- **Pure and total:** `delayAfter` is a function of the attempt number only, defined for any attempt ≥ 1, and never overflows (it stops doubling once past the cap; doubling a `Duration` 62 times would overflow a 64-bit int).
- **`flush()` ignores the waits.** A developer who taps "Flush now" wants to see what happens now. Every automatic trigger respects them.
- **The retry timer.** The scheduler arms one timer, for the earliest retry time still ahead, and re-arms it after every run. A retry time already past belongs to an event that is due now: the next interval or reconnect sends it. (Arming "at once" for a past time would loop as fast as an unreachable server fails, since unreachable doesn't move the time. A mutation in Phase 4 showed exactly that loop.)

With the defaults (`maxRetries: 5`), an event survives five server errors and is given up on at the sixth, after at least half an hour of waits (1 + 2 + 4 + 8 + 16 minutes, plus however long each trigger took to come).

---

## Why unreachable doesn't count

An attempt measures **the server's** opinion of a batch. An unreachable server never saw it: the phone was in a tunnel, the Wi-Fi was a captive portal, the DNS timed out. If those counted, five network blips on a train would kill an event that nothing was wrong with.

So an unreachable batch goes back to `pending` with its attempts and its retry time unchanged, and waits for the next trigger (a reconnect, usually).

## Why a 401 pauses, and a 400 fails

- **A 401 is about the key, not the events.** Every upload would be rejected the same way, from every trigger, so the scheduler stops asking until the app restarts with a new configuration. The events wait, uncounted: they will be fine with the right key. An explicit `flush()` still tries, and says `Unauthorized`.
- **A 400 is about the events.** The server refused this batch as it is; sending it again would be refused again. The events are marked `failed` at once, kept, with the reason, so a developer can see what went wrong and fix the code that tracks them.

---

## The dead state and its recovery

`failed` is a dead end on purpose: nothing automatic touches a failed event again. It is **kept**, never deleted:
- the Dashboard counts it and shows its last error;
- `TrackLite.debug.retryFailed()` puts every failed event back to `pending` **as if new**: attempts 0, no wait, error cleared. Then the next trigger sends it. (The sample's **Retry failed** asks first.)

The only way a failed event leaves is the queue's cap (`maxQueueSize`), oldest first, counted in `dropped_total`.

---

## Expired claims

A claim is `sending` with a token and a time. If the app dies mid-upload (the OS kills it, the user swipes it away), the claim is never settled. So every run first releases claims older than **5 minutes** back to `pending`. That is long enough for any request to have finished (a batch is at most 100 events), and short enough that a crash costs one interval.

A released batch may already be on the server. It is sent again, and the server drops the duplicates by event id: at least once, never lost. See [EVENT_PIPELINE.md](EVENT_PIPELINE.md#the-delivery-guarantee-at-least-once).

---

## What the demo shows

With the Dashboard's **Failures** at 100 % and **Track 100 events**:
1. A full batch is due: the `threshold` trigger runs, the first batch of 20 gets a 500, and the run stops. Those 20 wait a minute; the other 80 are untouched.
2. The 30-second interval sends the next 20 that are due, oldest first. Each run gets one 500 and stops, so a burst of 100 is attempted over several runs, never in a flood.
3. Once the first 20's wait is over, they are the oldest due again, and go before the untried ones. Their wait doubles each time.
4. After the sixth server error, the Dashboard shows them **Failed**; **Retry failed** brings them back.

The upload log shows each run: *Full batch · Failed · server error 500*, then *Every 30 s · Failed*…

---

## What a real backend would add

- **`Retry-After`.** A 429 or 503 often says how long to wait. A real transport would read it, and the policy would take the larger of it and the backoff.
- **Jitter.** If a million phones fail at 9:00:00, a pure doubling brings them all back at 9:01:00, 9:03:00… Randomizing each wait (say, 50–100 % of it) spreads them out.
- **429 Too Many Requests** as its own kind: back off the whole client, not just the batch.
- **Smaller batches after a 413** (payload too large).
- **A circuit breaker:** after N failures in a row, stop all uploads for a while, not just the events that failed.

These are on the [roadmap](ROADMAP.md).
