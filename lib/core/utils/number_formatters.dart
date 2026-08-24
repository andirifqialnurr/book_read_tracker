String formatCompactNumber(int value) {
  if (value < 1000) return '$value';
  return '${(value / 1000).toStringAsFixed(1)}k';
}
