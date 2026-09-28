import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculadora_estado/app.dart';

void main() {
  Future<void> enterNumbers(
    WidgetTester tester,
    String first,
    String second,
  ) async {
    await tester.enterText(find.byKey(const Key('firstNumberField')), first);
    await tester.enterText(find.byKey(const Key('secondNumberField')), second);
  }

  Future<void> selectOperation(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  String displayedResult(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('resultText'))).data!;

  testWidgets('calculates all four operations and accepts decimal comma', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    await enterNumbers(tester, '12,5', '2');

    await selectOperation(tester, '+  Somar');
    expect(displayedResult(tester), '14,5');

    await selectOperation(tester, '−  Subtrair');
    expect(displayedResult(tester), '10,5');

    await selectOperation(tester, '×  Multiplicar');
    expect(displayedResult(tester), '25');

    await selectOperation(tester, '÷  Dividir');
    expect(displayedResult(tester), '6,25');
  });

  testWidgets('validates input, handles division by zero, and clears state', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await selectOperation(tester, '+  Somar');
    expect(displayedResult(tester), 'Informe dois números válidos.');

    await enterNumbers(tester, '8', '0');
    await selectOperation(tester, '÷  Dividir');
    expect(displayedResult(tester), 'Não é possível dividir por zero.');

    await selectOperation(tester, '+  Somar');
    expect(displayedResult(tester), '8');

    await tester.tap(find.text('Limpar'));
    await tester.pump();
    expect(displayedResult(tester), 'O resultado aparecerá aqui.');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('firstNumberField')))
          .controller!
          .text,
      isEmpty,
    );
  });
}
