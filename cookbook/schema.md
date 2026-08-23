# Schema - Shelf SQLite

## 1. Database

Engine: SQLite lokal melalui `sqflite`.

Nama database target: `shelf.db`

Versi awal: `1`

Semua timestamp disimpan sebagai ISO-8601 UTC string (`TEXT`) agar mudah dibaca, mudah di-debug, dan aman untuk migrasi Flutter.

## 2. Naming Convention

- Tabel memakai `snake_case`.
- Kolom memakai `snake_case`.
- Domain model Dart memakai `camelCase`.
- Enum disimpan sebagai `TEXT` stabil, bukan ordinal integer.
- Boolean disimpan sebagai `INTEGER` 0/1 jika dibutuhkan.

## 3. Tables

### books

Menyimpan data utama buku dan catatan baca.

```sql
CREATE TABLE books (
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
);
```

Kolom:

| Kolom | Dart field | Catatan |
| --- | --- | --- |
| `id` | `id` | Auto increment lokal |
| `title` | `title` | Wajib |
| `author` | `author` | Nullable; UI boleh menampilkan `Unknown author` |
| `cover_uri` | `coverUri` | Path/URI file lokal |
| `cover_color` | `coverColorHex` | Hex fallback cover |
| `cover_accent` | `coverAccentHex` | Hex accent fallback cover |
| `cover_icon` | `coverIconName` | Nama icon fallback, bukan `IconData` mentah |
| `total_pages` | `totalPages` | Nullable |
| `current_page` | `currentPage` | Default 0 |
| `status` | `status` | Enum text stabil |
| `genre` | `genre` | Nullable, UI fallback `Uncategorized` |
| `publication_year` | `publicationYear` | Nullable |
| `started_at` | `startedAt` | Nullable |
| `finished_at` | `finishedAt` | Nullable |
| `rating` | `rating` | Nullable, 1-5 |
| `review` | `review` | Nullable |
| `created_at` | `createdAt` | Wajib |
| `updated_at` | `updatedAt` | Wajib |

Indexes:

```sql
CREATE INDEX idx_books_status ON books(status);
CREATE INDEX idx_books_created_at ON books(created_at);
CREATE INDEX idx_books_finished_at ON books(finished_at);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author);
```

Search MVP dapat memakai `LIKE` terhadap `title` dan `author`. FTS dapat ditambahkan di V2 jika dibutuhkan.

### tags

Menyimpan tag custom.

```sql
CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL COLLATE NOCASE,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(name)
);
```

### book_tags

Relasi many-to-many antara buku dan tags.

```sql
CREATE TABLE book_tags (
  book_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (book_id, tag_id),
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);
```

Indexes:

```sql
CREATE INDEX idx_book_tags_tag_id ON book_tags(tag_id);
```

### reading_goals

Menyimpan target baca tahunan.

```sql
CREATE TABLE reading_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  year INTEGER NOT NULL,
  target_books INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(year),
  CHECK (year >= 0),
  CHECK (target_books >= 1)
);
```

Default MVP:

- Tahun aktif memakai `DateTime.now().year`.
- Jika belum ada row, repository membuat default `target_books = 24`.

### progress_history

Menyimpan riwayat update halaman.

```sql
CREATE TABLE progress_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  page INTEGER NOT NULL,
  recorded_at TEXT NOT NULL,
  note TEXT,
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  CHECK (page >= 0)
);
```

Indexes:

```sql
CREATE INDEX idx_progress_history_book_id ON progress_history(book_id);
CREATE INDEX idx_progress_history_recorded_at ON progress_history(recorded_at);
```

### app_settings

Menyimpan preferensi lokal seperti theme.

```sql
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

Keys awal:

| Key | Values | Default |
| --- | --- | --- |
| `theme_mode` | `system`, `light`, `dark` | `system` |

## 4. Domain Mapping

### BookStatus

| Database value | Dart enum |
| --- | --- |
| `wantToRead` | `BookStatus.wantToRead` |
| `reading` | `BookStatus.reading` |
| `finished` | `BookStatus.finished` |
| `dropped` | `BookStatus.dropped` |

Jangan simpan enum ordinal karena urutan enum bisa berubah.

### DateTime

- Saat menulis: `date.toUtc().toIso8601String()`.
- Saat membaca: `DateTime.parse(value).toLocal()` bila UI membutuhkan local time.
- Untuk annual goal, hitung berdasarkan calendar year lokal dari `finishedAt`.

### Color

- Simpan warna sebagai hex string uppercase, contoh `#5B5FA8`.
- Mapper domain mengubah hex ke `Color`.
- Jika null, gunakan fallback palette dari `design-system.md`.

### Icon

- Simpan `cover_icon` sebagai nama stabil, contoh `auto_stories`, `auto_awesome`, `gamepad`, `nightlight`, `center_focus_strong`, `spa`.
- Mapper UI mengubah nama ke `IconData`.
- Jangan simpan kode `IconData.codePoint` tanpa font family karena rawan berubah.

## 5. DAO Responsibilities

### BookDao

Method target:

- `Future<List<BookRow>> getAllBooks({BookSort sort})`
- `Future<BookRow?> getBookById(int id)`
- `Future<int> insertBook(BookRow row)`
- `Future<void> updateBook(BookRow row)`
- `Future<void> deleteBook(int id)`
- `Future<List<BookRow>> searchBooks(String query, {BookStatus? status})`
- `Future<List<BookRow>> getRecentlyFinished({int limit = 5})`
- `Future<List<BookRow>> getCurrentlyReading()`

### TagDao

Method target:

- `Future<List<TagRow>> getAllTags()`
- `Future<int> upsertTag(String name)`
- `Future<void> setBookTags(int bookId, List<String> names)`
- `Future<List<TagRow>> getTagsForBook(int bookId)`

### ReadingGoalDao

Method target:

- `Future<ReadingGoalRow?> getGoalByYear(int year)`
- `Future<int> upsertGoal({required int year, required int targetBooks})`

### ProgressHistoryDao

Method target:

- `Future<void> insertProgress({required int bookId, required int page, required DateTime recordedAt})`
- `Future<List<ProgressHistoryRow>> getForBook(int bookId)`
- `Future<Map<int, int>> getBooksFinishedPerMonth(int year)`

### SettingsDao

Method target:

- `Future<String?> getValue(String key)`
- `Future<void> setValue(String key, String value)`

## 6. Initial Migration

`onCreate` version 1 harus:

1. Enable foreign keys.
2. Create semua tabel.
3. Create semua index.
4. Insert default settings:

```sql
INSERT INTO app_settings (key, value, updated_at)
VALUES ('theme_mode', 'system', ?);
```

Catatan sqflite:

- Jalankan `PRAGMA foreign_keys = ON` pada `onConfigure`.
- Gunakan transaction untuk operasi yang menyentuh `books`, `tags`, dan `book_tags` sekaligus.

## 7. Data Validation

Validasi dilakukan dua lapis:

- UI/controller memberi pesan ramah ke pengguna.
- Database `CHECK` constraint menjaga data tetap valid.

Rules:

- `title` tidak boleh kosong.
- `current_page` minimal 0.
- Jika `total_pages` ada, `current_page <= total_pages`.
- `rating` harus null atau 1-5.
- `target_books` minimal 1.
- Tag name di-trim dan tidak boleh kosong.

## 8. Future Migration Ideas

- FTS table untuk search title/author/review.
- `reading_sessions` untuk timer.
- `quotes` untuk highlight.
- `book_exports` atau metadata backup.
- `sync_state` jika cloud sync ditambahkan.
