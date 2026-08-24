import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/domain/books/book.dart';
import 'package:shelf_book_tracker/domain/books/book_rules.dart';
import 'package:shelf_book_tracker/domain/books/book_status.dart';

void main() {
  test('Book progress returns null when total pages are unavailable', () {
    final book = Book(
      id: 1,
      title: 'Untitled',
      author: 'Unknown',
      status: BookStatus.reading,
      currentPage: 42,
    );

    expect(book.progress, isNull);
  });

  test('Book progress is clamped to the 0 to 1 range', () {
    final book = Book(
      id: 1,
      title: 'Untitled',
      author: 'Unknown',
      status: BookStatus.reading,
      currentPage: 250,
      totalPages: 100,
    );

    expect(book.currentPage, 100);
    expect(book.progress, 1);
  });

  test('Book rules clamp progress pages between zero and total pages', () {
    expect(BookRules.clampProgressPage(-12, totalPages: 300), 0);
    expect(BookRules.clampProgressPage(120, totalPages: 100), 100);
    expect(BookRules.clampProgressPage(120, totalPages: null), 120);
  });

  test('changing status preserves existing rating and review by default', () {
    final book = Book(
      id: 1,
      title: 'Untitled',
      author: 'Unknown',
      status: BookStatus.finished,
      rating: 4.5,
      review: 'Still worth keeping.',
    );

    final updated = book.copyWith(status: BookStatus.reading);

    expect(updated.rating, 4.5);
    expect(updated.review, 'Still worth keeping.');
  });
}
