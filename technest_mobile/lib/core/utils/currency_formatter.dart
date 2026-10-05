class CurrencyFormatter {
  /// Formats a number with thousands separators (e.g. 1,250.00 or 125,000.00)
  static String format(num price, {String prefix = 'Rs. '}) {
    final parts = price.toStringAsFixed(2).split('.');
    final isNegative = parts[0].startsWith('-');
    final cleanInt = isNegative ? parts[0].substring(1) : parts[0];
    final decimalPart = parts[1];

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = cleanInt.replaceAllMapped(reg, (Match m) => '${m[1]},');

    final resultInt = isNegative ? '-$formattedInt' : formattedInt;
    return '$prefix$resultInt.$decimalPart';
  }
}

/// Helper extension or top-level function for quick access
String formatPrice(num price, {String prefix = 'Rs. '}) {
  return CurrencyFormatter.format(price, prefix: prefix);
}
