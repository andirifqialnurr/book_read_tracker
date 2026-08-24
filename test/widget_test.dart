import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/app/shelf_app.dart';
import 'package:shelf_book_tracker/domain/books/book.dart';
import 'package:shelf_book_tracker/domain/books/book_status.dart';
import 'package:shelf_book_tracker/features/books/widgets/book_cover.dart';
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
}
