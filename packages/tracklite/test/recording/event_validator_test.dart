import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/recording/event_validator.dart';

void main() {
  String? rejection(String name, [Map<String, Object> properties = const {}]) =>
      switch (validateEvent(name, properties)) {
        Rejected(:final reason) => reason,
        Valid() => null,
      };

  test('a valid event keeps its name, trimmed', () {
    expect(
      validateEvent('  purchase ', {'price': 20, 'gift': false, 'id': 'p'}),
      isA<Valid>().having((v) => v.name, 'name', 'purchase'),
    );
  });

  group('the name', () {
    test('blank is rejected', () {
      expect(rejection('   '), 'the name is blank');
    });

    test('64 characters pass, 65 do not', () {
      expect(rejection('a' * 64), isNull);
      expect(rejection('a' * 65), 'the name is longer than 64 characters');
    });
  });

  test('25 properties pass, 26 do not', () {
    Map<String, Object> props(int n) => {for (var i = 0; i < n; i++) 'k$i': i};

    expect(rejection('e', props(25)), isNull);
    expect(rejection('e', props(26)), '26 properties (at most 25)');
  });

  group('a property name', () {
    test('blank is rejected', () {
      expect(rejection('e', {' ': 1}), 'a property name is blank');
    });

    test('40 characters pass, 41 do not', () {
      expect(rejection('e', {'k' * 40: 1}), isNull);
      expect(
        rejection('e', {'k' * 41: 1}),
        'property "${'k' * 41}" has a name longer than 40 characters',
      );
    });

    test(r'starting with $ is reserved', () {
      expect(
        rejection('e', {r'$os': 'ios'}),
        r'property "$os" starts with "$", which is reserved for the SDK',
      );
    });
  });

  group('a property value', () {
    test('a String of 255 characters passes, 256 does not', () {
      expect(rejection('e', {'s': 'x' * 255}), isNull);
      expect(
        rejection('e', {'s': 'x' * 256}),
        'property "s" is longer than 255 characters',
      );
    });

    test('ints, doubles and bools pass', () {
      expect(rejection('e', {'i': -3, 'd': 12.5, 'b': true}), isNull);
    });

    for (final value in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      test('$value is not a finite number', () {
        expect(
          rejection('e', {'n': value}),
          'property "n" is not a finite number ($value)',
        );
      });
    }

    test('a list or a map is refused, by type', () {
      expect(
        rejection('e', {
          'l': const [1, 2],
        }),
        startsWith('property "l" is a List'),
      );
      expect(
        rejection('e', {
          'm': const {'a': 1},
        }),
        contains('(only String, num and bool)'),
      );
    });
  });
}
