import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/books/book.dart';

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
