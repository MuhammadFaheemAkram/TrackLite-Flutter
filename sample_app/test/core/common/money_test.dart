import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/core/common/money.dart';

void main() {
  test('formats whole cents with the currency symbol and two decimals', () {
    expect(formatPrice(1250, 'USD'), r'$12.50');
    expect(formatPrice(6500, 'USD'), r'$65.00');
    expect(formatPrice(5, 'USD'), r'$0.05');
  });
}
