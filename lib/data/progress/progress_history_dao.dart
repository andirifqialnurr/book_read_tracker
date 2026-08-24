import 'package:sqflite/sqflite.dart';

import '../../core/database/table_names.dart';

class ProgressHistoryDao {
  const ProgressHistoryDao(this._database);

  final DatabaseExecutor _database;

  Future<void> insertProgress({
    required int bookId,
    required int page,
    required DateTime recordedAt,
    String? note,
  }) async {
    await _database.insert(TableNames.progressHistory, {
      'book_id': bookId,
      'page': page,
      'recorded_at': recordedAt.toUtc().toIso8601String(),
      'note': note,
    });
  }

  Future<List<Map<String, Object?>>> getForBook(int bookId) {
    return _database.query(
      TableNames.progressHistory,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'recorded_at DESC',
    );
  }

  Future<Map<int, int>> getBooksFinishedPerMonth(int year) async {
    final rows = await _database.rawQuery(
      '''
SELECT CAST(strftime('%m', recorded_at) AS INTEGER) AS month, COUNT(*) AS total
FROM ${TableNames.progressHistory}
WHERE strftime('%Y', recorded_at) = ?
GROUP BY month
''',
      ['$year'],
    );
    return {
      for (final row in rows) row['month'] as int: row['total'] as int,
    };
  }
}
