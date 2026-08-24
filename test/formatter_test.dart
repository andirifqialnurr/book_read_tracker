import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/core/utils/date_formatters.dart';
import 'package:shelf_book_tracker/core/utils/number_formatters.dart';

void main() {
  test('formatShelfDate keeps the compact day month year format', () {
    expect(formatShelfDate(DateTime(2026, 8, 7)), '07 Aug 2026');
    expect(shortMonthName(12), 'Dec');
  });

  test('formatCompactNumber keeps small numbers literal and thousands short', () {
    expect(formatCompactNumber(999), '999');
    expect(formatCompactNumber(1200), '1.2k');
  });
}
