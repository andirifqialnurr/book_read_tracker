import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/domain/books/book.dart';
import 'package:shelf_book_tracker/domain/books/book_status.dart';
import 'package:shelf_book_tracker/features/library/library_filter.dart';
import 'package:shelf_book_tracker/features/library/library_providers.dart';
import 'package:shelf_book_tracker/features/stats/stats_providers.dart';

void main() {
  test('filteredBooksProvider applies query, status, and sort from provider state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final books = [
      Book(
        id: 1,
        title: 'Deep Work',
        author: 'Cal Newport',
        status: BookStatus.finished,
        rating: 4,
      ),
      Book(
        id: 2,
        title: 'The Creative Act',
        author: 'Rick Rubin',
        status: BookStatus.reading,
      ),
      Book(
        id: 3,
        title: 'Tomorrow',
        author: 'Gabrielle Zevin',
        status: BookStatus.finished,
        rating: 5,
      ),
    ];

    final controller = container.read(libraryFilterProvider.notifier);
    controller.setStatus(BookStatus.finished);
    controller.setSort(LibrarySort.rating);

    var filtered = container.read(filteredBooksProvider(books));
    expect(filtered.map((book) => book.title), ['Tomorrow', 'Deep Work']);

    controller.setQuery('deep');
    filtered = container.read(filteredBooksProvider(books));
    expect(filtered.single.title, 'Deep Work');
  });

  test('booksPerMonthChartProvider counts finished books by month', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final books = [
      Book(
        id: 1,
        title: 'May One',
        author: 'Reader',
        status: BookStatus.finished,
        finishedAt: DateTime(DateTime.now().year, 5, 2),
      ),
      Book(
        id: 2,
        title: 'May Two',
        author: 'Reader',
        status: BookStatus.finished,
        finishedAt: DateTime(DateTime.now().year, 5, 18),
      ),
      Book(
        id: 3,
        title: 'Reading',
        author: 'Reader',
        status: BookStatus.reading,
      ),
    ];

    final values = container.read(booksPerMonthChartProvider(books));

    expect(values[4], 2);
    expect(values.where((value) => value > 0), [2]);
  });
}
