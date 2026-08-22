String formatPrice(double price, String currency) {
  final symbol = currency == 'USD' ? '\$' : '₹';
  // Show whole numbers without decimals, otherwise up to 2 decimal places
  final text = price == price.roundToDouble()
      ? price.toInt().toString()
      : price.toStringAsFixed(2);
  return '$symbol$text';
}
