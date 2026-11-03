import 'package:injectable/injectable.dart';
import 'package:tracklite_sample/domain/shop/product.dart';

/// The shop's products, in code: the sample is about the SDK, so there is no
/// shop backend.
@lazySingleton
class ProductCatalog {
  const ProductCatalog();

  static const _products = [
    Product(
      id: 'coffee-beans',
      name: 'Coffee beans',
      description: 'A 250 g bag of a medium roast, for every brewer.',
      priceCents: 1250,
    ),
    Product(
      id: 'travel-mug',
      name: 'Travel mug',
      description: 'Keeps coffee hot for four hours, and never leaks.',
      priceCents: 2400,
    ),
    Product(
      id: 'pour-over',
      name: 'Pour-over kit',
      description: 'A ceramic dripper, filters and a glass carafe.',
      priceCents: 3800,
    ),
    Product(
      id: 'grinder',
      name: 'Hand grinder',
      description:
          'Steel burrs and 30 grind settings, from espresso to cold '
          'brew.',
      priceCents: 6500,
    ),
  ];

  /// Every product, in the order the shop shows them.
  List<Product> get all => _products;

  /// The product with [id], or `null` (a stale link).
  Product? byId(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }
}
