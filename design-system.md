# Design System - Shelf

## 1. Design Direction

Shelf menggunakan gaya editorial, hangat, personal, dan modern. UI harus terasa seperti reading journal pribadi, bukan storefront atau marketplace buku.

Prinsip utama:

- Cover buku menjadi elemen visual utama.
- Warna UI tetap tenang; warna kuat muncul sebagai accent dan cover fallback.
- Layout mobile-first, portrait-first, dan safe-area aware.
- Review diberi ruang baca yang nyaman.
- Light mode dan dark mode wajib setara, bukan dark mode hasil invert otomatis.

## 2. Theme Mode

Aplikasi mendukung:

- `ThemeMode.light`
- `ThemeMode.dark`
- `ThemeMode.system` sebagai target preferensi setelah state/persistence siap

Prototype saat ini memakai toggle manual di `ShelfApp`. Implementasi berikutnya harus memindahkan state theme ke provider dan menyimpan preferensi di database/local settings.

## 3. Color Tokens

Warna di bawah diambil dari `lib/main.dart` dan harus dijaga sebagai identitas visual awal.

### Core

| Token | Light | Dark | Penggunaan |
| --- | --- | --- | --- |
| `appBackground` | `#F8F6F1` | `#151416` | Scaffold background |
| `surface` | `#FFFDF8` | `#211F21` | Card, sheet, stat tile |
| `primary` | `#5B5FA8` | `#B9B9F1` via scheme/status | CTA, focus, chart active |
| `onSurface` | `#272426` | `#FFFFFF` | Teks utama |
| `inputFill` | `#FFFFFF` | `#29272A` | Text field |
| `inputBorder` | `#EBE7DF` | `#3A373B` | Text field border |
| `navBackground` | `#FFFFFF` | `#211F21` | Bottom navigation |
| `navIndicator` | `#E8E7FA` | `#3A3867` | Selected nav destination |
| `star` | `#D89547` | `#D89547` | Rating |

### Status

| Status | Light | Dark |
| --- | --- | --- |
| Want to read | `#7C6A55` | `#D7B995` |
| Reading | `#5B5FA8` | `#B9B9F1` |
| Finished | `#487B66` | `#A4D1B7` |
| Dropped | `#A05C56` | `#E0ABA4` |

### Cover Fallback Palette

Cover fallback boleh memakai kombinasi dari prototype:

- Indigo: `#5B5FA8` dengan accent `#DEDCFF`
- Terracotta: `#D87555` dengan accent `#FFD9C4`
- Green: `#477765` dengan accent `#D4EDDF`
- Coral: `#E07B57` dengan accent `#FFDBBE`
- Teal: `#426B70` dengan accent `#C8EBE2`
- Night blue: `#333B77` dengan accent `#F3D99A`
- Deep blue: `#314B65` dengan accent `#B7D2E5`
- Leaf: `#54725F` dengan accent `#D2E5C8`

## 4. Typography

Font yang dipilih:

- Heading/editorial: `Merriweather`
- Body/UI: `Inter`
- Fallback heading sebelum font asset siap: `Georgia`
- Fallback body: platform default Flutter

Alasan:

- `Merriweather` menjaga nuansa serif editorial seperti prototype `Georgia`.
- `Inter` memberi keterbacaan kuat untuk form, stats, chip, dan navigation.

Skala awal:

| Token | Size | Weight | Line height | Penggunaan |
| --- | ---: | ---: | ---: | --- |
| `display` | 32 | 700 | 1.04 | Home greeting |
| `screenTitle` | 30 | 700 | 1.20 | Judul halaman |
| `sectionTitle` | 21 | 700 | 1.20 | Header section |
| `detailTitle` | 20 | 700 | 1.20 | Detail section |
| `cardTitle` | 19 | 700 | 1.10 | Reading card title |
| `body` | 14-16 | 400-600 | 1.40 | Konten umum |
| `eyebrow` | 10 | 800 | 1.00 | Status/date uppercase |

Aturan:

- Jangan memakai font size berbasis viewport.
- Text panjang harus wrap atau ellipsis sesuai konteks.
- Judul buku di card maksimal 2 baris.
- Judul buku di cover fallback maksimal 4 baris.
- Letter spacing hanya untuk eyebrow dan cover label; jangan gunakan negative letter spacing.

## 5. Shape and Spacing

Radius:

- `cover`: 12
- `input`: 16
- `chip`: 24
- `smallCard`: 18
- `mainCard`: 20-22
- `bottomSheetHandle`: 8

Spacing:

