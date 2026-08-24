# TODO - Shelf Book Read Tracker

## Status Awal

Dokumen awal sudah dibuat dari:

- `02-book-read-tracker-flutter-PRD.md`
- `lib/main.dart`
- `pubspec.yaml`
- `test/widget_test.dart`

Temuan utama:

- `lib/main.dart` masih mencampur app bootstrap, theme, model, in-memory state, halaman, widget, sheet, dan helper.
- Data buku dan reading goal masih in-memory, belum persist.
- Theme light/dark sudah ada dan harus dijaga.
- UI sudah punya karakter editorial hangat dan tidak boleh diganti total.
- `pubspec.yaml` belum memiliki Riverpod, sqflite, font, atau package cover picker.
- `test/widget_test.dart` masih template counter dan tidak cocok dengan app saat ini.

## Prinsip Eksekusi

- Kerjakan bertahap.
- Setiap batch harus punya tujuan jelas dan bisa divalidasi.
- Jangan mengubah desain visual besar-besaran saat memecah file.
- Jaga warna, radius, komponen, copy UI, dan struktur screen dari prototype.
- Setelah batch signifikan, jalankan minimal `flutter analyze` dan test relevan.
- Commit per batch kecil yang meaningful.
- Push hanya setelah commit berhasil.

## Phase 0 - Documentation

- [x] Buat `PRD.md`.
- [x] Buat `design-system.md`.
- [x] Buat `architecture.md`.
- [x] Buat `schema.md`.
- [x] Buat `TODO.md`.

## Phase 1 - Dependencies and Bootstrap

- [x] Tambahkan dependencies ke `pubspec.yaml`:
  - [x] `flutter_riverpod`
  - [x] `sqflite`
  - [x] `path`
  - [x] `path_provider`
  - [x] `google_fonts`
  - [x] `image_picker`
- [x] Jalankan `flutter pub get`.
- [x] Ubah `main.dart` menjadi bootstrap ringan dengan `ProviderScope`.
- [x] Buat `lib/app/shelf_app.dart`.
- [x] Buat `lib/app/shelf_shell.dart`.
- [x] Pastikan app masih bisa render setelah bootstrap dipindah.

## Phase 2 - Theme and Design Tokens

- [x] Buat `lib/core/theme/app_colors.dart`.
- [x] Buat `lib/core/theme/app_text_styles.dart`.
- [x] Buat `lib/core/theme/app_theme.dart`.
- [x] Pindahkan warna dari `main.dart` ke token theme.
- [x] Ganti helper `_serif` dan `_eyebrow` menjadi text style reusable.
- [x] Terapkan `Merriweather` untuk heading/editorial.
- [x] Terapkan `Inter` untuk body/UI.
- [x] Pastikan light mode tetap memakai:
  - [x] Background `#F8F6F1`
  - [x] Surface `#FFFDF8`
  - [x] Primary `#5B5FA8`
- [x] Pastikan dark mode tetap memakai:
  - [x] Background `#151416`
  - [x] Surface `#211F21`
  - [x] Navigation indicator `#3A3867`

## Phase 3 - Domain Models and Rules

- [x] Buat `lib/domain/books/book_status.dart`.
- [x] Buat `lib/domain/books/book.dart`.
- [x] Buat `lib/domain/books/book_rules.dart`.
- [x] Pindahkan `BookStatus` dan label/status color mapping.
- [x] Pindahkan `Book.progress`.
- [x] Tambahkan rule clamp progress:
  - [x] Page minimal 0.
  - [x] Jika `totalPages` ada, page maksimal `totalPages`.
- [x] Pastikan review/rating tidak hilang otomatis saat status berubah.

## Phase 4 - Shared Utilities

- [x] Buat `lib/core/utils/date_formatters.dart`.
- [x] Buat `lib/core/utils/number_formatters.dart`.
- [x] Pindahkan `_formatDate`.
- [x] Pindahkan `_month`.
- [x] Pindahkan `_formatNumber`.
- [x] Tambahkan unit test formatter sederhana.

## Phase 5 - Reusable Widgets

- [x] Buat `lib/shared/widgets/section_header.dart`.
- [x] Buat `lib/shared/widgets/shelf_filter_chip.dart`.
- [x] Buat `lib/shared/widgets/no_results.dart`.
- [x] Buat `lib/shared/widgets/detail_section.dart`.
- [x] Buat `lib/shared/widgets/meta_row.dart`.
- [x] Pastikan semua widget memakai token theme.
- [x] Pastikan tooltip tersedia untuk icon button yang butuh label.

## Phase 6 - Feature Widgets and Screens

### Home

- [x] Buat `lib/features/home/home_page.dart`.
- [x] Buat `lib/features/home/widgets/reading_card.dart`.
- [x] Buat `lib/features/home/widgets/finished_book_row.dart`.
- [x] Pertahankan currently reading horizontal card.
- [x] Pertahankan recently finished row compact.

