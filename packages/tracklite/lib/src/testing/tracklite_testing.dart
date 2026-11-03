import 'package:tracklite/src/storage/tracklite_database.dart';

/// Switches for an app's own tests (`package:tracklite/testing.dart`).
///
/// A widget test has no documents directory and no SQLite file to open. An
/// app whose tests start the real SDK (`TrackLite.initialize`) calls
/// [useInMemoryDatabase] first: each start then gets a fresh database in
/// memory, gone when the test ends.
abstract final class TrackLiteTesting {
  /// Starts from now keep their events in memory.
  static void useInMemoryDatabase() =>
      openTrackLiteDatabase = TrackLiteDatabase.inMemory;

  /// Starts from now use the file on the device again (the default).
  static void useDeviceDatabase() =>
      openTrackLiteDatabase = TrackLiteDatabase.onDevice;
}
