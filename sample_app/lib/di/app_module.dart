import 'package:injectable/injectable.dart';
import 'package:tracklite/tracklite.dart';

/// Registrations for objects the app doesn't construct itself.
@module
abstract class AppModule {
  /// The SDK's client, started in `main()` with `TrackLite.initialize`
  /// before anything resolves it. Registering it lets the adapter receive
  /// it through its constructor, like any other dependency.
  @lazySingleton
  TrackLiteClient get trackLite => TrackLite.instance;
}
