import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/app/shelf_app.dart';
import 'package:shelf_book_tracker/core/theme/app_colors.dart';
import 'package:shelf_book_tracker/domain/books/book.dart';
import 'package:shelf_book_tracker/domain/books/book_status.dart';
import 'package:shelf_book_tracker/features/books/widgets/book_cover.dart';
import 'package:shelf_book_tracker/features/books/widgets/progress_sheet.dart';
import 'package:shelf_book_tracker/features/books/book_providers.dart';
import 'package:shelf_book_tracker/features/goals/goal_providers.dart';

void main() {
  testWidgets('Shelf app renders the home shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookRepositoryProvider.overrideWith(
            (ref) => InMemoryBookRepository(initialBooks: const []),
          ),
          activeReadingGoalProvider.overrideWith(
            (ref) => ReadingGoalController(),
          ),
        ],
        child: const ShelfApp(),
      ),
    );

    expect(find.text('Currently reading'), findsOneWidget);
    expect(find.text('2026 reading goal'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('BookCover falls back when the local cover file is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookCover(
            book: Book(
              id: 1,
              title: 'Missing Cover',
              author: 'Reader',
              status: BookStatus.wantToRead,
              coverUri: 'C:\\missing\\cover.jpg',
            ),
            width: 120,
            height: 160,
          ),
        ),
      ),
    );

    expect(find.text('Missing Cover'), findsOneWidget);
    expect(find.text('Reader'), findsOneWidget);
  });

  testWidgets('BookCover fallback color follows book status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookCover(
            book: Book(
              id: 1,
              title: 'Finished Cover',
              author: 'Reader',
              status: BookStatus.finished,
            ),
            width: 120,
            height: 160,
          ),
        ),
      ),
    );

    final cover = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) {
          return false;
        }
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.gradient is LinearGradient;
      }).first,
    );
    final decoration = cover.decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;

    expect(gradient.colors.first, AppColors.coverGreen);
  });

  testWidgets('recently finished list is wrapped in a bordered card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookRepositoryProvider.overrideWith(
            (ref) => InMemoryBookRepository(
              initialBooks: [
                Book(
                  id: 1,
                  title: 'Finished Book',
                  author: 'Reader',
                  status: BookStatus.finished,
                  finishedAt: DateTime(2026, 8, 24),
                ),
              ],
            ),
          ),
          activeReadingGoalProvider.overrideWith(
            (ref) => ReadingGoalController(),
          ),
        ],
        child: const ShelfApp(),
      ),
    );

    expect(find.byKey(const Key('recently_finished_card')), findsOneWidget);
    expect(find.text('Finished Book'), findsWidgets);
  });

  testWidgets('progress sheet increments by one before saving', (
    WidgetTester tester,
  ) async {
    Book? updatedBook;
    final book = Book(
      id: 1,
      title: 'Progress Book',
      author: 'Reader',
      status: BookStatus.reading,
      currentPage: 12,
      totalPages: 100,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                showProgressSheet(
                  context: context,
                  book: book,
                  onUpdate: (updated) async {
                    updatedBook = updated;
                  },
                );
              },
              child: const Text('Open progress'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open progress'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('12'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save progress'));
    await tester.pumpAndSettle();

    expect(updatedBook?.currentPage, 13);
    expect(find.text('Update progress'), findsNothing);
  });

  testWidgets('progress sheet allows manual input after tapping the page number', (
    WidgetTester tester,
  ) async {
    Book? updatedBook;
    final book = Book(
      id: 1,
      title: 'Progress Book',
      author: 'Reader',
      status: BookStatus.reading,
      currentPage: 12,
      totalPages: 100,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                showProgressSheet(
                  context: context,
                  book: book,
                  onUpdate: (updated) async {
                    updatedBook = updated;
                  },
                );
              },
              child: const Text('Open progress'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '250');
    await tester.tap(find.text('Save progress'));
    await tester.pumpAndSettle();

    expect(updatedBook?.currentPage, 100);
    expect(find.text('Update progress'), findsNothing);
  });
}
