import 'package:flutter/material.dart';

import 'calculator_logic.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _maxDigits = 15;

  String _display = '0'; // número que está sendo digitado / resultado
  String _expression = ''; // ex.: "12 + "
  String? _firstOperand;
  Operation? _operation;
  bool _startNewNumber = false;
  String? _error;

  void _reset() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _operation = null;
    _startNewNumber = false;
    _error = null;
  }

  void _showError(String message) {
    _reset();
    _error = message;
  }

  // ---------- Ações do teclado ----------

  void _onDigit(String digit) {
    setState(() {
      if (_error != null) _reset();
      if (_startNewNumber || _display == '0') {
        _display = digit;
        _startNewNumber = false;
      } else if (_display.replaceAll(RegExp(r'[-,]'), '').length < _maxDigits) {
        _display += digit;
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (_error != null) _reset();
      if (_startNewNumber) {
        _display = '0,';
        _startNewNumber = false;
      } else if (!_display.contains(',')) {
        _display += ',';
      }
    });
  }

  void _onOperation(Operation operation) {
    setState(() {
      if (_error != null) _reset();

      // Encadeamento: 2 + 3 × ... calcula 2 + 3 antes de continuar.
      if (_firstOperand != null && _operation != null && !_startNewNumber) {
        final result = calculate(_firstOperand!, _display, _operation!);
        if (result.error != null) {
          _showError(result.error!);
          return;
        }
        _display = result.value!;
      }

      _firstOperand = _display;
      _operation = operation;
      _expression = '$_display ${operation.symbol}';
      _startNewNumber = true;
    });
  }

  void _onEquals() {
    final first = _firstOperand;
    final operation = _operation;
    if (first == null || operation == null) return;

    setState(() {
      final result = calculate(first, _display, operation);
      if (result.error != null) {
        _showError(result.error!);
        return;
      }
      _expression = '${result.expression} =';
      _display = result.value!;
      _firstOperand = null;
      _operation = null;
      _startNewNumber = true;
    });
  }

  void _onClear() => setState(_reset);

  void _onBackspace() {
    if (_error != null) return _onClear();
    if (_startNewNumber) return;
    setState(() {
      _display = _display.length > 1 ? _display.substring(0, _display.length - 1) : '0';
      if (_display == '-') _display = '0';
    });
  }


  // ---------- Interface ----------

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _buildDisplay(colors, textTheme)),
                  const SizedBox(height: 16),
                  _buildKeypad(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay(ColorScheme colors, TextTheme textTheme) {
    final hasError = _error != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _expression,
            style: textTheme.titleLarge?.copyWith(
              color: colors.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _error ?? _display,
              key: const Key('resultText'),
              maxLines: 1,
              style: hasError
                  ? textTheme.titleLarge?.copyWith(color: colors.error)
                  : textTheme.displayMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _row([
          _key('C', _onClear, type: _KeyType.action),
          _key('⌫', _onBackspace, type: _KeyType.action),
          _operationKey(Operation.division),
        ]),
        _row([
          _digitKey('7'),
          _digitKey('8'),
          _digitKey('9'),
          _operationKey(Operation.multiplication),
        ]),
        _row([
          _digitKey('4'),
          _digitKey('5'),
          _digitKey('6'),
          _operationKey(Operation.subtraction),
        ]),
        _row([
          _digitKey('1'),
          _digitKey('2'),
          _digitKey('3'),
          _operationKey(Operation.addition),
        ]),
        _row([
          _digitKey('0', flex: 2),
          _key(',', _onDecimal),
          _key('=', _onEquals, type: _KeyType.equals),
        ]),
      ],
    );
  }

  Widget _row(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(height: 68, child: Row(children: children)),
    );
  }

  Widget _digitKey(String digit, {int flex = 1}) =>
      _key(digit, () => _onDigit(digit), flex: flex);

  Widget _operationKey(Operation operation) {
    final selected = _operation == operation && _startNewNumber;
    return _key(
      operation.symbol,
      () => _onOperation(operation),
      type: _KeyType.operation,
      selected: selected,
    );
  }

  Widget _key(
    String label,
    VoidCallback onPressed, {
    _KeyType type = _KeyType.number,
    bool selected = false,
    int flex = 1,
  }) {
    final colors = Theme.of(context).colorScheme;

    final (background, foreground) = switch (type) {
      _KeyType.number => (colors.surfaceContainerHighest, colors.onSurface),
      _KeyType.action => (colors.secondaryContainer, colors.onSecondaryContainer),
      _KeyType.operation => selected
          ? (colors.primary, colors.onPrimary)
          : (colors.tertiaryContainer, colors.onTertiaryContainer),
      _KeyType.equals => (colors.primary, colors.onPrimary),
    };

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

enum _KeyType { number, action, operation, equals }