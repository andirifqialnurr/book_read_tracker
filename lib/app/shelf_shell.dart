import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_text_styles.dart';
import '../domain/books/book.dart';
import '../domain/books/book_rules.dart';
import '../domain/books/book_status.dart';
import '../features/books/book_detail_page.dart';
import '../features/books/book_form_page.dart';
import '../features/books/book_providers.dart';
import '../features/goals/goal_providers.dart';
import '../features/home/home_page.dart';
import '../features/library/library_providers.dart';
import '../features/library/library_page.dart';
import '../features/stats/stats_page.dart';

class ShelfShell extends ConsumerStatefulWidget {
  const ShelfShell({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  ConsumerState<ShelfShell> createState() => _ShelfShellState();
}

class _ShelfShellState extends ConsumerState<ShelfShell> {
  int _selectedIndex = 0;
  int _finishedThisYear(List<Book> books) => books.where((book) {
        return book.status == BookStatus.finished &&
            book.finishedAt?.year == DateTime.now().year;
      }).length;

  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookDetailPage(
          book: book,
          onUpdate: (updated) {
            ref.read(bookRepositoryProvider.notifier).updateBook(updated);
          },
          onDelete: () {
            ref.read(bookRepositoryProvider.notifier).deleteBook(book.id);
          },
        ),
      ),
    );
  }

  void _addBook(Book book) {
    ref.read(bookRepositoryProvider.notifier).addBook(book);
    setState(() => _selectedIndex = 1);
  }

  void _showProgressSheet(Book book) {
    final controller = TextEditingController(text: '${book.currentPage}');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Update your progress',
                style: AppTextStyles.editorial(context, 24),
              ),
              const SizedBox(height: 6),
              Text(book.title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 22),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current page',
                  suffixText: 'pages',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final page = int.tryParse(controller.text) ?? book.currentPage;
                    final safePage = BookRules.clampProgressPage(
                      page,
                      totalPages: book.totalPages,
                    );
                    ref
                        .read(bookRepositoryProvider.notifier)
                        .updateBook(book.copyWith(currentPage: safePage));
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Save progress'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final currentlyReading = ref.watch(currentlyReadingProvider);
    final recentlyFinished = ref.watch(recentlyFinishedProvider);
    final goal = ref.watch(activeReadingGoalProvider);
    final libraryFilter = ref.watch(libraryFilterProvider);
    final filteredBooks = ref.watch(filteredBooksProvider);
    final finishedThisYear = _finishedThisYear(books);
    final pages = books.fold<int>(0, (sum, book) => sum + book.currentPage);
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
              finishedCount: finishedThisYear,
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
                _addBook(book);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Book added to your shelf')),
                );
              },
            ),
            StatsPage(
              books: books,
              goal: goal,
              finishedCount: finishedThisYear,
              totalPages: pages,
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
