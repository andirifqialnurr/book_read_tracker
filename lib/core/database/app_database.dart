import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';

class AppDatabase {
  AppDatabase();

  static const databaseName = 'shelf.db';

  Database? _database;

  Future<Database> get instance async {
    final existing = _database;
    if (existing != null) return existing;

    final directory = await getApplicationDocumentsDirectory();
    final database = await openDatabase(
      p.join(directory.path, databaseName),
      version: DatabaseMigrations.initialVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await DatabaseMigrations.createV1(db);
      },
    );
    _database = database;
    return database;
  }

  Future<void> close() async {
    final existing = _database;
    if (existing == null) return;
    await existing.close();
    _database = null;
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
