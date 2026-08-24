import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';
import '../books/book_providers.dart';
import 'library_filter.dart';

class LibraryFilterState {
  const LibraryFilterState({
    this.query = '',
    this.status,
    this.sort = LibrarySort.recentlyAdded,
  });

  final String query;
  final BookStatus? status;
  final LibrarySort sort;

  LibraryFilterState copyWith({
    String? query,
    BookStatus? status,
    bool clearStatus = false,
    LibrarySort? sort,
  }) {
    return LibraryFilterState(
      query: query ?? this.query,
      status: clearStatus ? null : status ?? this.status,
      sort: sort ?? this.sort,
    );
  }
}

class LibraryFilterController extends StateNotifier<LibraryFilterState> {
  LibraryFilterController() : super(const LibraryFilterState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setStatus(BookStatus? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
  }

  void setSort(LibrarySort sort) {
    state = state.copyWith(sort: sort);
  }
}

final libraryFilterProvider =
    StateNotifierProvider<LibraryFilterController, LibraryFilterState>(
  (ref) => LibraryFilterController(),
);

final filteredBooksProvider = Provider<List<Book>>(
  (ref) {
    final books = ref.watch(booksProvider);
    final filter = ref.watch(libraryFilterProvider);
    final query = filter.query.toLowerCase().trim();
    final filtered = books.where((book) {
      final matchesQuery = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
      final matchesFilter = filter.status == null || book.status == filter.status;
      return matchesQuery && matchesFilter;
    }).toList();
    return sortLibraryBooks(filtered, filter.sort);
  },
);
