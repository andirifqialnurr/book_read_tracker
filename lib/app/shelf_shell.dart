import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/date_formatters.dart';
import '../core/utils/number_formatters.dart';
import '../domain/books/book.dart';
import '../domain/books/book_rules.dart';
import '../domain/books/book_status.dart';
import '../features/books/book_form_page.dart';
import '../features/books/widgets/book_cover.dart';
import '../features/goals/widgets/goal_card.dart';
import '../features/home/home_page.dart';
import '../features/library/library_filter.dart';
import '../features/library/library_page.dart';
import '../shared/widgets/detail_section.dart';
import '../shared/widgets/meta_row.dart';

class ShelfShell extends StatefulWidget {
  const ShelfShell({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  State<ShelfShell> createState() => _ShelfShellState();
}

class _ShelfShellState extends State<ShelfShell> {
  int _selectedIndex = 0;
  int _goal = 24;
  String _searchQuery = '';
  BookStatus? _filter;
  LibrarySort _librarySort = LibrarySort.recentlyAdded;
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

  List<Book> get _filteredBooks {
    final filtered = _books.where((book) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
      final matchesFilter = _filter == null || book.status == _filter;
      return matchesQuery && matchesFilter;
    }).toList();
    return sortLibraryBooks(filtered, _librarySort);
  }

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
              books: _filteredBooks,
              query: _searchQuery,
              filter: _filter,
              sort: _librarySort,
              onQueryChanged: (value) => setState(() => _searchQuery = value),
              onFilterChanged: (value) => setState(() => _filter = value),
              onSortChanged: (value) => setState(() => _librarySort = value),
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

class StatsPage extends StatelessWidget {
  const StatsPage({required this.books, required this.goal, required this.finishedCount, required this.totalPages, required this.onGoalChanged, super.key});

  final List<Book> books;
  final int goal;
  final int finishedCount;
  final int totalPages;
  final ValueChanged<int> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    final ratings = books.where((book) => book.rating != null).map((book) => book.rating!).toList();
    final average = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    final genres = <String, int>{};
    for (final book in books.where((book) => book.status == BookStatus.finished)) {
      genres[book.genre] = (genres[book.genre] ?? 0) + 1;
    }
    final favoriteGenre = genres.entries.isEmpty ? '—' : genres.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final values = [2.0, 4.0, 1.0, 3.0, 2.5, 4.0, 3.0, 5.0];

    return CustomScrollView(
      slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 0), sliver: SliverToBoxAdapter(child: Row(children: [Expanded(child: Text('Reading stats', style: AppTextStyles.editorial(context, 30))), IconButton(tooltip: 'Edit annual goal', onPressed: () => _showGoalEditor(context, goal, onGoalChanged), icon: const Icon(Icons.edit_outlined))]))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), sliver: SliverToBoxAdapter(child: GoalCard(progress: goal == 0 ? 0.0 : (finishedCount / goal).clamp(0.0, 1.0).toDouble(), count: finishedCount, goal: goal, compact: true))),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatTile(value: '$finishedCount', label: 'Books finished', icon: Icons.check_circle_outline_rounded),
              _StatTile(value: formatCompactNumber(totalPages), label: 'Pages read', icon: Icons.menu_book_rounded),
              _StatTile(value: average == 0 ? '—' : average.toStringAsFixed(1), label: 'Average rating', icon: Icons.star_outline_rounded),
              _StatTile(value: favoriteGenre, label: 'Favorite genre', icon: Icons.local_library_outlined, smallValue: true),
            ],
          ),
        ),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 30, 20, 0), sliver: SliverToBoxAdapter(child: Text('Books per month', style: AppTextStyles.editorial(context, 21)))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 30), sliver: SliverToBoxAdapter(child: _BarChart(values: values))),
      ],
    );
  }
}

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({required this.book, required this.onUpdate, required this.onDelete, super.key});

  final Book book;
  final ValueChanged<Book> onUpdate;
  final VoidCallback onDelete;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Book _book = widget.book;

  void _update(Book book) {
    setState(() => _book = book);
    widget.onUpdate(book);
  }

  Future<void> _showProgress() async {
    final controller = TextEditingController(text: '${_book.currentPage}');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Update progress', style: AppTextStyles.editorial(context, 24)),
          const SizedBox(height: 18),
          TextField(controller: controller, autofocus: true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Current page', suffixText: _book.totalPages == null ? null : 'of ${_book.totalPages}')),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () { final raw = int.tryParse(controller.text) ?? _book.currentPage; final page = BookRules.clampProgressPage(raw, totalPages: _book.totalPages); _update(_book.copyWith(currentPage: page)); Navigator.pop(sheetContext); }, child: const Text('Save progress'))),
        ]),
      ),
    );
  }

  Future<void> _finishBook() async {
    final rating = ValueNotifier<double>(_book.rating ?? 0);
    final reviewController = TextEditingController(text: _book.review ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 22),
        child: StatefulBuilder(builder: (context, setSheetState) => SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 22),
          Text(
            'A good one to remember.',
            style: AppTextStyles.editorial(context, 25),
          ),
          const SizedBox(height: 6),
          Text('How did ${_book.title} feel?', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          ValueListenableBuilder<double>(valueListenable: rating, builder: (_, value, __) => Row(children: List.generate(5, (index) => IconButton(tooltip: 'Rate ${index + 1} stars', onPressed: () { rating.value = index + 1.0; setSheetState(() {}); }, iconSize: 31, color: index < value ? AppColors.star : Theme.of(context).dividerColor, icon: Icon(index < value ? Icons.star_rounded : Icons.star_outline_rounded))))),
          const SizedBox(height: 8),
          TextField(controller: reviewController, maxLines: 4, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Personal review', hintText: 'A few words for future you...')),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () { _update(_book.copyWith(status: BookStatus.finished, rating: rating.value == 0 ? null : rating.value, review: reviewController.text.trim().isEmpty ? null : reviewController.text.trim(), finishedAt: DateTime.now())); Navigator.pop(sheetContext); }, child: const Text('Save as finished'))),
        ]))),
      ),
    );
    rating.dispose();
    reviewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _book.progress;
    final statusColor = _book.status.color(Theme.of(context).brightness);
    return Scaffold(
      appBar: AppBar(leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)), actions: [IconButton(tooltip: 'More actions', onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 30), children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BookCover(book: _book, width: 126, height: 188),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 5), Text(_book.status.label.toUpperCase(), style: AppTextStyles.eyebrow(context, color: statusColor)), const SizedBox(height: 10), Text(_book.title, style: AppTextStyles.editorial(context, 25, height: 1.08)), const SizedBox(height: 8), Text(_book.author, style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 16), Wrap(spacing: 6, runSpacing: 6, children: [Chip(label: Text(_book.genre)), if (_book.totalPages != null) Chip(label: Text('${_book.totalPages} pages'))])])),
        ]),
        const SizedBox(height: 28),
        if (progress != null) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Reading progress', style: AppTextStyles.editorial(context, 20)), Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800))]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 10)),
          const SizedBox(height: 8),
          Text('${_book.currentPage} of ${_book.totalPages} pages', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
        ],
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _showProgress, icon: const Icon(Icons.edit_note_rounded), label: const Text('Update progress'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: _book.status == BookStatus.finished ? _finishBook : _finishBook, icon: const Icon(Icons.check_rounded), label: Text(_book.status == BookStatus.finished ? 'Edit review' : 'Finish book')))]),
        const SizedBox(height: 30),
        DetailSection(title: 'About this reading', child: Column(children: [if (_book.startedAt != null) MetaRow(label: 'Started', value: formatShelfDate(_book.startedAt!)), if (_book.finishedAt != null) MetaRow(label: 'Finished', value: formatShelfDate(_book.finishedAt!)), MetaRow(label: 'Shelf', value: _book.status.label)])),
        if (_book.rating != null || _book.review != null) ...[
          const SizedBox(height: 26),
          DetailSection(title: 'Your review', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (_book.rating != null) Row(children: [const Icon(Icons.star_rounded, color: AppColors.star), const SizedBox(width: 5), Text('${_book.rating!.toStringAsFixed(1)} / 5', style: const TextStyle(fontWeight: FontWeight.w800))]), if (_book.review != null) ...[const SizedBox(height: 14), Text(_book.review!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55))]])),
        ],
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.icon, this.smallValue = false});
  final String value;
  final String label;
  final IconData icon;
  final bool smallValue;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary), const Spacer(), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: smallValue ? 17 : 24, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(label, style: Theme.of(context).textTheme.bodySmall)]));
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A'];
    return Container(height: 196, padding: const EdgeInsets.fromLTRB(14, 16, 14, 12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerColor)), child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(values.length, (index) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(width: 22, height: values[index] * 25, decoration: BoxDecoration(color: index == values.length - 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withValues(alpha: .25), borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))))), const SizedBox(height: 9), Text(labels[index], style: Theme.of(context).textTheme.bodySmall)]))));
  }
}

Future<void> _showGoalEditor(BuildContext context, int current, ValueChanged<int> onChanged) async {
  final controller = TextEditingController(text: '$current');
  await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: Text('Annual goal', style: AppTextStyles.editorial(context, 22)), content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Books to finish in 2026')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () { final goal = (int.tryParse(controller.text) ?? current).clamp(1, 999).toInt(); onChanged(goal); Navigator.pop(dialogContext); }, child: const Text('Save'))]));
  controller.dispose();
}



