import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/config/tracklite_config.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';

/// The SDK as an object: what the `TrackLite` facade forwards to.
///
/// Most apps use the facade. An app with dependency injection can register
/// the client instead (`TrackLite.instance`, or one from [create]) and
/// depend on this interface, so its tests can pass a fake.
///
/// Nothing here throws at runtime: [track], [setUserId] and [clearUser]
/// return at once, and the async methods report their outcome.
abstract interface class TrackLiteClient {
  /// Starts a client with [config].
  ///
  /// Throws an [ArgumentError] if [config] breaks a rule: a developer's
  /// mistake, reported in development rather than hidden.
  static Future<TrackLiteClient> create(TrackLiteConfig config) async {
    config.validate();
    // The composition root: the SDK has no DI container (it would become
    // every host's dependency), so the parts are wired by hand, here.
    return TrackLiteClientImpl(
      config: config,
      logger: TrackLiteLogger(enabled: config.debugMode),
    );
  }

  /// Records an event named [name] with its [properties], and returns at
  /// once. Values are `String`, finite `num` or `bool`.
  void track(String name, {Map<String, Object> properties = const {}});

  /// Attaches [userId] to the events tracked from now on.
  void setUserId(String userId);

  /// Stops attaching a user id, for example when the user signs out.
  void clearUser();

  /// Uploads every pending event now, and says what happened.
  Future<FlushResult> flush();

  /// Stops the client. Later calls are ignored, and stored events wait for
  /// the next start.
  Future<void> shutdown();
}
