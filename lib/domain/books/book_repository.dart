import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'book.dart';

abstract class BookRepository extends StateNotifier<List<Book>> {
  BookRepository(super.books);

  Future<void> load();

  Future<void> addBook(Book book);

  Future<void> updateBook(Book book);

  Future<void> deleteBook(int id);
}
