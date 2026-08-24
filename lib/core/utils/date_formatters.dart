String formatShelfDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '$day ${shortMonthName(date.month)} ${date.year}';
}

String shortMonthName(int month) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}
