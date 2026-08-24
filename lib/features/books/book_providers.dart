import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../data/books/sqflite_book_repository.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_repository.dart';
import '../../domain/books/book_rules.dart';
import '../../domain/books/book_status.dart';

class InMemoryBookRepository extends BookRepository {
  InMemoryBookRepository({List<Book>? initialBooks})
      : super(initialBooks ?? const []);

  @override
  Future<void> load() async {}

  @override
  Future<void> addBook(Book book) async {
    state = [book, ...state];
  }

  @override
  Future<void> updateBook(Book updated) async {
    state = [
      for (final book in state)
        if (book.id == updated.id) updated else book,
    ];
  }

  @override
  Future<void> deleteBook(int id) async {
    state = state.where((book) => book.id != id).toList();
  }
}

class BookFormController {
  const BookFormController(this._repository);

  final BookRepository _repository;

  Future<void> addBook(Book book) {
    return _repository.addBook(book);
  }

  Future<void> updateBook(Book book) {
    return _repository.updateBook(book);
  }
}

class BookDetailController {
  const BookDetailController(this._repository);

  final BookRepository _repository;

  Future<void> updateBook(Book book) {
    return _repository.updateBook(book);
  }

  Future<void> updateProgress(Book book, int currentPage) {
    final safePage = BookRules.clampProgressPage(
      currentPage,
      totalPages: book.totalPages,
    );
    return _repository.updateBook(book.copyWith(currentPage: safePage));
  }

  Future<void> finishBook(
    Book book, {
    double? rating,
    String? review,
    DateTime? finishedAt,
  }) {
    return _repository.updateBook(
      book.copyWith(
        status: BookStatus.finished,
        rating: rating,
        review: review,
        finishedAt: finishedAt ?? DateTime.now(),
      ),
    );
  }

  Future<void> deleteBook(int id) {
    return _repository.deleteBook(id);
  }
}

final bookRepositoryProvider =
    StateNotifierProvider<BookRepository, List<Book>>(
  (ref) {
    final repository = SqfliteBookRepository(ref.watch(appDatabaseProvider));
    var disposed = false;
    ref.onDispose(() => disposed = true);
    Timer.run(() {
      if (!disposed) {
        unawaited(repository.load());
      }
    });
    return repository;
  },
);

final bookFormControllerProvider = Provider<BookFormController>((ref) {
  return BookFormController(ref.read(bookRepositoryProvider.notifier));
});

final bookDetailControllerProvider = Provider<BookDetailController>((ref) {
  return BookDetailController(ref.read(bookRepositoryProvider.notifier));
});

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

final currentlyReadingProvider = Provider<List<Book>>((ref) {
  final books = ref.watch(booksProvider);
  return books.where((book) => book.status == BookStatus.reading).toList();
});

final recentlyFinishedProvider = Provider<List<Book>>((ref) {
  final books = ref.watch(booksProvider);
  return books.where((book) => book.status == BookStatus.finished).toList();
});
