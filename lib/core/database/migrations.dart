import 'package:sqflite/sqflite.dart';

import 'table_names.dart';

class DatabaseMigrations {
  const DatabaseMigrations._();

  static const initialVersion = 1;

  static Future<void> createV1(Database db) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.transaction((txn) async {
      await txn.execute('''
CREATE TABLE ${TableNames.books} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  author TEXT,
  cover_uri TEXT,
  cover_color TEXT,
  cover_accent TEXT,
  cover_icon TEXT,
  total_pages INTEGER,
  current_page INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'wantToRead'
    CHECK (status IN ('wantToRead', 'reading', 'finished', 'dropped')),
  genre TEXT,
  publication_year INTEGER,
  started_at TEXT,
  finished_at TEXT,
  rating REAL CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5)),
  review TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  CHECK (total_pages IS NULL OR total_pages >= 0),
  CHECK (current_page >= 0),
  CHECK (total_pages IS NULL OR current_page <= total_pages),
  CHECK (publication_year IS NULL OR publication_year >= 0)
)
''');
      await txn.execute(
        'CREATE INDEX idx_books_status ON ${TableNames.books}(status)',
      );
      await txn.execute(
        'CREATE INDEX idx_books_created_at ON ${TableNames.books}(created_at)',
      );
      await txn.execute(
        'CREATE INDEX idx_books_finished_at ON ${TableNames.books}(finished_at)',
      );
      await txn.execute(
        'CREATE INDEX idx_books_title ON ${TableNames.books}(title)',
      );
      await txn.execute(
        'CREATE INDEX idx_books_author ON ${TableNames.books}(author)',
      );

      await txn.execute('''
CREATE TABLE ${TableNames.tags} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL COLLATE NOCASE,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(name)
)
''');

      await txn.execute('''
CREATE TABLE ${TableNames.bookTags} (
  book_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (book_id, tag_id),
  FOREIGN KEY (book_id) REFERENCES ${TableNames.books}(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES ${TableNames.tags}(id) ON DELETE CASCADE
)
''');
      await txn.execute(
        'CREATE INDEX idx_book_tags_tag_id ON ${TableNames.bookTags}(tag_id)',
      );

      await txn.execute('''
CREATE TABLE ${TableNames.readingGoals} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  year INTEGER NOT NULL,
  target_books INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(year),
  CHECK (year >= 0),
  CHECK (target_books >= 1)
)
''');

      await txn.execute('''
CREATE TABLE ${TableNames.progressHistory} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  page INTEGER NOT NULL,
  recorded_at TEXT NOT NULL,
  note TEXT,
  FOREIGN KEY (book_id) REFERENCES ${TableNames.books}(id) ON DELETE CASCADE,
  CHECK (page >= 0)
)
''');
      await txn.execute('''
CREATE INDEX idx_progress_history_book_id
ON ${TableNames.progressHistory}(book_id)
''');
      await txn.execute('''
CREATE INDEX idx_progress_history_recorded_at
ON ${TableNames.progressHistory}(recorded_at)
''');

      await txn.execute('''
CREATE TABLE ${TableNames.appSettings} (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
      await txn.insert(TableNames.appSettings, {
        'key': 'theme_mode',
        'value': 'system',
        'updated_at': now,
      });
    });
  }
}
