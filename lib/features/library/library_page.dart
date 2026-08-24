import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';
import '../../shared/widgets/no_results.dart';
import '../../shared/widgets/shelf_filter_chip.dart';
import 'library_filter.dart';
import 'widgets/library_book_card.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    required this.books,
    required this.query,
    required this.filter,
    required this.sort,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onOpenBook,
    required this.onAddBook,
    super.key,
  });

  final List<Book> books;
  final String query;
  final BookStatus? filter;
  final LibrarySort sort;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<BookStatus?> onFilterChanged;
  final ValueChanged<LibrarySort> onSortChanged;
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
                IconButton(
                  tooltip: 'Add book',
                  onPressed: onAddBook,
                  icon: const Icon(Icons.add_rounded),
                ),
                PopupMenuButton<LibrarySort>(
                  tooltip: 'Sort library',
                  icon: const Icon(Icons.tune_rounded),
                  initialValue: sort,
                  onSelected: onSortChanged,
                  itemBuilder: (context) {
                    return LibrarySort.values.map((value) {
                      return PopupMenuItem<LibrarySort>(
                        value: value,
                        child: Text(value.label),
                      );
                    }).toList();
                  },
                ),
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
                  ShelfFilterChip(
                    label: 'All books',
                    selected: filter == null,
                    onTap: () => onFilterChanged(null),
                  ),
                  ...BookStatus.values.map(
                    (status) => ShelfFilterChip(
                      label: status.label,
                      selected: filter == status,
                      onTap: () => onFilterChanged(status),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          sliver: books.isEmpty
              ? SliverToBoxAdapter(child: NoResults(query: query))
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => LibraryBookCard(
                      book: books[index],
                      onTap: () => onOpenBook(books[index]),
                    ),
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
