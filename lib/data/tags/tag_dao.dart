import 'package:sqflite/sqflite.dart';

import '../../core/database/table_names.dart';

class TagDao {
  const TagDao(this._database);

  final DatabaseExecutor _database;

  Future<List<Map<String, Object?>>> getAllTags() {
    return _database.query(TableNames.tags, orderBy: 'name COLLATE NOCASE ASC');
  }

  Future<int> upsertTag(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Tag name cannot be empty');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final existing = await _database.query(
      TableNames.tags,
      columns: ['id'],
      where: 'name = ? COLLATE NOCASE',
      whereArgs: [trimmed],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.single['id'] as int;
    return _database.insert(TableNames.tags, {
      'name': trimmed,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> setBookTags(int bookId, List<String> names) async {
    await _database.delete(
      TableNames.bookTags,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    final now = DateTime.now().toUtc().toIso8601String();
    for (final name in names) {
      final tagId = await upsertTag(name);
      await _database.insert(TableNames.bookTags, {
        'book_id': bookId,
        'tag_id': tagId,
        'created_at': now,
      });
    }
  }

  Future<List<Map<String, Object?>>> getTagsForBook(int bookId) {
    return _database.rawQuery(
      '''
SELECT t.*
FROM ${TableNames.tags} t
JOIN ${TableNames.bookTags} bt ON bt.tag_id = t.id
WHERE bt.book_id = ?
ORDER BY t.name COLLATE NOCASE ASC
''',
      [bookId],
    );
  }
}
