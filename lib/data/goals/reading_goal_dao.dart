import 'package:sqflite/sqflite.dart';

import '../../core/database/table_names.dart';

class ReadingGoalDao {
  const ReadingGoalDao(this._database);

  final DatabaseExecutor _database;

  Future<Map<String, Object?>?> getGoalByYear(int year) async {
    final rows = await _database.query(
      TableNames.readingGoals,
      where: 'year = ?',
      whereArgs: [year],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single;
  }

  Future<int> upsertGoal({
    required int year,
    required int targetBooks,
    DateTime? now,
  }) async {
    final timestamp = (now ?? DateTime.now()).toUtc().toIso8601String();
    final existing = await getGoalByYear(year);
    if (existing == null) {
      return _database.insert(TableNames.readingGoals, {
        'year': year,
        'target_books': targetBooks,
        'created_at': timestamp,
        'updated_at': timestamp,
      });
    }
    await _database.update(
      TableNames.readingGoals,
      {
        'target_books': targetBooks,
        'updated_at': timestamp,
      },
      where: 'year = ?',
      whereArgs: [year],
    );
    return existing['id'] as int;
  }
}
