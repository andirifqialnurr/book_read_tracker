# Architecture - Shelf Book Read Tracker

## 1. Kondisi Implementasi

`lib/main.dart` sekarang hanya berisi bootstrap Flutter dan `ProviderScope`.
Implementasi utama sudah dipisahkan ke layer berikut:

- `app` untuk `ShelfApp` dan shell navigasi.
- `core` untuk theme, database helper, migration, table names, dan formatter.
- `domain` untuk model, enum, rules, dan repository contract.
- `data` untuk DAO, mapper, dan repository SQLite.
- `features` untuk screen, provider/controller, sheet, dan widget per fitur.
- `shared` untuk widget reusable lintas fitur.

Runtime utama memakai SQLite melalui `sqflite`. In-memory repository tetap ada sebagai test/fallback override tanpa dummy seed runtime.

## 2. Architectural Goals

- UI, state, business logic, database, dan model dipisahkan jelas.
- Semua data utama persist ke SQLite melalui `sqflite`.
- State async dari database dikelola dengan Riverpod.
- Komponen UI reusable berada di file terpisah.
- Theme light/dark menjadi kontrak reusable, bukan fungsi private di `main.dart`.
- Struktur folder mudah bertumbuh untuk fitur V2 seperti ISBN scanner, export, dan backup.

## 3. State Management

State management yang dipakai: `flutter_riverpod`.

Paket target:

- `flutter_riverpod`
- `sqflite`
- `path`
- `path_provider`
- `google_fonts`
- `image_picker` untuk cover lokal opsional

Alasan Riverpod:

- Tidak bergantung pada `BuildContext`.
- Cocok untuk repository async berbasis SQLite.
- Mudah membuat derived state untuk filter, stats, goal, dan theme.
- Memudahkan unit test provider dan repository.

## 4. Layering

Struktur layer:

- `app`: bootstrap aplikasi, shell navigation, dan route-level wiring.
- `core`: theme, constants, database helper, shared utilities, error/result primitives.
- `data`: DTO/entity persistence, DAO, repository implementation.
- `domain`: model domain, enum, business rules, repository contract.
- `features`: screen, provider, controller/notifier, dan widget per fitur.
- `shared`: widget reusable lintas fitur.

Dependency direction:

`UI -> providers/controllers -> repositories -> dao/database`

Aturan:

- UI tidak boleh memanggil `sqflite` langsung.
- Provider tidak boleh menyimpan widget controller seperti `TextEditingController`.
- Repository mengembalikan domain model, bukan row map mentah.
- DAO bertanggung jawab atas SQL dan mapping row.
- Business rules seperti clamp progress ada di controller/domain service, bukan tersebar di widget.

## 5. Folder Structure Aktual

```text
lib/
  main.dart
  app/
    shelf_app.dart
    shelf_shell.dart
  core/
    database/
      app_database.dart
      migrations.dart
      table_names.dart
    theme/
      app_colors.dart
      app_theme.dart
      app_text_styles.dart
      theme_providers.dart
    utils/
      date_formatters.dart
      number_formatters.dart
  domain/
    books/
      book.dart
      book_status.dart
      book_repository.dart
      book_rules.dart
    goals/
      reading_goal.dart
      reading_goal_repository.dart
  data/
    books/
      book_dao.dart
      book_mapper.dart
      sqflite_book_repository.dart
    goals/
      reading_goal_dao.dart
      reading_goal_mapper.dart
      sqflite_reading_goal_repository.dart
    progress/
      progress_history_dao.dart
    settings/
      settings_dao.dart
    tags/
      tag_dao.dart
  features/
    home/
      home_page.dart
      widgets/
        finished_book_row.dart
        reading_card.dart
    library/
      library_page.dart
      library_filter.dart
      library_providers.dart
      widgets/
        library_book_card.dart
    books/
      book_detail_page.dart
      book_form_page.dart
      book_providers.dart
      widgets/
        book_cover.dart
        cover_picker.dart
        finish_review_sheet.dart
        progress_sheet.dart
    goals/
      goal_providers.dart
      widgets/
        goal_card.dart
        goal_editor_dialog.dart
    stats/
      stats_page.dart
      stats_providers.dart
      widgets/
        books_per_month_chart.dart
        stat_tile.dart
  shared/
    widgets/
      detail_section.dart
      meta_row.dart
      no_results.dart
      section_header.dart
      shelf_filter_chip.dart
```