### Library

- [x] Buat `lib/features/library/library_page.dart`.
- [x] Buat `lib/features/library/library_filter.dart`.
- [x] Buat `lib/features/library/widgets/library_book_card.dart`.
- [x] Tambahkan sort state: Recently Added, Title, Rating, Finished Date.
- [x] Pastikan search/filter bekerja dari provider.

### Books

- [x] Buat `lib/features/books/book_detail_page.dart`.
- [x] Buat `lib/features/books/book_form_page.dart`.
- [x] Buat `lib/features/books/widgets/book_cover.dart`.
- [x] Buat `lib/features/books/widgets/cover_picker.dart`.
- [x] Buat `lib/features/books/widgets/progress_sheet.dart`.
- [x] Buat `lib/features/books/widgets/finish_review_sheet.dart`.
- [x] Tambahkan edit book flow.
- [x] Tambahkan delete book flow dengan konfirmasi.

### Goals

- [x] Buat `lib/features/goals/widgets/goal_card.dart`.
- [x] Buat `lib/features/goals/widgets/goal_editor_dialog.dart`.

### Stats

- [x] Buat `lib/features/stats/stats_page.dart`.
- [x] Buat `lib/features/stats/widgets/stat_tile.dart`.
- [x] Buat `lib/features/stats/widgets/books_per_month_chart.dart`.
- [x] Ganti values chart hard-coded dengan data buku aktif.
- [x] Hubungkan chart stats ke provider.

## Phase 7 - Riverpod State

- [x] Buat provider repository in-memory sementara agar refactor UI tidak langsung tergantung SQLite.
- [x] Buat `booksProvider`.
- [x] Buat `bookByIdProvider`.
- [x] Buat `libraryFilterProvider`.
- [x] Buat `filteredBooksProvider`.
- [x] Buat `currentlyReadingProvider`.
- [x] Buat `recentlyFinishedProvider`.
- [x] Buat `activeReadingGoalProvider`.
- [x] Buat `readingStatsProvider`.
- [x] Buat `themeModeProvider`.
- [x] Buat controller/notifier:
  - [x] `BookFormController`
  - [x] `BookDetailController`
  - [x] `LibraryFilterController`
  - [x] `ReadingGoalController`
  - [x] `ThemeController`

## Phase 8 - sqflite Persistence

- [x] Buat `lib/core/database/app_database.dart`.
- [x] Buat `lib/core/database/migrations.dart`.
- [x] Buat `lib/core/database/table_names.dart`.
- [x] Implement schema versi 1 sesuai `schema.md`.
- [x] Enable foreign keys di `onConfigure`.
- [x] Buat DAO:
  - [x] `BookDao`
  - [x] `TagDao`
  - [x] `ReadingGoalDao`
  - [x] `ProgressHistoryDao`
  - [x] `SettingsDao`
- [x] Buat mapper row/domain:
  - [x] `BookMapper`
  - [x] `ReadingGoalMapper`
- [x] Buat repository sqflite:
  - [x] `SqfliteBookRepository`
  - [x] `SqfliteReadingGoalRepository`
- [x] Ganti provider in-memory menjadi provider SQLite.
- [x] Pastikan add/update/delete tetap refresh UI.
- [x] Pastikan data tetap ada setelah app restart.

## Phase 9 - Cover Handling

- [x] Tambahkan cover picker dari gallery.
- [x] Simpan path/URI cover lokal ke `books.cover_uri`.
- [x] Pertahankan cover fallback jika cover kosong atau file tidak tersedia.
- [x] Simpan cover fallback color/accent/icon agar konsisten setelah restart.

## Phase 10 - Tests and Validation

- [x] Ganti `test/widget_test.dart` template counter menjadi smoke test `ShelfApp`.
- [x] Tambahkan unit test `Book.progress`.
- [x] Tambahkan unit test clamp progress.
- [x] Tambahkan mapper test row/domain.
- [x] Tambahkan provider/controller test untuk:
  - [x] Add book.
  - [x] Update progress.
  - [x] Finish book.
  - [x] Filter library.
  - [x] Reading goal.
- [x] Jalankan `flutter analyze`.
- [x] Jalankan `flutter test`.
- [x] Jika memungkinkan, jalankan app di device/emulator dan cek light/dark secara visual. Tidak tersedia di environment ini: `flutter devices` menggantung dan checkout tidak berisi folder platform runtime.

## Phase 11 - Cleanup

- [x] Hapus dummy seed books dari runtime utama atau pindahkan ke dev-only seed.
- [x] Pastikan `main.dart` hanya bootstrap.
- [x] Pastikan semua import package sesuai nama project di `pubspec.yaml`.
- [ ] Pastikan tidak ada helper private besar tersisa di screen file.
- [ ] Pastikan semua file mengikuti folder target di `architecture.md`.
- [ ] Review lagi `design-system.md` setelah implementasi untuk memastikan kontraknya masih akurat.
