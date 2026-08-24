import 'package:sqflite/sqflite.dart';

import '../../core/database/table_names.dart';

class SettingsDao {
  const SettingsDao(this._database);

  final DatabaseExecutor _database;

  Future<String?> getValue(String key) async {
    final rows = await _database.query(
      TableNames.appSettings,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single['value'] as String;
  }

  Future<void> setValue(String key, String value) async {
    await _database.insert(
      TableNames.appSettings,
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
