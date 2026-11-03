/// TrackLite: a small analytics SDK for Flutter apps.
///
/// This is the whole public API. Everything else lives in `lib/src/` and can
/// change in any version; the names below change only with a new major
/// version (and are checked by `test/public_api_test.dart`).
library;

export 'package:tracklite/src/client/tracklite_client.dart'
    show TrackLiteClient;
export 'package:tracklite/src/config/tracklite_config.dart'
    show TrackLiteConfig;
export 'package:tracklite/src/model/event_status.dart' show EventStatus;
export 'package:tracklite/src/model/flush_result.dart'
    show
        Failed,
        FlushResult,
        NotInitialized,
        NothingToSend,
        Offline,
        Unauthorized,
        Uploaded;
export 'package:tracklite/src/model/tracklite_event.dart' show TrackLiteEvent;
export 'package:tracklite/src/tracklite.dart' show TrackLite;
