import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/common/money.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/features/product/cubit/product_cubit.dart';
import 'package:tracklite_sample/features/product/cubit/product_state.dart';

/// One product, pushed inside the Shop tab.
class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductCubit>(param1: productId),
      child: const ProductView(),
    );
  }
}

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listenWhen: (before, after) =>
          after.messageSerial != before.messageSerial,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final product = state.product;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product')),
            body: const EmptyStateView(
              icon: Icons.search_off,
              title: 'Product not found',
              message: 'The shop has nothing at this link.',
            ),
          );
        }
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(product.name)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            children: [
              Text(
                formatPrice(product.priceCents, product.currency),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(product.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.large),
              FilledButton.icon(
                onPressed: context.read<ProductCubit>().buy,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Buy'),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Sends purchase with product_id, price and currency.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
