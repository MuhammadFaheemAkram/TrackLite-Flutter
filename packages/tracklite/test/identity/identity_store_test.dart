import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/identity/identity_store.dart';
import 'package:tracklite/src/recording/event_recorder.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

import '../helpers/sdk.dart';

void main() {
  late TrackLiteDatabase db;
  late EventRecorder recorder;
  late SequentialIds ids;

  setUp(() {
    db = TrackLiteDatabase.inMemory();
    ids = SequentialIds();
    recorder = EventRecorder(
      database: db,
      maxQueueSize: 100,
      logger: LogRecorder().logger(),
      newId: ids.call,
    );
  });
  tearDown(() => db.close());

  Future<IdentityStore> load() =>
      IdentityStore.load(meta: db.metaDao, recorder: recorder, newId: ids.call);

  test('the first start creates an anonymous id and stores it', () async {
    final identity = await load();

    expect(identity.anonymousId, 'id-1');
    expect(identity.userId, isNull);
    expect(await db.metaDao.read(MetaKeys.anonymousId), 'id-1');
  });

  test('a later start reads the same identity back', () async {
    final first = await load();
    first.setUserId('user_123');
    await recorder.idle;

    final again = await load();

    expect(again.anonymousId, 'id-1');
    expect(again.userId, 'user_123');
  });

  test('clear removes the user and starts a new anonymous id', () async {
    final identity = await load()
      ..setUserId('user_123');

    identity.clear();

    expect(identity.userId, isNull);
    expect(identity.anonymousId, 'id-2');
    await recorder.idle;
    expect(await db.metaDao.read(MetaKeys.userId), isNull);
    expect(await db.metaDao.read(MetaKeys.anonymousId), 'id-2');
  });
}
