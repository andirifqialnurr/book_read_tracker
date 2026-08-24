import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../domain/books/book.dart';
import '../domain/books/book_rules.dart';
import '../domain/books/book_status.dart';
import '../features/books/book_detail_page.dart';
import '../features/books/book_form_page.dart';
import '../features/home/home_page.dart';
import '../features/library/library_page.dart';
import '../features/library/library_providers.dart';
import '../features/stats/stats_page.dart';

class ShelfShell extends ConsumerStatefulWidget {
  const ShelfShell({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  ConsumerState<ShelfShell> createState() => _ShelfShellState();
}

class _ShelfShellState extends ConsumerState<ShelfShell> {
  int _selectedIndex = 0;
  int _goal = 24;
  final List<Book> _books = [
    Book(
      id: 1,
      title: 'The Creative Act',
      author: 'Rick Rubin',
      status: BookStatus.reading,
      currentPage: 148,
      totalPages: 432,
      genre: 'Creativity',
      startedAt: DateTime(2026, 8, 12),
      coverColor: AppColors.coverCoral,
      coverAccent: AppColors.coverCoralAccent,
      coverIcon: Icons.auto_awesome_rounded,
    ),
    Book(
      id: 2,
      title: 'Tomorrow, and Tomorrow, and Tomorrow',
      author: 'Gabrielle Zevin',
      status: BookStatus.finished,
      currentPage: 401,
      totalPages: 416,
      genre: 'Fiction',
      rating: 4.5,
      review: 'A tender story about friendship, ambition, and the games we build.',
      finishedAt: DateTime(2026, 8, 7),
      coverColor: AppColors.coverTeal,
      coverAccent: AppColors.coverTealAccent,
      coverIcon: Icons.gamepad_rounded,
    ),
    Book(
      id: 3,
      title: 'The Midnight Library',
      author: 'Matt Haig',
      status: BookStatus.wantToRead,
      currentPage: 0,
      totalPages: 304,
      genre: 'Fiction',
      coverColor: AppColors.coverNightBlue,
      coverAccent: AppColors.coverNightBlueAccent,
      coverIcon: Icons.nightlight_round,
    ),
    Book(
      id: 4,
      title: 'Deep Work',
      author: 'Cal Newport',
      status: BookStatus.finished,
      currentPage: 296,
      totalPages: 304,
      genre: 'Productivity',
      rating: 4,
      finishedAt: DateTime(2026, 5, 18),
      coverColor: AppColors.coverDeepBlue,
      coverAccent: AppColors.coverDeepBlueAccent,
      coverIcon: Icons.center_focus_strong_rounded,
    ),
    Book(
      id: 5,
      title: 'Braiding Sweetgrass',
      author: 'Robin Wall Kimmerer',
      status: BookStatus.dropped,
      currentPage: 70,
      totalPages: 408,
      genre: 'Nature',
      coverColor: AppColors.coverLeaf,
      coverAccent: AppColors.coverLeafAccent,
      coverIcon: Icons.spa_rounded,
    ),
  ];

  int get _finishedThisYear => _books.where((book) {
        return book.status == BookStatus.finished &&
            book.finishedAt?.year == DateTime.now().year;
      }).length;

  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookDetailPage(
          book: book,
          onUpdate: (updated) => _replaceBook(updated),
          onDelete: () {
            setState(() => _books.removeWhere((item) => item.id == book.id));
          },
        ),
      ),
    );
  }

  void _replaceBook(Book updated) {
    final index = _books.indexWhere((book) => book.id == updated.id);
    if (index == -1) return;
    setState(() => _books[index] = updated);
  }

  void _addBook(Book book) {
    setState(() {
      _books.insert(0, book);
      _selectedIndex = 1;
    });
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
                    _replaceBook(book.copyWith(currentPage: safePage));
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
    final libraryBooks = List<Book>.unmodifiable(_books);
    final libraryFilter = ref.watch(libraryFilterProvider);
    final filteredBooks = ref.watch(filteredBooksProvider(libraryBooks));
    final pages = _books.fold<int>(0, (sum, book) => sum + book.currentPage);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomePage(
              books: _books,
              goal: _goal,
              finishedCount: _finishedThisYear,
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
              books: _books,
              goal: _goal,
              finishedCount: _finishedThisYear,
              totalPages: pages,
              onGoalChanged: (goal) => setState(() => _goal = goal),
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
