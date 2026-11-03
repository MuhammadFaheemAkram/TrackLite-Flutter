import 'dart:developer' as developer;

import 'package:meta/meta.dart';
import 'package:tracklite/src/background/background_uploads.dart';
import 'package:tracklite/src/background/saved_config.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/connectivity/network_monitor.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/network/analytics_transport.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:workmanager/workmanager.dart';

/// Where the OS starts the SDK's background task: a fresh isolate with
/// nothing from the app in it.
///
/// A top-level function marked `@pragma('vm:entry-point')`: native code
/// starts it by name, so nothing in Dart calls it, and without the
/// annotation a release build's tree shaking would remove it.
@internal
@pragma('vm:entry-point')
void trackLiteBackgroundDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task == backgroundTaskName || task == Workmanager.iOSBackgroundTask) {
      await runBackgroundUpload();
    }
    // Always done: a failed upload leaves its events for the next run,
    // rather than having Android retry the job with its own backoff.
    return true;
  });
}

/// One background upload: open the database, read the config `initialize`
/// saved, upload what is due (respecting backoff), close.
///
/// It uses the default transport and monitor: objects can't cross into
/// another isolate. With the fake server that means a server of its own,
/// as if the real one had restarted (conventions §11.80); its runs still
/// show in the upload log, as `background`.
@internal
Future<FlushResult> runBackgroundUpload({
  TrackLiteDatabase Function()? openDatabase,
  AnalyticsTransport? transport,
  NetworkMonitor? networkMonitor,
}) async {
  final database = (openDatabase ?? openTrackLiteDatabase)();
  try {
    final saved = await database.metaDao.read(MetaKeys.backgroundConfig);
    if (saved == null) {
      // The app never initialized the SDK on this device: nothing to do.
      await database.close();
      return const NothingToSend();
    }
    final config = decodeConfig(saved)
        .withObjects(transport: transport, networkMonitor: networkMonitor);
    final client = await TrackLiteClientImpl.open(
      config,
      database: database,
      inBackground: true,
    );
    try {
      return await client.uploadInBackground();
    } finally {
      await client.shutdown();
    }
  } on Object catch (error, stackTrace) {
    developer.log(
      'background upload failed',
      name: 'TrackLite',
      error: error,
      stackTrace: stackTrace,
    );
    return Failed(reason: 'background upload failed: $error', remaining: 0);
  }
}