- Page horizontal padding: 20
- Section top gap: 28-30
- Card inner padding: 14-20
- Form field vertical gap: 12
- Card grid gap: 14 horizontal, 24 vertical
- Button pair gap: 10-12

Cover ratio:

- Gunakan rasio sekitar 2:3.
- Ukuran prototype:
  - Reading card cover: 100 x 148
  - Detail cover: 126 x 188
  - Finished row cover: 48 x 68
  - Library card cover: full width x 218
  - Cover picker: 128 x 166

## 6. Components

Komponen UI harus dipisah per file saat refactor. Nama file target:

| Component | Target file | Catatan |
| --- | --- | --- |
| `ShelfApp` | `lib/app/shelf_app.dart` | MaterialApp dan theme mode |
| `ShelfShell` | `lib/app/shelf_shell.dart` | Bottom navigation dan IndexedStack |
| `AppTheme` | `lib/core/theme/app_theme.dart` | ThemeData light/dark |
| `AppColors` | `lib/core/theme/app_colors.dart` | Color tokens |
| `AppTextStyles` | `lib/core/theme/app_text_styles.dart` | Text style helpers |
| `BookCover` | `lib/features/books/widgets/book_cover.dart` | Cover fallback dan cover file lokal |
| `CoverPicker` | `lib/features/books/widgets/cover_picker.dart` | Picker UI |
| `ReadingCard` | `lib/features/home/widgets/reading_card.dart` | Currently reading card |
| `FinishedBookRow` | `lib/features/home/widgets/finished_book_row.dart` | Recently finished row |
| `GoalCard` | `lib/features/goals/widgets/goal_card.dart` | Annual goal card |
| `SectionHeader` | `lib/shared/widgets/section_header.dart` | Header section reusable |
| `ShelfFilterChip` | `lib/shared/widgets/shelf_filter_chip.dart` | ChoiceChip wrapper |
| `NoResults` | `lib/shared/widgets/no_results.dart` | Empty search/filter state |
| `DetailSection` | `lib/shared/widgets/detail_section.dart` | Framed detail content |
| `MetaRow` | `lib/shared/widgets/meta_row.dart` | Label/value row |
| `StatTile` | `lib/features/stats/widgets/stat_tile.dart` | Stats tile |
| `BooksPerMonthChart` | `lib/features/stats/widgets/books_per_month_chart.dart` | Chart widget |

## 7. Screen Layout Rules

### Home

- Gunakan `CustomScrollView`.
- Header tetap editorial dengan greeting, theme toggle, dan avatar/action.
- Currently Reading horizontal card height sekitar 226.
- Reading goal tampil sebagai card primary solid.
- Recently Finished memakai row compact, bukan card besar.

### Library

- Search field berada sebelum filter chips.
- Filter chips horizontal scroll.
- Grid 2-column menjadi default untuk mobile medium/large.
- Untuk small width, pastikan title/author tidak menabrak cover atau status.

### Add/Edit Book

- Cover picker berada di tengah atas form.
- Form dibagi menjadi `Book details` dan `Shelf details`.
- CTA utama full width.
- Validasi title wajib memakai snackbar atau inline error yang konsisten.

### Book Detail

- Cover di kiri, metadata utama di kanan.
- Progress section muncul hanya jika `totalPages` tersedia.
- Review section muncul jika rating atau review tersedia.
- Action utama tetap `Update progress` dan `Finish book` / `Edit review`.

### Stats

- Goal card compact di atas.
- Stat tiles 2-column.
- Books per month chart memakai bar chart sederhana.

## 8. Interaction States

Setiap komponen wajib menangani:

- Loading data dari SQLite.
- Empty library.
- Empty currently reading.
- Empty recently finished.
- No search result.
- Book tanpa cover.
- Book tanpa total pages.
- Judul/author sangat panjang.
- Error database.
- Light mode.
- Dark mode.

## 9. Accessibility

- Icon button harus punya tooltip.
- Warna status tidak boleh menjadi satu-satunya pembeda; label status tetap ditampilkan.
- Target tap minimal 44 x 44.
- Teks pada button tidak boleh overflow.
- Contrast light/dark harus dicek setelah refactor theme.

## 10. Implementation Notes

- Jangan mengubah karakter visual utama saat memecah file.
- Jangan mengganti semua radius menjadi satu angka global; pertahankan variasi yang sudah menjadi bahasa visual prototype.
- Hindari card di dalam card kecuali konten detail benar-benar membutuhkan frame.
- Gunakan `Theme.of(context)` dan token theme, bukan warna hard-coded tersebar di widget.
- Semua warna hard-coded dari prototype dipindahkan ke `AppColors`.
