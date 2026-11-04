# The Event Pipeline

From `track()` to the server, and every place an event can be on the way.

```
track('purchase', {price: 20})                     the host's call: synchronous, never throws
   │
   ├─ validate ──────────── invalid? refused, rejected_total + 1, logged (debug mode)
   │
   ├─ stamp: a UUID, the time now (UTC), the user id and anonymous id *now*
   │
   ▼
the recorder's queue (in memory, call order)       identity changes and counters go in the same queue
   │  one drain at a time, scheduled in a microtask
   ▼
one transaction ─▶ events (status: pending) · tracked_total · the cap (oldest unsent dropped, dropped_total)
   │
   ├─ onStored(n) ─▶ the scheduler: a full batch due? ─▶ trigger "threshold"
   ▼
a trigger: interval · threshold · paused · reconnect · retryDue · background · manual (flush)
   │  offline? key rejected? ─▶ nothing attempted
   ▼
UploadManager.upload (single-flight: a second caller joins the run)
   │  1. wait for the recorder: everything tracked so far is stored
   │  2. release claims older than 5 minutes (an upload that died)
   │  3. claim up to batchSize due events, oldest first, in one statement ─▶ sending
   │  4. transport.upload(UploadBatch(apiKey, sentAt, libraryVersion, events))
   │  5. success ─▶ one transaction: sent, sent_total, prune sent > 24 h ─▶ next batch (back to 3)
   │     failure ─▶ the error table, and the run stops
   │  6. log the run (uploads)
   ▼
FlushResult: Uploaded · NothingToSend · Offline · Failed · Unauthorized · NotInitialized
```

---

## 1. Validate

| Rule | Limit |
|---|---|
| The name | 1–64 characters, not blank |
| Properties | at most 25 |
| A property key | 1–40 characters, not starting with `$` (reserved, as in Mixpanel and Amplitude) |
| A property value | a `String` (≤ 255 characters), a finite `num` or a `bool` |

An invalid event is **refused and counted**, never thrown at the host. The database's `CHECK`s are a second line: a bug that slips past the validator fails loudly at the insert instead of storing a row that would fail every upload.

## 2. Stamp

The event gets its id (UUID v4), its time (UTC, from an injected `Clock`), and the identity **at the call**: an event tracked just before `setUserId` carries no user id, even if both are stored in the same transaction.

## 3. Store

