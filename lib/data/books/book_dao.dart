import 'package:sqflite/sqflite.dart';

import '../../core/database/table_names.dart';
import '../../domain/books/book_status.dart';

class BookDao {
  const BookDao(this._database);

  final DatabaseExecutor _database;

  Future<List<Map<String, Object?>>> getAllBooks() {
    return _database.query(TableNames.books, orderBy: 'id DESC');
  }

  Future<Map<String, Object?>?> getBookById(int id) async {
    final rows = await _database.query(
      TableNames.books,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single;
  }

  Future<int> insertBook(Map<String, Object?> row) {
    return _database.insert(TableNames.books, row);
  }

  Future<void> updateBook(int id, Map<String, Object?> row) async {
    await _database.update(
      TableNames.books,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteBook(int id) async {
    await _database.delete(
      TableNames.books,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, Object?>>> searchBooks(
    String query, {
    BookStatus? status,
  }) {
    final trimmed = query.trim();
    final whereParts = <String>[];
    final whereArgs = <Object?>[];
    if (trimmed.isNotEmpty) {
      whereParts.add('(title LIKE ? OR author LIKE ?)');
      whereArgs.addAll(['%$trimmed%', '%$trimmed%']);
    }
    if (status != null) {
      whereParts.add('status = ?');
      whereArgs.add(status.name);
    }
    return _database.query(
      TableNames.books,
      where: whereParts.isEmpty ? null : whereParts.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, Object?>>> getRecentlyFinished({int limit = 5}) {
    return _database.query(
      TableNames.books,
      where: 'status = ? AND finished_at IS NOT NULL',
      whereArgs: [BookStatus.finished.name],
      orderBy: 'finished_at DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, Object?>>> getCurrentlyReading() {
    return _database.query(
      TableNames.books,
      where: 'status = ?',
      whereArgs: [BookStatus.reading.name],
      orderBy: 'updated_at DESC',
    );
  }
}
