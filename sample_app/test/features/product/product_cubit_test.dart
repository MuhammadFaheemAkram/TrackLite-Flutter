import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/shop/product_catalog.dart';
import 'package:tracklite_sample/features/product/cubit/product_cubit.dart';
import 'package:tracklite_sample/features/product/cubit/product_state.dart';

import '../../helpers/recording_analytics.dart';

void main() {
  const catalog = ProductCatalog();
  late RecordingAnalytics analytics;

  setUp(() => analytics = RecordingAnalytics());

  test('starts with the product, or none for a stale id', () {
    expect(
      ProductCubit('grinder', catalog, analytics).state.product,
      catalog.byId('grinder'),
    );
    expect(ProductCubit('teapot', catalog, analytics).state.product, isNull);
  });

  blocTest<ProductCubit, ProductState>(
    'Buy tracks a purchase with its id, price and currency, and says so',
    build: () => ProductCubit('coffee-beans', catalog, analytics),
    act: (cubit) => cubit
      ..buy()
      ..buy(),
    expect: () => [
      ProductState(
        product: catalog.byId('coffee-beans'),
        message: 'Purchase tracked: Coffee beans',
        messageSerial: 1,
      ),
      ProductState(
        product: catalog.byId('coffee-beans'),
        message: 'Purchase tracked: Coffee beans',
        messageSerial: 2,
      ),
    ],
    verify: (_) => expect(analytics.events, [
      for (var i = 0; i < 2; i++)
        const Tracked('purchase', {
          'product_id': 'coffee-beans',
          'price': 12.5,
          'currency': 'USD',
        }),
    ]),
  );

  blocTest<ProductCubit, ProductState>(
    'Buy does nothing without a product',
    build: () => ProductCubit('teapot', catalog, analytics),
    act: (cubit) => cubit.buy(),
    expect: () => const <ProductState>[],
    verify: (_) => expect(analytics.events, isEmpty),
  );
}