- **The host never waits.** `record()` queues and returns; a drain is scheduled in a microtask, so it runs after the current frame's synchronous code.
- **One drain at a time, one transaction per drain.** Everything queued so far is written in call order, in one commit: a burst of 100 `track()` calls in a frame is one write, not 100.
- **All or nothing.** If the transaction fails (a full disk, a broken file), none of the drain is stored. The error is logged and the SDK carries on rather than fail the host. It is the one way an event can be lost: a counter can't be written either.
- **The cap.** In the same transaction, unsent events past `maxQueueSize` (10,000) are dropped, **oldest first**, and counted. An SDK must not fill a user's disk because a server is down for a month.
- **Order is `seq`,** the insertion order: never the timestamp (two events can share one, and a device's clock can move back).

## 4. Trigger

The app never has to call `flush()`. The scheduler starts uploads when they are worth it:

| Trigger | When |
|---|---|
| `interval` | every `flushInterval` (30 s) while the app is in the foreground |
| `threshold` | a drain leaves `batchSize` (20) events due: a full batch is ready |
| `paused` | the app goes to the background: its last chance before the OS may kill it |
| `reconnect` | the network comes back |
| `retryDue` | the earliest retry time arrives (one timer, re-armed after each run) |
| `background` | the `workmanager` task, about every 15 minutes, with a network |
| `manual` | `flush()`: the only one that ignores retry waits |

None of them runs offline or while the API key is rejected. They only **ask**: the uploader is single-flight, so triggers that pile up join one run.

## 5. Claim, send, settle

**The claim** is one SQL statement:

```sql
UPDATE events SET status = 'sending', claim_token = ?1, claimed_at = ?2
WHERE seq IN (SELECT seq FROM events
              WHERE status = 'pending'
                AND (?3 OR next_attempt_at IS NULL OR julianday(next_attempt_at) <= julianday(?2))
              ORDER BY seq LIMIT ?4)
```

A second uploader running the same query (another trigger, or the background isolate) gets the **next** events, never these. The token identifies this batch for every later update.

**On success,** one transaction marks the batch `sent`, adds it to `sent_total`, and prunes `sent` rows older than 24 hours. Then the next batch, until none is due.

**On failure,** the run stops: a failing server isn't sent more. What happens to the batch depends on the error: see [RETRY_STRATEGY.md](RETRY_STRATEGY.md).

Every run, whatever its outcome, is a row in the upload log (the newest 100 are kept): why it ran, when, what came of it, how many batches and events, the error.

---

## Every status and transition

```
                    track()
                       │
                       ▼
   retryFailed()  ┌─────────┐  claim (due, oldest first)   ┌─────────┐   2xx    ┌──────┐   24 h   
  ┌──────────────▶│ pending │─────────────────────────────▶│ sending │─────────▶│ sent │────────▶ pruned
  │               └─────────┘◀─────────────────────────────└─────────┘          └──────┘  (sent_total keeps the count)
  │                 │   ▲    unreachable · 401 · a transport bug ·  │
  │                 │   │    a 5xx (+1 attempt, wait its backoff) ·  │
  │                 │   │    a claim older than 5 min                │
  │                 │   └────────────────────────────────────────────┘
  │                 │                                                │ a 400 · a 5xx past maxRetries
  │                 │ over maxQueueSize (oldest first)               ▼
  │                 └───────────────────▶ dropped (dropped_total)  ┌────────┐
  └────────────────────────────────────────────────────────────────│ failed │── over maxQueueSize ─▶ dropped
                                                                   └────────┘
```

| From | To | When | Counted |
|---|---|---|---|
| — | `pending` | `track()`, valid | `tracked_total` |
| — | (refused) | `track()`, invalid | `rejected_total` |
| `pending` | `sending` | a claim: due (never tried, or its wait is over), or any with `flush()` | |
| `sending` | `sent` | the server accepted the batch | `sent_total` |
| `sending` | `pending` | unreachable, a 401, a transport that broke its contract | no attempt |
| `sending` | `pending` (waiting) | a 5xx, attempts ≤ `maxRetries` | attempt + 1, `next_attempt_at` set |
| `sending` | `failed` | a 400, or a 5xx past `maxRetries` | kept with its last error |
| `sending` | `pending` | the claim is older than 5 minutes (the app died mid-upload) | |
| `failed` | `pending` | `debug.retryFailed()` | attempts and wait reset |
| `pending`, `failed` | deleted | over `maxQueueSize`, oldest first | `dropped_total` |
| `sent` | deleted | older than 24 hours | still in `sent_total` |

**Nothing leaves silently.** Every event ends `sent`, or is counted as `rejected`, `dropped` or `failed` (and a failed one can be revived). The only exception is a database that can't be written at all (see *Store*).

---

## The delivery guarantee: at least once

The device and the server can't commit together over a network. One of the two must go first:

- **Mark `sent` before the server confirms:** a crash in between loses the batch. *At most once.*
- **Mark `sent` after the server confirms** (TrackLite): a crash in between sends the batch again when its claim expires. *At least once.*

TrackLite chooses never to lose an event, and makes the duplicate harmless: **every event has an id, and the server keeps each id once** (`FakeAnalyticsServer` counts the duplicates it dropped). Exactly-once delivery is at-least-once plus deduplication by id.

**The crash, step by step:**
1. A batch is claimed (`sending`) and sent; the server stores it.
2. The app is killed before `sent` is written.
3. On the next start, the events are still `sending`. A run releases claims older than 5 minutes back to `pending`.
4. They are sent again; the server answers "20 duplicates", and they are marked `sent`.

Seen on the simulator while taking the screenshots: relaunching the app mid-upload left "Sending 2" on the Dashboard until the claim expired.
