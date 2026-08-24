import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/date_formatters.dart';
import '../core/utils/number_formatters.dart';
import '../domain/books/book.dart';
import '../domain/books/book_rules.dart';
import '../domain/books/book_status.dart';

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
    return _books.where((book) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
      final matchesFilter = _filter == null || book.status == _filter;
      return matchesQuery && matchesFilter;
    }).toList();
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
              onQueryChanged: (value) => setState(() => _searchQuery = value),
              onFilterChanged: (value) => setState(() => _filter = value),
              onOpenBook: _openBook,
              onAddBook: () => setState(() => _selectedIndex = 2),
            ),
            AddBookPage(
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

class HomePage extends StatelessWidget {
  const HomePage({
    required this.books,
    required this.goal,
    required this.finishedCount,
    required this.onOpenBook,
    required this.onUpdateProgress,
    required this.onSeeLibrary,
    required this.onToggleTheme,
    super.key,
  });

  final List<Book> books;
  final int goal;
  final int finishedCount;
  final ValueChanged<Book> onOpenBook;
  final ValueChanged<Book> onUpdateProgress;
  final VoidCallback onSeeLibrary;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final reading = books.where((book) => book.status == BookStatus.reading).toList();
    final finished = books.where((book) => book.status == BookStatus.finished).toList();
    final progress = goal == 0
        ? 0.0
        : (finishedCount / goal).clamp(0.0, 1.0).toDouble();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SATURDAY, AUGUST 23',
                        style: AppTextStyles.eyebrow(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Good morning,\nreader.',
                        style: AppTextStyles.editorial(
                          context,
                          32,
                          height: 1.04,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: onToggleTheme,
                  icon: const Icon(Icons.wb_sunny_outlined),
                ),
                const SizedBox(width: 2),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text('A', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(title: 'Currently reading', actionLabel: 'See all', onAction: onSeeLibrary),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
          sliver: reading.isEmpty
              ? SliverToBoxAdapter(child: _EmptyReadingCard(onAdd: onSeeLibrary))
              : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 226,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 20),
                      itemCount: reading.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final book = reading[index];
                        return _ReadingCard(book: book, onTap: () => onOpenBook(book), onUpdate: () => onUpdateProgress(book));
                      },
                    ),
                  ),
                ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(child: _GoalCard(progress: progress, count: finishedCount, goal: goal)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(title: 'Recently finished', actionLabel: 'Library', onAction: onSeeLibrary),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          sliver: finished.isEmpty
              ? SliverToBoxAdapter(child: Text('Your finished books will appear here.', style: Theme.of(context).textTheme.bodyMedium))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FinishedRow(book: finished[index], onTap: () => onOpenBook(finished[index])),
                    ),
                    childCount: finished.length,
                  ),
                ),
        ),
      ],
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    required this.books,
    required this.query,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onOpenBook,
    required this.onAddBook,
    super.key,
  });

  final List<Book> books;
  final String query;
  final BookStatus? filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<BookStatus?> onFilterChanged;
  final ValueChanged<Book> onOpenBook;
  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Your library',
                    style: AppTextStyles.editorial(context, 30),
                  ),
                ),
                IconButton(onPressed: onAddBook, icon: const Icon(Icons.add_rounded)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Search title or author',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(label: 'All books', selected: filter == null, onTap: () => onFilterChanged(null)),
                  ...BookStatus.values.map((status) => _FilterChip(label: status.label, selected: filter == status, onTap: () => onFilterChanged(status))),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          sliver: books.isEmpty
              ? SliverToBoxAdapter(child: _NoResults(query: query))
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _LibraryBookCard(book: books[index], onTap: () => onOpenBook(books[index])),
                    childCount: books.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 24,
                    childAspectRatio: .61,
                  ),
                ),
        ),
      ],
    );
  }
}

class AddBookPage extends StatefulWidget {
  const AddBookPage({required this.onCancel, required this.onSave, super.key});

