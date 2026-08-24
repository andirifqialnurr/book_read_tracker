import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/core/theme/theme_providers.dart';
import 'package:shelf_book_tracker/domain/books/book.dart';
import 'package:shelf_book_tracker/domain/books/book_status.dart';
import 'package:shelf_book_tracker/features/books/book_providers.dart';
import 'package:shelf_book_tracker/features/goals/goal_providers.dart';
import 'package:shelf_book_tracker/features/library/library_filter.dart';
import 'package:shelf_book_tracker/features/library/library_providers.dart';
import 'package:shelf_book_tracker/features/stats/stats_providers.dart';

void main() {
  test('filteredBooksProvider applies query, status, and sort from provider state', () {
    final container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWith(
          (ref) => InMemoryBookRepository(initialBooks: const []),
        ),
      ],
    );
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

    container.read(bookRepositoryProvider.notifier)
      ..addBook(books[0])
      ..addBook(books[1])
      ..addBook(books[2]);

    var filtered = container.read(filteredBooksProvider);
    expect(filtered.map((book) => book.title), ['Tomorrow', 'Deep Work']);

    controller.setQuery('deep');
    filtered = container.read(filteredBooksProvider);
    expect(filtered.single.title, 'Deep Work');
  });

  test('booksPerMonthChartProvider counts finished books by month', () {
    final container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWith(
          (ref) => InMemoryBookRepository(initialBooks: const []),
        ),
      ],
    );
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

  test('readingStatsProvider summarizes active book state', () {
    final container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWith(
          (ref) => InMemoryBookRepository(initialBooks: const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(bookRepositoryProvider.notifier)
      ..addBook(
        Book(
          id: 1,
          title: 'Current Year',
          author: 'Reader',
          status: BookStatus.finished,
          currentPage: 220,
          genre: 'Fiction',
          rating: 4,
          finishedAt: DateTime(DateTime.now().year, 8, 2),
        ),
      )
      ..addBook(
        Book(
          id: 2,
          title: 'Past Year',
          author: 'Reader',
          status: BookStatus.finished,
          currentPage: 180,
          genre: 'Fiction',
          rating: 5,
          finishedAt: DateTime(DateTime.now().year - 1, 7, 2),
        ),
      )
      ..addBook(
        Book(
          id: 3,
          title: 'Active',
          author: 'Reader',
          status: BookStatus.reading,
          currentPage: 50,
          genre: 'Productivity',
        ),
      );

    final stats = container.read(readingStatsProvider);

    expect(stats.finishedThisYear, 1);
    expect(stats.totalPages, 450);
    expect(stats.averageRating, 4.5);
    expect(stats.favoriteGenre, 'Fiction');
    expect(stats.booksPerMonth[7], 1);
  });

  test('book repository provider supports add, update, lookup, and delete', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(bookRepositoryProvider.notifier);
    final book = Book(
      id: 99,
      title: 'Provider Book',
      author: 'Reader',
      status: BookStatus.wantToRead,
    );

    repository.addBook(book);
    expect(container.read(bookByIdProvider(99))?.title, 'Provider Book');

    repository.updateBook(book.copyWith(status: BookStatus.reading));
    expect(container.read(bookByIdProvider(99))?.status, BookStatus.reading);

    repository.deleteBook(99);
    expect(container.read(bookByIdProvider(99)), isNull);
  });

  test('home and goal providers expose derived reading state', () {
    final container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWith(
          (ref) => InMemoryBookRepository(initialBooks: const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(bookRepositoryProvider.notifier);
    repository
      ..addBook(
        Book(
          id: 1,
          title: 'Reading',
          author: 'Reader',
          status: BookStatus.reading,
        ),
      )
      ..addBook(
        Book(
          id: 2,
          title: 'Finished',
          author: 'Reader',
          status: BookStatus.finished,
        ),
      );

    expect(container.read(currentlyReadingProvider).single.title, 'Reading');
    expect(container.read(recentlyFinishedProvider).single.title, 'Finished');

    container.read(activeReadingGoalProvider.notifier).setGoal(36);
    expect(container.read(activeReadingGoalProvider), 36);
  });

  test('themeModeProvider toggles between light and dark mode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);

    container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.dark);

    container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
