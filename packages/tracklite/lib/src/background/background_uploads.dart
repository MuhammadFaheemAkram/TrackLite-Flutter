import 'package:meta/meta.dart';
import 'package:workmanager/workmanager.dart';

/// The periodic background task's name, on both platforms: the WorkManager
/// job and the iOS `BGTaskScheduler` identifier, which the host app lists in
/// `Info.plist` and registers in `AppDelegate`.
@internal
const backgroundTaskName = 'dev.tracklite.upload';

/// How often the OS is asked to run it: 15 minutes is Android's minimum,
/// and iOS treats it as the earliest.
@internal
const backgroundFrequency = Duration(minutes: 15);

/// Registers (or cancels) the periodic background upload.
@internal
abstract interface class BackgroundUploads {
  Future<void> enable();

  Future<void> disable();
}

/// Background uploads with `workmanager`: Android's WorkManager and iOS's
/// `BGTaskScheduler` behind one API.
///
/// The OS decides when the task runs (Doze, App Standby and iOS's own
/// judgement defer it); it only runs with a network. Registered without an
/// initial delay, so the first run comes soon after install
/// (conventions §11.66).
@internal
final class WorkmanagerUploads implements BackgroundUploads {
  WorkmanagerUploads(this._dispatcher);

  /// The top-level function the OS starts the task in.
  final void Function() _dispatcher;

  @override
  Future<void> enable() async {
    final workmanager = Workmanager();
    await workmanager.initialize(_dispatcher);
    await workmanager.registerPeriodicTask(
      backgroundTaskName,
      backgroundTaskName,
      frequency: backgroundFrequency,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  @override
  Future<void> disable() =>
      Workmanager().cancelByUniqueName(backgroundTaskName);
}
