# PRD — Shelf: Book Read Tracker

**Platform:** Mobile — Flutter  
**Persistence:** `sqflite` / SQLite lokal  
**Mode:** Offline-first, single user  
**Prototype target:** Lovable

## 1. Ringkasan produk

Shelf adalah personal reading journal. Pengguna menyimpan buku yang ingin dibaca, sedang dibaca, selesai, atau ditinggalkan; mencatat progress; lalu memberi rating dan review. Metadata buku pada MVP dimasukkan manual sehingga aplikasi benar-benar dapat digunakan offline.

## 2. Tujuan

- Membuat personal library yang sederhana dan menyenangkan dilihat.
- Membuat update progress membaca hanya membutuhkan beberapa tap.
- Menjadikan review pribadi sebagai bagian penting, bukan fitur sosial.
- Menampilkan statistik membaca tanpa gamification berlebihan.

## 3. Scope MVP

Termasuk: tambah/edit buku, cover dari gallery/camera opsional, status reading, progress halaman, rating, review, reading dates, tags/genre, reading goal tahunan, statistik lokal, search/filter, dark/light.

Tidak termasuk: login, social/following, cloud library, online book API/ISBN lookup, marketplace, AI summary, audiobook tracking kompleks.

## 4. Navigasi

Bottom navigation:

1. Home
2. Library
3. Add Book (`+` dapat menjadi FAB)
4. Stats

Settings tersedia dari Home/Profile action.

## 5. Status buku

- `WANT_TO_READ`
- `READING`
- `FINISHED`
- `DROPPED`

Perubahan ke `FINISHED` menawarkan input finished date, rating, dan review. Rating/review boleh dilewati.

## 6. Core flow

### Add book

`Add → Cover → Title → Author → Page count → Genre/Tags → Status → Save`

Field wajib hanya Title. Data lain dapat dilengkapi kemudian.

### Reading progress

`Currently Reading → book → Update Progress → current page → Save`

Persentase dihitung otomatis jika total pages tersedia.

### Finish & review

`Mark Finished → finished date → rating → review → Save`

## 7. Screen requirements

### Home

- `Currently Reading` sebagai konten utama; jika lebih dari satu gunakan horizontal cards.
- Progress bar + `current / total pages`.
- CTA `Update progress`.
- Reading goal tahun aktif, misalnya `14 / 24 books`.
- Recently Finished.
- Empty state untuk pengguna baru.

### Library

- Search title/author.
- Filter chips: All, Want to Read, Reading, Finished, Dropped.
- Sort: Recently Added, Title, Rating, Finished Date.
- Grid 2-column untuk cover pada medium/large; list atau compact 2-column yang aman pada small.
- Cover fallback yang tetap menarik ketika user tidak memasukkan gambar.

### Book Detail

- Cover, title, author, status.
- Page progress.
- Genre/tags.
- Started/finished dates.
- Personal rating.
- Full personal review.
- Actions: Update Progress, Change Status, Edit.

### Add/Edit Book

- Cover picker.
- Title, author, page count, publication year opsional.
- Genre dan custom tags.
- Status.
- Started date muncul relevan untuk Reading/Finished.

### Finish Review Sheet/Screen

- Celebration yang subtle, bukan confetti berlebihan.
- 1–5 star rating mendukung half-star hanya jika implementasi dipilih; MVP boleh integer stars.
- Multiline review.
- Finished date.

### Stats

- Books finished year-to-date.
- Pages read berdasarkan progress/finished data yang tersedia.
- Average rating.
- Favorite genre berdasarkan count.
- Books per month bar chart.
- Annual goal progress.

## 8. Business rules

- Progress tidak boleh <0 atau > total pages jika total pages diketahui.
- Jika current page mencapai total pages, tawarkan `Mark as Finished`; jangan memaksa.
- `FINISHED` menambah finished date; user boleh mengubahnya.
- Mengubah Finished kembali ke Reading tidak boleh menghapus review secara otomatis.
- Annual goal adalah jumlah buku selesai pada calendar year.
- Cover lokal disimpan sebagai file lokal; database menyimpan URI/path yang dikelola aplikasi.

## 9. Model data lokal

### books
`id, title, author?, cover_uri?, total_pages?, current_page, status, genre?, publication_year?, started_at?, finished_at?, rating?, review?, created_at, updated_at`

### tags
`id, name`

### book_tags
`book_id, tag_id`

### reading_goals
`id, year, target_books`

### progress_history
`id, book_id, page, recorded_at`

Progress history memberi data yang cukup untuk fitur statistik V2 tanpa membebani MVP.

## 10. Arahan desain Lovable

Karakter: editorial, hangat, personal, seperti rak buku modern. Gunakan cream/warm neutral pada light mode, ink/charcoal pada dark mode, dengan accent indigo atau terracotta yang terkendali. Cover buku menjadi sumber warna utama; UI tidak perlu terlalu berwarna.

- Typography hierarki kuat untuk judul/author.
- Cover aspect ratio konsisten sekitar 2:3.
- Tidak meniru storefront/marketplace.
- Review mendapat ruang baca yang nyaman.
- Empty state boleh menggunakan ilustrasi sederhana berupa buku, bukan karakter kompleks.

### Adaptive mobile

- Small 320–359dp: prioritaskan list/cover kecil, title wrap maksimal 2 baris.
- Medium 360–399dp: baseline.
- Large ≥400dp: cover/grid lebih lega tanpa desktop layout.
- Portrait-first dan safe-area aware.

## 11. State wajib

New user/no books, currently reading, completed library, no search result, missing cover, very long title/author, book without page count, light/dark states.

## 12. Acceptance criteria

- User dapat menambah buku tanpa internet dan menemukan kembali setelah restart.
- Status dan progress dapat diubah tanpa kehilangan review/data lain.
- Buku selesai dihitung benar di goal/statistics.
- Search/filter Library bekerja dari SQLite lokal.
- UI tetap usable untuk buku tanpa cover atau page count.

## 13. V2

ISBN scanner, Open Library/Google Books metadata, reading sessions/timer, quotes/highlights, export library, backup/restore, home-screen widget, dan cloud sync.