  final VoidCallback onCancel;
  final ValueChanged<Book> onSave;

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _yearController = TextEditingController();
  BookStatus _status = BookStatus.wantToRead;
  String _genre = 'Fiction';

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A title is required')));
      return;
    }
    final colors = [
      [AppColors.coverIndigo, AppColors.coverIndigoAccent],
      [AppColors.coverTerracotta, AppColors.coverTerracottaAccent],
      [AppColors.coverGreen, AppColors.coverGreenAccent],
    ];
    final pair = colors[title.length % colors.length];
    widget.onSave(Book(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      author: _authorController.text.trim().isEmpty ? 'Unknown author' : _authorController.text.trim(),
      status: _status,
      totalPages: int.tryParse(_pagesController.text.trim()),
      genre: _genre,
      startedAt: _status == BookStatus.reading ? DateTime.now() : null,
      coverColor: pair[0],
      coverAccent: pair[1],
    ));
    _titleController.clear();
    _authorController.clear();
    _pagesController.clear();
    _yearController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add a book',
                    style: AppTextStyles.editorial(context, 30),
                  ),
                ),
                TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _CoverPicker()),
                const SizedBox(height: 26),
                Text(
                  'Book details',
                  style: AppTextStyles.editorial(context, 21),
                ),
                const SizedBox(height: 14),
                TextField(controller: _titleController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Title *', hintText: 'What are you reading?')),
                const SizedBox(height: 12),
                TextField(controller: _authorController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Author', hintText: 'Who wrote it?')),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: TextField(controller: _pagesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Page count'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _yearController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year')))]),
                const SizedBox(height: 26),
                Text(
                  'Shelf details',
                  style: AppTextStyles.editorial(context, 21),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<BookStatus>(initialValue: _status, decoration: const InputDecoration(labelText: 'Status'), items: BookStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(status.label))).toList(), onChanged: (value) => setState(() => _status = value ?? _status)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(initialValue: _genre, decoration: const InputDecoration(labelText: 'Genre'), items: const ['Fiction', 'Creativity', 'Productivity', 'Nature', 'Biography', 'Other'].map((genre) => DropdownMenuItem(value: genre, child: Text(genre))).toList(), onChanged: (value) => setState(() => _genre = value ?? _genre)),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Save to my shelf'))),
              ],
            ),
          ),
        ),
      ],
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
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 0), sliver: SliverToBoxAdapter(child: Row(children: [Expanded(child: Text('Reading stats', style: AppTextStyles.editorial(context, 30))), IconButton(onPressed: () => _showGoalEditor(context, goal, onGoalChanged), icon: const Icon(Icons.edit_outlined))]))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), sliver: SliverToBoxAdapter(child: _GoalCard(progress: goal == 0 ? 0.0 : (finishedCount / goal).clamp(0.0, 1.0).toDouble(), count: finishedCount, goal: goal, compact: true))),
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
          ValueListenableBuilder<double>(valueListenable: rating, builder: (_, value, __) => Row(children: List.generate(5, (index) => IconButton(onPressed: () { rating.value = index + 1.0; setSheetState(() {}); }, iconSize: 31, color: index < value ? AppColors.star : Theme.of(context).dividerColor, icon: Icon(index < value ? Icons.star_rounded : Icons.star_outline_rounded))))),
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
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 30), children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _BookCover(book: _book, width: 126, height: 188),
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
        _DetailSection(title: 'About this reading', child: Column(children: [if (_book.startedAt != null) _MetaRow(label: 'Started', value: formatShelfDate(_book.startedAt!)), if (_book.finishedAt != null) _MetaRow(label: 'Finished', value: formatShelfDate(_book.finishedAt!)), _MetaRow(label: 'Shelf', value: _book.status.label)])),
        if (_book.rating != null || _book.review != null) ...[
          const SizedBox(height: 26),
          _DetailSection(title: 'Your review', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (_book.rating != null) Row(children: [const Icon(Icons.star_rounded, color: AppColors.star), const SizedBox(width: 5), Text('${_book.rating!.toStringAsFixed(1)} / 5', style: const TextStyle(fontWeight: FontWeight.w800))]), if (_book.review != null) ...[const SizedBox(height: 14), Text(_book.review!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55))]])),
        ],
      ]),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.book, required this.onTap, required this.onUpdate});

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final progress = book.progress ?? 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 310,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .5)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 18, offset: const Offset(0, 8))]),
        child: Row(children: [
          _BookCover(book: book, width: 100, height: 148),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.editorial(context, 19, height: 1.1)), const SizedBox(height: 6), Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall), const Spacer(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800)), Text('${book.currentPage}/${book.totalPages}', style: Theme.of(context).textTheme.bodySmall)]), const SizedBox(height: 7), ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: progress, minHeight: 7)), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 34, child: OutlinedButton(onPressed: onUpdate, child: const Text('Update')))])),
        ]),
      ),
    );
  }
}

