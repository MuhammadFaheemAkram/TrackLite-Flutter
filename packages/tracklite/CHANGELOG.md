## 0.1.0

- The public API's shape:
  - `TrackLite` (`initialize`, `track`, `setUserId`, `clearUser`, `flush`, `shutdown`, `instance`, `version`);
  - `TrackLiteClient`;
  - `TrackLiteConfig`, with its rules checked at `initialize`;
  - `TrackLiteEvent`, `EventStatus` and the six `FlushResult` cases.
- Calls are logged in debug mode. Events aren't stored or sent yet: that's 0.2.0 and 0.3.0.
