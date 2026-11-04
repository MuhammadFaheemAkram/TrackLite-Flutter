import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late List<String> chosen;
  setUp(() => chosen = []);

  Future<void> pump(WidgetTester tester, {required double textScale}) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    return tester.pumpThemed(
      SegmentedChoice<String>(
        values: const ['Fast', 'Normal', 'Slow'],
        labelOf: (value) => value,
        selected: 'Normal',
        onSelected: chosen.add,
      ),
    );
  }

  testWidgets('normal text: segments side by side', (tester) async {
    await pump(tester, textScale: 1);

    expect(find.byType(SegmentedButton<String>), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);

    await tester.tap(find.text('Slow'));
    expect(chosen, ['Slow']);
  });

  testWidgets('large text: chips that wrap, the same choice', (tester) async {
    await pump(tester, textScale: 2);

    expect(find.byType(SegmentedButton<String>), findsNothing);
    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
    expect([for (final chip in chips) chip.selected], [false, true, false]);

    await tester.tap(find.text('Slow'));
    expect(chosen, ['Slow']);
  });
}
