import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // TrackLite's background upload. BGTaskScheduler delivers a task only to
    // a handler registered before launching finishes, so it is registered
    // here, not from Dart. The identifier is the SDK's task name
    // (`dev.tracklite.upload`), also listed in Info.plist; 15 minutes is the
    // earliest iOS may run it.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "dev.tracklite.upload",
      earliestBeginInSeconds: NSNumber(value: 15 * 60)
    )
    WorkmanagerPlugin.registerLaunchHandlers()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // The background upload runs in an engine of its own, which needs the
    // plugins too (the database's path, connectivity).
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
  }
}
