import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/sdk.dart';

void main() {
  test('watchStats: the counts and ids now, then after each change', () async {
    final db = TrackLiteDatabase.inMemory();
    final client = await openTestClient(database: db, maxQueue: 2);
    addTearDown(client.shutdown);
    final stats = client.debug.watchStats();

    expect(await stats.first, const TrackLiteStats(anonymousId: 'id-1'));

    client
      ..setUserId('user_123')
      ..track('a')
      ..track('b')
      ..track('c')
      ..track('');
    await client.idle;

    expect(
      await stats.first,
      const TrackLiteStats(
        anonymousId: 'id-1',
        userId: 'user_123',
        tracked: 3,
        pending: 2,
        dropped: 1,
        rejected: 1,
      ),
    );
  });

  test('stats equality, and every count defaults to 0', () {
    const stats = TrackLiteStats(anonymousId: 'a');

    expect(stats.tracked + stats.pending + stats.sending, 0);
    expect(stats.sent + stats.failed + stats.dropped + stats.rejected, 0);
    expect(stats, const TrackLiteStats(anonymousId: 'a'));
    expect(stats.hashCode, const TrackLiteStats(anonymousId: 'a').hashCode);
    expect(stats, isNot(const TrackLiteStats(anonymousId: 'a', failed: 1)));
    expect(stats.toString(), contains('anonymousId: a'));
  });
}
