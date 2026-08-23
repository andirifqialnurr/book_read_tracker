# PRD - Shelf Book Read Tracker

## 1. Ringkasan

Shelf adalah aplikasi mobile Flutter untuk personal reading journal. Pengguna dapat menyimpan daftar buku, mengatur status baca, memperbarui progress halaman, memberi rating dan review pribadi, serta melihat statistik membaca lokal.

Aplikasi bersifat offline-first, single user, dan menggunakan database lokal SQLite melalui `sqflite`. Metadata buku pada MVP dimasukkan manual agar aplikasi tetap dapat digunakan tanpa internet.

## 2. Tujuan Produk

- Membuat personal library yang sederhana, hangat, dan nyaman dilihat.
- Membuat update progress membaca dapat dilakukan cepat dari Home atau Book Detail.
- Menjadikan review pribadi sebagai fitur utama, bukan fitur sosial.
- Menampilkan statistik membaca yang berguna tanpa gamification berlebihan.
- Menjaga desain editorial hangat yang sudah ada di `lib/main.dart`, dengan dukungan light mode dan dark mode.

## 3. Target Pengguna

- Pembaca pribadi yang ingin mencatat buku yang akan dibaca, sedang dibaca, selesai dibaca, atau ditinggalkan.
- Pengguna yang mengutamakan catatan offline dan tidak membutuhkan login, cloud sync, atau fitur sosial.

## 4. Scope MVP

Termasuk:

- Tambah, edit, hapus, dan lihat detail buku.
- Status buku: `wantToRead`, `reading`, `finished`, `dropped`.
- Progress halaman: `currentPage` dan `totalPages`.
- Rating 1 sampai 5, review teks, tanggal mulai, dan tanggal selesai.
- Genre dan tag.
- Search title/author.
- Filter status dan sort library.
- Annual reading goal.
- Statistik lokal.
- Cover lokal opsional dan cover fallback bergaya editorial.
- Light mode dan dark mode.
- Persistensi lokal dengan `sqflite`.

Tidak termasuk MVP:

- Login dan multi-user.
- Social/following.
- Cloud library atau cloud sync.
- Online book API, ISBN lookup, atau scanner.
- Marketplace.
- AI summary.
- Audiobook tracking kompleks.

## 5. Navigasi

Bottom navigation terdiri dari:

- Home
- Library
- Add Book
- Stats

Settings ditempatkan sebagai action dari Home atau halaman Settings terpisah bila kebutuhan preferensi bertambah.

## 6. Status Buku

Status yang digunakan:

- `wantToRead`: buku masuk daftar ingin dibaca.
- `reading`: buku sedang dibaca.
- `finished`: buku selesai dibaca.
- `dropped`: buku ditinggalkan.

Aturan status:

- Mengubah status ke `finished` menawarkan input finished date, rating, dan review.
- Rating dan review boleh kosong.
- Mengubah status dari `finished` ke status lain tidak boleh menghapus rating, review, atau finished date secara otomatis.
- Jika `currentPage` mencapai `totalPages`, aplikasi menawarkan `Mark as Finished`, tetapi tidak memaksa.

## 7. Core Flow

### Add Book

Alur:

`Add Book -> Cover -> Title -> Author -> Page count -> Genre/Tags -> Status -> Save`

Ketentuan:

- Field wajib hanya `title`.
- `author` boleh kosong dan ditampilkan sebagai `Unknown author`.
- `totalPages`, `publicationYear`, `genre`, `tags`, dan cover dapat dilengkapi kemudian.

### Update Progress

Alur:

`Currently Reading / Book Detail -> Update Progress -> Current page -> Save`

Ketentuan:

- `currentPage` tidak boleh kurang dari 0.
- Jika `totalPages` diketahui, `currentPage` tidak boleh melebihi `totalPages`.
- Persentase progress dihitung otomatis dari `currentPage / totalPages`.
- Progress update dicatat ke `progress_history`.

### Finish and Review

Alur:

`Finish Book -> Finished date -> Rating -> Review -> Save`

Ketentuan:

- `finishedAt` default ke tanggal hari ini, tetapi dapat diedit.
- Rating MVP menggunakan integer star 1 sampai 5.
- Review multiline dan boleh kosong.

## 8. Screen Requirements

### Home

- Header editorial dengan greeting dan action toggle theme.
- `Currently Reading` sebagai konten utama.
- Horizontal cards jika ada lebih dari satu buku yang sedang dibaca.
- Progress bar dan teks `current / total pages`.
- CTA `Update`.
- Reading goal tahun aktif, contoh `14 of 24 books`.
- Recently Finished.
- Empty state untuk pengguna baru.

### Library

- Search title/author.
- Filter chips: All books, Want to read, Reading, Finished, Dropped.
- Sort: Recently Added, Title, Rating, Finished Date.
- Grid 2-column untuk viewport yang cukup.
- Layout tetap aman pada layar kecil.
- Cover fallback tetap menarik jika pengguna tidak memilih gambar.

### Book Detail

- Cover, title, author, status.
- Progress halaman.
- Genre dan tags.
- Started date dan finished date.
- Rating dan review pribadi.
- Actions: Update Progress, Finish/Edit Review, Edit Book, Change Status, Delete.

### Add/Edit Book

- Cover picker.
- Title, author, page count, publication year.
- Genre dan tags.
- Status.
- Started date muncul untuk status `reading` atau `finished`.
- Finished date, rating, dan review muncul untuk status `finished`.

### Stats

- Books finished year-to-date.
- Pages read.
- Average rating.
- Favorite genre.
- Books per month.
- Annual goal progress.

## 9. Business Rules

- Annual goal dihitung dari jumlah buku `finished` dalam calendar year.
- Pages read menggunakan data `currentPage`; untuk buku `finished`, `currentPage` sebaiknya disamakan dengan `totalPages` jika tersedia.
- Buku tanpa `totalPages` tetap dapat disimpan dan dibaca, tetapi progress persentase tidak ditampilkan.
- Cover lokal disimpan sebagai file lokal; database hanya menyimpan URI/path.
- Search dan filter harus bekerja dari data SQLite lokal.

## 10. State Management

State management yang dipilih untuk implementasi berikutnya adalah Riverpod (`flutter_riverpod`).

Alasan:

- Cocok untuk aplikasi Flutter kecil-menengah yang akan bertumbuh.
- Memisahkan UI, state, repository, dan database dengan jelas.
- Mudah diuji tanpa bergantung pada widget tree.
- Cocok untuk state async dari `sqflite`.

State utama:

- `booksProvider`: daftar buku dari repository.
- `libraryFilterProvider`: query, status filter, dan sort.
- `readingGoalProvider`: goal tahun aktif.
- `themeModeProvider`: light/dark/system preference.
- Derived providers untuk currently reading, recently finished, stats, dan filtered library.

## 11. Acceptance Criteria

- Pengguna dapat menambah buku tanpa internet dan data tetap ada setelah restart.
- Status dan progress dapat diubah tanpa kehilangan review atau data lain.
- Buku selesai dihitung benar di goal dan statistics.
- Search/filter Library bekerja dari SQLite lokal.
- UI tetap usable untuk buku tanpa cover atau page count.
- Light mode dan dark mode tersedia dengan tema warna yang konsisten dengan prototype sekarang.
- `lib/main.dart` tidak lagi berisi seluruh model, state, halaman, helper, dan widget dalam satu file setelah tahap implementasi refactor.

## 12. V2

- ISBN scanner.
- Open Library atau Google Books metadata.
- Reading sessions/timer.
- Quotes/highlights.
- Export library.
- Backup/restore.
- Home-screen widget.
- Cloud sync.
