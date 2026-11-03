import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/domain/shop/product_catalog.dart';
import 'package:tracklite_sample/features/product/cubit/product_state.dart';

/// One product, and Buy: it tracks a `purchase` with the product's id, its
/// price and its currency (a real shop would track it after the payment).
@injectable
class ProductCubit extends Cubit<ProductState> {
  ProductCubit(
    @factoryParam String productId,
    ProductCatalog catalog,
    this._analytics,
  ) : super(ProductState(product: catalog.byId(productId)));

  final AnalyticsService _analytics;

  void buy() {
    final product = state.product;
    if (product == null) return;
    _analytics.track(
      'purchase',
      properties: {
        'product_id': product.id,
        'price': product.price,
        'currency': product.currency,
      },
    );
    emit(
      state.copyWith(
        message: 'Purchase tracked: ${product.name}',
        messageSerial: state.messageSerial + 1,
      ),
    );
  }
}
