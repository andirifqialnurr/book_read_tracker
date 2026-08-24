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
- [ ] Pastikan search/filter bekerja dari provider.

### Books

- [ ] Buat `lib/features/books/book_detail_page.dart`.
- [x] Buat `lib/features/books/book_form_page.dart`.
- [x] Buat `lib/features/books/widgets/book_cover.dart`.
- [x] Buat `lib/features/books/widgets/cover_picker.dart`.
- [x] Buat `lib/features/books/widgets/progress_sheet.dart`.
- [x] Buat `lib/features/books/widgets/finish_review_sheet.dart`.
- [ ] Tambahkan edit book flow.
- [ ] Tambahkan delete book flow dengan konfirmasi.

### Goals

- [x] Buat `lib/features/goals/widgets/goal_card.dart`.
- [ ] Buat `lib/features/goals/widgets/goal_editor_dialog.dart`.

### Stats

- [ ] Buat `lib/features/stats/stats_page.dart`.
- [ ] Buat `lib/features/stats/widgets/stat_tile.dart`.
- [ ] Buat `lib/features/stats/widgets/books_per_month_chart.dart`.
- [ ] Ganti values chart hard-coded dengan data dari provider.

## Phase 7 - Riverpod State

- [ ] Buat provider repository in-memory sementara agar refactor UI tidak langsung tergantung SQLite.
- [ ] Buat `booksProvider`.
- [ ] Buat `bookByIdProvider`.
- [ ] Buat `libraryFilterProvider`.
- [ ] Buat `filteredBooksProvider`.
- [ ] Buat `currentlyReadingProvider`.
- [ ] Buat `recentlyFinishedProvider`.
- [ ] Buat `activeReadingGoalProvider`.
- [ ] Buat `readingStatsProvider`.
- [ ] Buat `themeModeProvider`.
- [ ] Buat controller/notifier:
  - [ ] `BookFormController`
  - [ ] `BookDetailController`
  - [ ] `LibraryFilterController`
  - [ ] `ReadingGoalController`
  - [ ] `ThemeController`

## Phase 8 - sqflite Persistence

- [ ] Buat `lib/core/database/app_database.dart`.
- [ ] Buat `lib/core/database/migrations.dart`.
- [ ] Buat `lib/core/database/table_names.dart`.
- [ ] Implement schema versi 1 sesuai `schema.md`.
- [ ] Enable foreign keys di `onConfigure`.
- [ ] Buat DAO:
  - [ ] `BookDao`
  - [ ] `TagDao`
  - [ ] `ReadingGoalDao`
  - [ ] `ProgressHistoryDao`
  - [ ] `SettingsDao`
- [ ] Buat mapper row/domain:
  - [ ] `BookMapper`
  - [ ] `ReadingGoalMapper`
- [ ] Buat repository sqflite:
  - [ ] `SqfliteBookRepository`
  - [ ] `SqfliteReadingGoalRepository`
- [ ] Ganti provider in-memory menjadi provider SQLite.
- [ ] Pastikan add/update/delete tetap refresh UI.
- [ ] Pastikan data tetap ada setelah app restart.

## Phase 9 - Cover Handling

- [ ] Tambahkan cover picker dari gallery.
- [ ] Simpan path/URI cover lokal ke `books.cover_uri`.
- [ ] Pertahankan cover fallback jika cover kosong atau file tidak tersedia.
- [ ] Simpan cover fallback color/accent/icon agar konsisten setelah restart.

## Phase 10 - Tests and Validation

- [ ] Ganti `test/widget_test.dart` template counter menjadi smoke test `ShelfApp`.
- [ ] Tambahkan unit test `Book.progress`.
- [ ] Tambahkan unit test clamp progress.
- [ ] Tambahkan mapper test row/domain.
- [ ] Tambahkan provider/controller test untuk:
  - [ ] Add book.
  - [ ] Update progress.
  - [ ] Finish book.
  - [ ] Filter library.
  - [ ] Reading goal.
- [ ] Jalankan `flutter analyze`.
- [ ] Jalankan `flutter test`.
- [ ] Jika memungkinkan, jalankan app di device/emulator dan cek light/dark secara visual.

## Phase 11 - Cleanup

- [ ] Hapus dummy seed books dari runtime utama atau pindahkan ke dev-only seed.
- [ ] Pastikan `main.dart` hanya bootstrap.
- [ ] Pastikan semua import package sesuai nama project di `pubspec.yaml`.
- [ ] Pastikan tidak ada helper private besar tersisa di screen file.
- [ ] Pastikan semua file mengikuti folder target di `architecture.md`.
- [ ] Review lagi `design-system.md` setelah implementasi untuk memastikan kontraknya masih akurat.
