import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/books/book.dart';
import '../features/books/book_detail_page.dart';
import '../features/books/book_form_page.dart';
import '../features/books/book_providers.dart';
import '../features/books/widgets/progress_sheet.dart';
import '../features/goals/goal_providers.dart';
import '../features/home/home_page.dart';
import '../features/library/library_providers.dart';
import '../features/library/library_page.dart';
import '../features/stats/stats_page.dart';
import '../features/stats/stats_providers.dart';

class ShelfShell extends ConsumerStatefulWidget {
  const ShelfShell({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  ConsumerState<ShelfShell> createState() => _ShelfShellState();
}

class _ShelfShellState extends ConsumerState<ShelfShell> {
  int _selectedIndex = 0;

  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookDetailPage(bookId: book.id),
      ),
    );
  }

  Future<void> _showProgressSheet(Book book) async {
    await showProgressSheet(
      context: context,
      book: book,
      onUpdate: ref.read(bookDetailControllerProvider).updateBook,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentlyReading = ref.watch(currentlyReadingProvider);
    final recentlyFinished = ref.watch(recentlyFinishedProvider);
    final goal = ref.watch(activeReadingGoalProvider);
    final libraryFilter = ref.watch(libraryFilterProvider);
    final filteredBooks = ref.watch(filteredBooksProvider);
    final stats = ref.watch(readingStatsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomePage(
              currentlyReading: currentlyReading,
              recentlyFinished: recentlyFinished,
              goal: goal,
              finishedCount: stats.finishedThisYear,
              onOpenBook: _openBook,
              onUpdateProgress: _showProgressSheet,
              onSeeLibrary: () => setState(() => _selectedIndex = 1),
              onToggleTheme: widget.onToggleTheme,
            ),
            LibraryPage(
              books: filteredBooks,
              query: libraryFilter.query,
              filter: libraryFilter.status,
              sort: libraryFilter.sort,
              onQueryChanged: ref.read(libraryFilterProvider.notifier).setQuery,
              onFilterChanged: ref.read(libraryFilterProvider.notifier).setStatus,
              onSortChanged: ref.read(libraryFilterProvider.notifier).setSort,
              onOpenBook: _openBook,
              onAddBook: () => setState(() => _selectedIndex = 2),
            ),
            BookFormPage(
              onCancel: () => setState(() => _selectedIndex = 0),
              onSave: (book) {
                ref.read(bookFormControllerProvider).addBook(book);
                setState(() => _selectedIndex = 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Book added to your shelf')),
                );
              },
            ),
            StatsPage(
              goal: goal,
              onGoalChanged: ref.read(activeReadingGoalProvider.notifier).setGoal,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.library_books_outlined), selectedIcon: Icon(Icons.library_books_rounded), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.add_rounded), selectedIcon: Icon(Icons.add_rounded), label: 'Add book'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Stats'),
        ],
      ),
    );
  }
}
