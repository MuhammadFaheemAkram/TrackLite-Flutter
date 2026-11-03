import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/common/money.dart';
import 'package:tracklite_sample/core/navigation/app_routes.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/shop/product.dart';
import 'package:tracklite_sample/domain/shop/product_catalog.dart';

/// The Shop tab: the catalog. It's fixed, in code, so no Cubit: the Page
/// reads it once and hands it to the View.
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) =>
      ShopView(products: getIt<ProductCatalog>().all);
}

class ShopView extends StatelessWidget {
  const ShopView({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: ListView(
        children: [
          for (final product in products)
            ListTile(
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Text(
                formatPrice(product.priceCents, product.currency),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onTap: () =>
                  ProductRoute(productId: product.id).push<void>(context),
            ),
        ],
      ),
    );
  }
}
