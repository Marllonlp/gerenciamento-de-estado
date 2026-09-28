enum Operation {
  addition('Somar', '+'),
  subtraction('Subtrair', '−'),
  multiplication('Multiplicar', '×'),
  division('Dividir', '÷');

  const Operation(this.label, this.symbol);

  final String label;
  final String symbol;
}

class CalculationResult {
  const CalculationResult.success(this.expression, this.value) : error = null;
  const CalculationResult.failure(this.error) : expression = null, value = null;

  final String? expression;
  final String? value;
  final String? error;
}

CalculationResult calculate(
  String firstInput,
  String secondInput,
  Operation operation,
) {
  final first = _readNumber(firstInput);
  final second = _readNumber(secondInput);

  if (first == null || second == null) {
    return const CalculationResult.failure('Informe dois números válidos.');
  }
  if (operation == Operation.division && second == 0) {
    return const CalculationResult.failure('Não é possível dividir por zero.');
  }

  final double result = switch (operation) {
    Operation.addition => first + second,
    Operation.subtraction => first - second,
    Operation.multiplication => first * second,
    Operation.division => first / second,
  };

  if (!result.isFinite) {
    return const CalculationResult.failure('O resultado é grande demais.');
  }

  return CalculationResult.success(
    '${_formatNumber(first)} ${operation.symbol} ${_formatNumber(second)}',
    _formatNumber(result),
  );
}

double? _readNumber(String value) {
  final number = double.tryParse(value.trim().replaceAll(',', '.'));
  return number != null && number.isFinite ? number : null;
}

String _formatNumber(double value) {
  // Avoid floating point artifacts such as 0.30000000000000004.
  final rounded = double.parse(value.toStringAsPrecision(12));
  final text = rounded.toString();
  return (text.endsWith('.0') ? text.substring(0, text.length - 2) : text)
      .replaceAll('.', ',');
}
