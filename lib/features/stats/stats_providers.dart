import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';
import '../books/book_providers.dart';

class ReadingStats {
  const ReadingStats({
    required this.finishedThisYear,
    required this.totalPages,
    required this.averageRating,
    required this.favoriteGenre,
    required this.booksPerMonth,
  });

  final int finishedThisYear;
  final int totalPages;
  final double averageRating;
  final String favoriteGenre;
  final List<double> booksPerMonth;
}

final booksPerMonthChartProvider = Provider.family<List<double>, List<Book>>(
  (ref, books) {
    return List<double>.generate(8, (index) {
      final month = index + 1;
      return books.where((book) {
        return book.finishedAt?.year == DateTime.now().year &&
            book.finishedAt?.month == month;
      }).length.toDouble();
    });
  },
);

final readingStatsProvider = Provider<ReadingStats>((ref) {
  final books = ref.watch(booksProvider);
  final currentYear = DateTime.now().year;
  final finishedBooks = books.where((book) {
    return book.status == BookStatus.finished;
  }).toList();
  final finishedThisYear = finishedBooks.where((book) {
    return book.finishedAt?.year == currentYear;
  }).length;
  final ratings = books
      .where((book) => book.rating != null)
      .map((book) => book.rating!)
      .toList();
  final genres = <String, int>{};
  for (final book in finishedBooks) {
    genres[book.genre] = (genres[book.genre] ?? 0) + 1;
  }

  return ReadingStats(
    finishedThisYear: finishedThisYear,
    totalPages: books.fold<int>(0, (sum, book) => sum + book.currentPage),
    averageRating: ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length,
    favoriteGenre: genres.entries.isEmpty
        ? '-'
        : genres.entries.reduce((a, b) => a.value >= b.value ? a : b).key,
    booksPerMonth: ref.watch(booksPerMonthChartProvider(books)),
  );
});