`main.dart` target akhir hanya berisi bootstrap:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ShelfApp()));
}
```

## 6. Provider Plan

Provider utama:

- `appDatabaseProvider`: membuka database SQLite.
- `bookRepositoryProvider`: menyediakan repository buku SQLite sebagai default.
- `booksProvider`: memuat semua buku.
- `bookByIdProvider`: memuat satu buku berdasarkan id.
- `libraryFilterProvider`: menyimpan query, status filter, dan sort.
- `filteredBooksProvider`: derived provider dari `booksProvider` dan filter.
- `currentlyReadingProvider`: derived provider untuk Home.
- `recentlyFinishedProvider`: derived provider untuk Home.
- `activeReadingGoalProvider`: repository/controller goal untuk tahun berjalan.
- `readingStatsProvider`: statistik dari books aktif.
- `themeModeProvider`: mode theme aktif.

Controller/notifier target:

- `BookFormController`: save add/edit.
- `BookDetailController`: update progress, finish review, change status, delete.
- `LibraryFilterController`: search/filter/sort.
- `ReadingGoalController`: update goal.
- `ThemeController`: toggle light/dark.

## 7. Data Flow

### Add Book

1. UI form mengirim input ke `BookFormController`.
2. Controller validasi `title`, angka halaman, tahun, dan status.
3. Controller membuat domain model.
4. Repository menyimpan ke SQLite via DAO.
5. Provider invalidate/refetch `booksProvider`.
6. UI pindah ke Library dan menampilkan snackbar.

### Update Progress

1. UI sheet mengirim page baru.
2. Controller clamp page berdasarkan `totalPages`.
3. Repository update `books.current_page`.
4. Repository insert row ke `progress_history`.
5. Provider books/stats di-refresh.
6. Jika page mencapai total pages, controller dapat memicu tawaran finish.

### Finish Book

1. UI sheet mengirim rating, review, dan finished date.
2. Controller validasi rating 1 sampai 5 jika terisi.
3. Repository update status `finished`, rating, review, `finished_at`, dan `updated_at`.
4. Review lama tidak dihapus kecuali pengguna mengosongkannya secara eksplisit di edit form.

## 8. Routing

MVP dapat tetap memakai `Navigator` bawaan:

- Shell tab: Home, Library, Add Book, Stats.
- Detail dan Edit dibuka melalui `MaterialPageRoute`.

Belum perlu router package sampai aplikasi membutuhkan deep link, nested routes, atau URL sync.

## 9. Persistence

Database:

- Engine: SQLite lokal via `sqflite`.
- Database file: `shelf.db`.
- Version awal: `1`.
- Migration ditulis eksplisit di `migrations.dart`.

Tabel minimal:

- `books`
- `tags`
- `book_tags`
- `reading_goals`
- `progress_history`
- `app_settings`

Detail struktur tabel ada di `schema.md`.

## 10. Error Handling

- DAO melempar error database mentah hanya ke repository.
- Repository mengubah error menjadi exception/domain failure yang jelas.
- UI menampilkan pesan pendek melalui snackbar atau empty/error state.
- Error state tidak boleh membuat screen blank.

## 11. Testing Strategy

Test yang sudah tersedia:

- Unit test untuk `Book.progress` dan business rules clamp progress.
- Unit test mapper SQLite row <-> domain.
- Provider/controller test untuk add, update progress, finish book, filter, dan stats.
- Widget smoke test untuk `ShelfApp`.
- Widget test untuk cover fallback ketika file lokal tidak tersedia.

## 12. Migration Strategy Dari `main.dart`

Urutan refactor yang sudah dijalankan:

1. Pindahkan enum/model/helper murni tanpa mengubah behavior.
2. Pindahkan theme ke `core/theme`.
3. Pindahkan reusable widgets.
4. Pindahkan screen per fitur.
5. Pasang Riverpod dengan state in-memory terlebih dahulu agar UI tetap berjalan.
6. Tambahkan `sqflite` repository dan migration.
7. Ganti provider in-memory menjadi provider repository SQLite.
8. Perbaiki test.

Dengan urutan ini, perubahan desain dijaga sambil memindahkan data utama ke SQLite.
