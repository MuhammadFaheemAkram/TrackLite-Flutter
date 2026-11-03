import 'package:meta/meta.dart';

/// The names of the `meta` table's rows.
@internal
abstract final class MetaKeys {
  static const anonymousId = 'anonymous_id';
  static const userId = 'user_id';

  /// Running totals. Counters, not row counts: sent rows are pruned after
  /// a day, and a total must never go down because of that.
  static const trackedTotal = 'tracked_total';
  static const sentTotal = 'sent_total';
  static const droppedTotal = 'dropped_total';
  static const rejectedTotal = 'rejected_total';
}
