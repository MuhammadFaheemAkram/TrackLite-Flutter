import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/storage/event_mapper.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/sdk.dart';

void main() {
  test('properties round-trip as they were: ints stay ints', () {
    const properties = {'count': 3, 'price': 12.5, 'gift': true, 'id': 'p'};

    final decoded = decodeProperties(encodeProperties(properties));

    expect(decoded, properties);
    expect(decoded['count'], isA<int>());
    expect(decoded['price'], isA<double>());
  });

  test('a row becomes the public event', () {
    final row = EventRow(
      seq: 7,
      id: 'e1',
      name: 'purchase',
      timestamp: testNow,
      userId: 'user_123',
      anonymousId: 'anon',
      properties: '{"price":20}',
      status: 'failed',
      attempts: 5,
      nextAttemptAt: testNow,
      lastError: 'Server error 500',
    );

    expect(
      row.toEvent(),
      TrackLiteEvent(
        id: 'e1',
        name: 'purchase',
        timestamp: testNow,
        userId: 'user_123',
        anonymousId: 'anon',
        properties: const {'price': 20},
        status: EventStatus.failed,
        attempts: 5,
        nextAttemptAt: testNow,
        lastError: 'Server error 500',
      ),
    );
  });
}
