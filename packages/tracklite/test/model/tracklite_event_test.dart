import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';

void main() {
  final event = TrackLiteEvent(
    id: 'e1',
    name: 'purchase',
    timestamp: DateTime.utc(2026, 11, 3, 9, 41),
    anonymousId: 'anon-1',
    userId: 'user_123',
    properties: const {'price': 20, 'currency': 'USD', 'gift': false},
    status: EventStatus.pending,
  );

  test('a new event has no attempts, retry time or error', () {
    expect(event.attempts, 0);
    expect(event.nextAttemptAt, isNull);
    expect(event.lastError, isNull);
  });

  test('equal by value, including the properties in any order', () {
    final same = TrackLiteEvent(
      id: 'e1',
      name: 'purchase',
      timestamp: DateTime.utc(2026, 11, 3, 9, 41),
      anonymousId: 'anon-1',
      userId: 'user_123',
      properties: const {'gift': false, 'currency': 'USD', 'price': 20},
      status: EventStatus.pending,
    );

    expect(same, event);
    expect(same.hashCode, event.hashCode);
  });

  test('any field makes a difference', () {
    TrackLiteEvent copy({
      String id = 'e1',
      Map<String, Object> properties = const {
        'price': 20,
        'currency': 'USD',
        'gift': false,
      },
      EventStatus status = EventStatus.pending,
      int attempts = 0,
      String? lastError,
    }) => TrackLiteEvent(
      id: id,
      name: 'purchase',
      timestamp: DateTime.utc(2026, 11, 3, 9, 41),
      anonymousId: 'anon-1',
      userId: 'user_123',
      properties: properties,
      status: status,
      attempts: attempts,
      lastError: lastError,
    );

    expect(copy(), event);
    expect(copy(id: 'e2'), isNot(event));
    expect(copy(properties: const {'price': 21}), isNot(event));
    expect(copy(status: EventStatus.sent), isNot(event));
    expect(copy(attempts: 1), isNot(event));
    expect(copy(lastError: '500'), isNot(event));
  });

  test('toString names it, its status and its properties', () {
    expect(
      event.toString(),
      'TrackLiteEvent(purchase, pending, id: e1, attempts: 0, '
      'properties: {price: 20, currency: USD, gift: false})',
    );
  });
}
