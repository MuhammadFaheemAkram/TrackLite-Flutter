import 'dart:async';

import 'package:tracklite/tracklite.dart';

/// A host-side fake of the SDK's client and its debug tools: possible
/// because the SDK exposes interfaces, not only static calls.
class FakeClient implements TrackLiteClient {
  final calls = <String>[];
  FlushResult flushResult = const NothingToSend();
  final FakeDebug fakeDebug = FakeDebug();

  @override
  void track(String name, {Map<String, Object> properties = const {}}) =>
      calls.add('track $name $properties');

  @override
  void setUserId(String userId) => calls.add('setUserId $userId');

  @override
  void clearUser() => calls.add('clearUser');

  @override
  Future<FlushResult> flush() async => flushResult;

  @override
  Future<void> shutdown() async {}

  @override
  TrackLiteDebug get debug => fakeDebug;
}

class FakeDebug implements TrackLiteDebug {
  final stats = StreamController<TrackLiteStats>.broadcast();
  final recent = StreamController<List<TrackLiteEvent>>.broadcast();
  final uploads = StreamController<List<UploadRecord>>.broadcast();
  int retryFailedAnswer = 0;

  @override
  Stream<TrackLiteStats> watchStats() => stats.stream;

  @override
  Stream<List<TrackLiteEvent>> watchRecentEvents({int limit = 20}) =>
      recent.stream;

  @override
  Stream<List<UploadRecord>> watchUploads({int limit = 10}) => uploads.stream;

  @override
  Future<int> retryFailed() async => retryFailedAnswer;

  Future<void> dispose() =>
      Future.wait([stats.close(), recent.close(), uploads.close()]);
}
