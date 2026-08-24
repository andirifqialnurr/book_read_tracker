import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';

class InMemoryBookRepository extends StateNotifier<List<Book>> {
  InMemoryBookRepository({List<Book>? initialBooks})
      : super(initialBooks ?? _seedBooks);

  void addBook(Book book) {
    state = [book, ...state];
  }

  void updateBook(Book updated) {
    state = [
      for (final book in state)
        if (book.id == updated.id) updated else book,
    ];
  }

  void deleteBook(int id) {
    state = state.where((book) => book.id != id).toList();
  }
}

final bookRepositoryProvider =
    StateNotifierProvider<InMemoryBookRepository, List<Book>>(
  (ref) => InMemoryBookRepository(),
);

final booksProvider = Provider<List<Book>>((ref) {
  return ref.watch(bookRepositoryProvider);
});

final bookByIdProvider = Provider.family<Book?, int>((ref, id) {
  final books = ref.watch(booksProvider);
  for (final book in books) {
    if (book.id == id) return book;
  }
  return null;
});

final _seedBooks = [
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
