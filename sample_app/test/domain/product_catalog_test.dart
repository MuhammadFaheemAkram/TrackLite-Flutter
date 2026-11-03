import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/shop/product.dart';
import 'package:tracklite_sample/domain/shop/product_catalog.dart';

void main() {
  const catalog = ProductCatalog();

  test('four products, each with a unique id and a positive price', () {
    expect(catalog.all, hasLength(4));
    expect(catalog.all.map((p) => p.id).toSet(), hasLength(4));
    expect(catalog.all.every((p) => p.priceCents > 0), isTrue);
  });

  test('byId finds a product, or nothing for a stale id', () {
    expect(catalog.byId('travel-mug')?.name, 'Travel mug');
    expect(catalog.byId('teapot'), isNull);
  });

  test('the price an event sends is the cents as a decimal', () {
    const product = Product(
      id: 'p',
      name: 'P',
      description: 'd',
      priceCents: 1250,
    );

    expect(product.price, 12.5);
    expect(product.currency, 'USD');
  });
}
