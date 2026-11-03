import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracklite_sample/domain/shop/product_catalog.dart';
import 'package:tracklite_sample/features/product/cubit/product_cubit.dart';
import 'package:tracklite_sample/features/product/cubit/product_state.dart';
import 'package:tracklite_sample/features/product/product_page.dart';

class _MockProductCubit extends MockCubit<ProductState>
    implements ProductCubit {}

void main() {
  final grinder = const ProductCatalog().byId('grinder');
  late _MockProductCubit cubit;

  setUp(() => cubit = _MockProductCubit());

  Future<void> pump(
    WidgetTester tester,
    ProductState state, {
    Stream<ProductState>? states,
  }) {
    whenListen(
      cubit,
      states ?? const Stream<ProductState>.empty(),
      initialState: state,
    );
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductCubit>.value(
          value: cubit,
          child: const ProductView(),
        ),
      ),
    );
  }

  testWidgets('shows the product, its price and what Buy sends', (
    tester,
  ) async {
    await pump(tester, ProductState(product: grinder));

    expect(find.widgetWithText(AppBar, 'Hand grinder'), findsOneWidget);
    expect(find.text(r'$65.00'), findsOneWidget);
    expect(find.textContaining('Steel burrs'), findsOneWidget);
    expect(
      find.text('Sends purchase with product_id, price and currency.'),
      findsOneWidget,
    );
  });

  testWidgets('Buy goes to the Cubit', (tester) async {
    await pump(tester, ProductState(product: grinder));

    await tester.tap(find.text('Buy'));

    verify(() => cubit.buy()).called(1);
  });

  testWidgets('a new message shows a SnackBar; the same one again does not', (
    tester,
  ) async {
    final before = ProductState(product: grinder);
    final after = before.copyWith(
      message: 'Purchase tracked: Hand grinder',
      messageSerial: 1,
    );
    final states = StreamController<ProductState>();
    addTearDown(states.close);
    await pump(tester, before, states: states.stream);
    final snackBar = find.widgetWithText(
      SnackBar,
      'Purchase tracked: Hand grinder',
    );

    states.add(after);
    await tester.pump();
    expect(snackBar, findsOneWidget);

    ScaffoldMessenger.of(tester.element(snackBar)).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    expect(snackBar, findsNothing);

    // Any rebuild with the same message (same serial) must not repeat it.
    states.add(after.copyWith(product: grinder));
    await tester.pumpAndSettle();
    expect(snackBar, findsNothing);
  });

  testWidgets('without a product: "Product not found"', (tester) async {
    await pump(tester, const ProductState());

    expect(find.text('Product not found'), findsOneWidget);
    expect(find.text('Buy'), findsNothing);
  });
}
