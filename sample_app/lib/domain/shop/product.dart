import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

/// Something the sample's shop sells. Buying it tracks a `purchase`.
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    // Whole cents, never a double: money must add up exactly.
    required int priceCents,
    @Default('USD') String currency,
  }) = _Product;

  const Product._();

  /// The price as a decimal number, the way the `purchase` event sends it.
  num get price => priceCents / 100;
}
