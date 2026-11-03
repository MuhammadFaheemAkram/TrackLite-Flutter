import 'package:meta/meta.dart';

/// The names of the `meta` table's rows.
@internal
abstract final class MetaKeys {
  static const anonymousId = 'anonymous_id';
  static const userId = 'user_id';

  /// Running totals. Counters, not row counts: rows are pruned later
  /// (Phase 3), and a total must never go down because of that.
  static const trackedTotal = 'tracked_total';
  static const droppedTotal = 'dropped_total';
  static const rejectedTotal = 'rejected_total';
}
