import 'package:meta/meta.dart';
import 'package:tracklite/src/recording/event_recorder.dart';
import 'package:tracklite/src/storage/meta_dao.dart';
import 'package:tracklite/src/storage/meta_keys.dart';

/// Who the events are about: the signed-in user (if any) and the
/// installation's anonymous id.
///
/// Both live in memory, so `track()` stamps them without a query, and in
/// `meta`, so they survive a restart. Changes are written through the
/// recorder's queue, in order with the events around them.
@internal
final class IdentityStore {
  IdentityStore._(this._recorder, this._newId, this._userId, this._anonymousId);

  /// Reads the stored identity, creating (and storing) an anonymous id on
  /// the first start.
  static Future<IdentityStore> load({
    required MetaDao meta,
    required EventRecorder recorder,
    required String Function() newId,
  }) async {
    final userId = await meta.read(MetaKeys.userId);
    var anonymousId = await meta.read(MetaKeys.anonymousId);
    if (anonymousId == null) {
      anonymousId = newId();
      await meta.write(MetaKeys.anonymousId, anonymousId);
    }
    return IdentityStore._(recorder, newId, userId, anonymousId);
  }

  final EventRecorder _recorder;
  final String Function() _newId;
  String? _userId;
  String _anonymousId;

  String? get userId => _userId;

  String get anonymousId => _anonymousId;

  void setUserId(String userId) {
    _userId = userId;
    _recorder.enqueue(SetMeta(MetaKeys.userId, userId));
  }

  /// Signs the user out of the events: no user id, and a **new** anonymous
  /// id. Keeping the old one would link the next person on this device to
  /// the last one (what Amplitude's `reset()` and Mixpanel's do too).
  void clear() {
    _userId = null;
    _anonymousId = _newId();
    _recorder
      ..enqueue(const SetMeta(MetaKeys.userId, null))
      ..enqueue(SetMeta(MetaKeys.anonymousId, _anonymousId));
  }
}
