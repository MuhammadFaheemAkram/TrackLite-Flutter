import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tracklite_sample/domain/shop/product.dart';

part 'product_state.freezed.dart';

@freezed
abstract class ProductState with _$ProductState {
  const factory ProductState({
    /// `null` when the link names no product.
    Product? product,

    /// A one-time SnackBar; [messageSerial] makes a repeat show again.
    String? message,
    @Default(0) int messageSerial,
  }) = _ProductState;
}
