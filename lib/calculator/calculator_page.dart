import 'package:flutter/material.dart';

import 'calculator_logic.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _firstController = TextEditingController();
  final _secondController = TextEditingController();

  CalculationResult? _calculation;

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _clearOutput() {
    if (_calculation == null) return;
    setState(() => _calculation = null);
  }

  void _clearAll() {
    _firstController.clear();
    _secondController.clear();
    setState(() => _calculation = null);
  }

  void _calculate(Operation operation) {
    setState(() {
      _calculation = calculate(
        _firstController.text,
        _secondController.text,
        operation,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final calculation = _calculation;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Quatro operações', style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Digite dois números e escolha uma operação.',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const Key('firstNumberField'),
                    controller: _firstController,
                    onChanged: (_) => _clearOutput(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Primeiro número',
                      hintText: 'Ex.: 12,5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('secondNumberField'),
                    controller: _secondController,
                    onChanged: (_) => _clearOutput(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Segundo número',
                      hintText: 'Ex.: 3',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Operação', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final row in [
                    [Operation.addition, Operation.subtraction],
                    [Operation.multiplication, Operation.division],
                  ]) ...[
                    Row(
                      children: [
                        for (final operation in row) ...[
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _calculate(operation),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  '${operation.symbol}  ${operation.label}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          if (operation == row.first) const SizedBox(width: 12),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resultado', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (calculation?.expression != null)
                          Text(
                            calculation!.expression!,
                            style: textTheme.bodyLarge,
                          ),
                        Text(
                          calculation?.error ??
                              calculation?.value ??
                              'O resultado aparecerá aqui.',
                          key: const Key('resultText'),
                          style: calculation?.error != null
                              ? textTheme.bodyLarge?.copyWith(
                                  color: colors.error,
                                )
                              : textTheme.headlineMedium?.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