class _FinishedRow extends StatelessWidget {
  const _FinishedRow({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            _BookCover(book: book, width: 48, height: 68),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      if (book.rating != null) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.star,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          book.rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        book.finishedAt == null
                            ? ''
                            : formatShelfDate(book.finishedAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryBookCard extends StatelessWidget {
  const _LibraryBookCard({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookCover(book: book, width: double.infinity, height: 218),
          const SizedBox(height: 10),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 4),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: book.status.color(Theme.of(context).brightness),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  book.status.label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.book, required this.width, required this.height});
  final Book book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [book.coverColor, Color.lerp(book.coverColor, Colors.black, .34)!]), boxShadow: [BoxShadow(color: book.coverColor.withValues(alpha: .22), blurRadius: 12, offset: const Offset(0, 6))]), child: Stack(children: [Positioned(top: -28, right: -24, child: Container(width: 98, height: 98, decoration: BoxDecoration(shape: BoxShape.circle, color: book.coverAccent.withValues(alpha: .22)))), Positioned(bottom: 14, right: 12, child: Icon(book.coverIcon, color: book.coverAccent.withValues(alpha: .74), size: 27)), Padding(padding: const EdgeInsets.fromLTRB(12, 14, 10, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SHELF', style: TextStyle(color: book.coverAccent.withValues(alpha: .8), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.5)), const Spacer(), Text(book.title, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: width < 70 ? 10 : 15, height: 1.05, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: book.coverAccent.withValues(alpha: .86), fontSize: width < 70 ? 7 : 9))]))]));
  }
}

class _CoverPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 128, height: 166, decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Theme.of(context).colorScheme.primaryContainer, border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .25), width: 1.5)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, size: 30, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), Text('Add cover', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('Optional', style: Theme.of(context).textTheme.bodySmall)]));
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.progress, required this.count, required this.goal, this.compact = false});
  final double progress;
  final int count;
  final int goal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(padding: EdgeInsets.all(compact ? 17 : 20), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(22)), child: Row(children: [SizedBox(width: compact ? 70 : 78, height: compact ? 70 : 78, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress, strokeWidth: 7, backgroundColor: Colors.white.withValues(alpha: .2), valueColor: const AlwaysStoppedAnimation(Colors.white)), Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))])), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('2026 reading goal', style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('$count of $goal books', style: TextStyle(color: Colors.white, fontSize: compact ? 19 : 21, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(progress >= 1 ? 'Goal complete — beautiful work.' : '${goal - count} more to go this year', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12))]))]));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel, required this.onAction});
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: AppTextStyles.editorial(context, 21))), TextButton(onPressed: onAction, child: Text(actionLabel))]);
}

class _EmptyReadingCard extends StatelessWidget {
  const _EmptyReadingCard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: Theme.of(context).dividerColor)), child: Row(children: [Icon(Icons.auto_stories_outlined, size: 34, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Nothing on your nightstand yet', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('Add a book to start your next chapter.', style: Theme.of(context).textTheme.bodySmall)])), TextButton(onPressed: onAdd, child: const Text('Add'))]));
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()));
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 65),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                'No books found',
                style: AppTextStyles.editorial(context, 21),
              ),
              const SizedBox(height: 5),
              Text(
                query.isEmpty
                    ? 'Try a different filter.'
                    : 'Nothing matched "$query".',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.editorial(context, 20)), const SizedBox(height: 12), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)), child: child)]);
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]));
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



