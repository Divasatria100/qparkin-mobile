# Requirements Document: Point Page Enhancement

## Introduction

Halaman Poin (Point Page) adalah komponen penting dalam aplikasi QPARKIN yang menampilkan sistem reward poin kepada pengguna. Berdasarkan dokumen SKPPL, sistem poin berfungsi sebagai mekanisme reward untuk setiap transaksi parkir yang berhasil, dan poin tersebut dapat digunakan untuk memotong tarif parkir di masa mendatang.

Saat ini, file `point_page.dart` masih kosong dan belum diimplementasikan. Enhancement ini bertujuan untuk membangun halaman poin yang informatif, user-friendly, dan terintegrasi penuh dengan alur parkir aplikasi QPARKIN.

## Glossary

- **Driver**: Pengguna aplikasi QPARKIN yang melakukan transaksi parkir
- **Poin Reward**: Sistem reward yang diberikan kepada pengguna berdasarkan transaksi parkir, yang dapat ditukarkan sebagai diskon atau pembayaran
- **Saldo Poin**: Total poin yang dimiliki pengguna saat ini (disimpan di `user.saldo_poin`)
- **Riwayat Poin**: Catatan historis semua perubahan poin (penambahan dan pengurangan) yang disimpan di tabel `riwayat_poin`
- **Penalty**: Denda yang dikenakan kepada pengguna karena melanggar ketentuan, seperti melebihi durasi booking (overstay)
- **Transaksi Parkir**: Sesi parkir lengkap dari masuk hingga keluar, tercatat di tabel `transaksi_parkir`
- **Provider**: State management pattern menggunakan ChangeNotifier untuk mengelola data dan UI state
- **API Service**: Layer yang menangani komunikasi dengan backend Laravel melalui HTTP requests

## Requirements

### Requirement 1: Tampilan Saldo Poin

**User Story:** Sebagai Driver, saya ingin melihat saldo poin saya saat ini dengan jelas, sehingga saya tahu berapa poin yang dapat saya gunakan untuk pembayaran parkir.

#### Acceptance Criteria

1. WHEN Driver membuka halaman poin, THEN sistem SHALL menampilkan saldo poin terkini dari backend API
2. WHEN saldo poin ditampilkan, THEN sistem SHALL menggunakan visual yang menarik (ikon bintang/koin dengan ukuran besar) sebagai focal point halaman
3. WHEN saldo poin berubah (setelah transaksi), THEN sistem SHALL memperbarui tampilan secara otomatis menggunakan Provider pattern
4. WHEN terjadi error saat mengambil data saldo, THEN sistem SHALL menampilkan pesan error yang informatif dengan opsi retry
5. WHEN data sedang dimuat, THEN sistem SHALL menampilkan shimmer loading indicator untuk memberikan feedback visual

### Requirement 2: Riwayat Transaksi Poin

**User Story:** Sebagai Driver, saya ingin melihat riwayat lengkap perubahan poin saya, sehingga saya dapat melacak dari mana poin berasal dan bagaimana poin digunakan.

#### Acceptance Criteria

1. WHEN Driver membuka tab riwayat poin, THEN sistem SHALL menampilkan daftar semua transaksi poin dari tabel `riwayat_poin` yang diurutkan dari terbaru ke terlama
2. WHEN menampilkan setiap item riwayat, THEN sistem SHALL menampilkan tanggal/waktu, jenis perubahan (tambah/kurang), jumlah poin, dan keterangan transaksi
3. WHEN item riwayat adalah penambahan poin, THEN sistem SHALL menampilkan dengan warna hijau dan ikon plus (+)
4. WHEN item riwayat adalah pengurangan poin (penalty atau penggunaan), THEN sistem SHALL menampilkan dengan warna merah dan ikon minus (-)
5. WHEN Driver mengetuk item riwayat yang terkait dengan transaksi parkir, THEN sistem SHALL membuka detail transaksi parkir tersebut
6. WHEN riwayat poin kosong, THEN sistem SHALL menampilkan empty state dengan pesan "Belum ada riwayat poin" dan ilustrasi yang sesuai

### Requirement 3: Filter dan Pencarian Riwayat

**User Story:** Sebagai Driver, saya ingin dapat memfilter riwayat poin berdasarkan jenis dan periode waktu, sehingga saya dapat menemukan transaksi poin tertentu dengan mudah.

#### Acceptance Criteria

1. WHEN Driver membuka halaman riwayat poin, THEN sistem SHALL menyediakan opsi filter berdasarkan jenis perubahan (Semua, Penambahan, Pengurangan)
2. WHEN Driver memilih filter jenis, THEN sistem SHALL menampilkan hanya riwayat yang sesuai dengan filter tersebut
3. WHEN Driver membuka filter periode, THEN sistem SHALL menyediakan opsi: Semua Waktu, Bulan Ini, 3 Bulan Terakhir, 6 Bulan Terakhir
4. WHEN Driver memilih filter periode, THEN sistem SHALL menampilkan hanya riwayat dalam rentang waktu yang dipilih
5. WHEN filter diterapkan, THEN sistem SHALL menampilkan indikator filter aktif dan jumlah hasil yang ditemukan

### Requirement 4: Statistik Poin

**User Story:** Sebagai Driver, saya ingin melihat statistik ringkasan poin saya, sehingga saya dapat memahami pola penggunaan dan perolehan poin.

#### Acceptance Criteria

1. WHEN Driver membuka halaman poin, THEN sistem SHALL menampilkan card statistik dengan total poin yang didapat sepanjang waktu
2. WHEN menampilkan statistik, THEN sistem SHALL menampilkan total poin yang digunakan sepanjang waktu
3. WHEN menampilkan statistik, THEN sistem SHALL menampilkan poin yang didapat bulan ini
4. WHEN menampilkan statistik, THEN sistem SHALL menampilkan poin yang digunakan bulan ini
5. WHEN data statistik dimuat, THEN sistem SHALL menghitung nilai dari data `riwayat_poin` yang difilter berdasarkan `perubahan` dan `waktu`

### Requirement 5: Informasi Cara Kerja Poin

**User Story:** Sebagai Driver baru, saya ingin memahami bagaimana sistem poin bekerja, sehingga saya dapat memaksimalkan penggunaan fitur ini.

#### Acceptance Criteria

1. WHEN Driver membuka halaman poin, THEN sistem SHALL menyediakan tombol atau link "Cara Kerja Poin"
2. WHEN Driver mengetuk "Cara Kerja Poin", THEN sistem SHALL menampilkan bottom sheet atau dialog dengan informasi lengkap
3. WHEN menampilkan informasi, THEN sistem SHALL menjelaskan cara mendapatkan poin (dari setiap transaksi parkir)
4. WHEN menampilkan informasi, THEN sistem SHALL menjelaskan cara menggunakan poin (sebagai metode pembayaran)
5. WHEN menampilkan informasi, THEN sistem SHALL menampilkan aturan konversi poin (contoh: 100 poin = Rp 1.000)
6. WHEN menampilkan informasi, THEN sistem SHALL menjelaskan tentang penalty dan pengurangan poin

### Requirement 6: Integrasi dengan Pembayaran

**User Story:** Sebagai Driver, saya ingin dapat menggunakan poin saya untuk membayar parkir, sehingga saya dapat menghemat biaya parkir.

#### Acceptance Criteria

1. WHEN Driver berada di halaman pembayaran parkir, THEN sistem SHALL menampilkan opsi "Gunakan Poin" dengan saldo poin yang tersedia
2. WHEN Driver memilih menggunakan poin, THEN sistem SHALL menampilkan slider atau input untuk memilih jumlah poin yang akan digunakan
3. WHEN poin digunakan untuk pembayaran, THEN sistem SHALL menghitung potongan biaya berdasarkan konversi poin ke rupiah
4. WHEN poin tidak mencukupi untuk membayar seluruh biaya parkir, THEN sistem SHALL menggunakan semua poin yang tersedia untuk memotong tarif parkir dan menampilkan sisa biaya yang harus dibayar dengan metode lain
5. WHEN poin mencukupi untuk membayar seluruh biaya parkir, THEN sistem SHALL menggunakan poin sesuai kebutuhan dan menyisakan poin yang tidak terpakai
6. WHEN pembayaran dengan poin berhasil, THEN sistem SHALL mencatat pengurangan poin di `riwayat_poin` dengan `perubahan='kurang'` dan `keterangan` yang jelas mencantumkan jumlah poin yang digunakan dan sisa biaya (jika ada)

### Requirement 7: Notifikasi Perubahan Poin

**User Story:** Sebagai Driver, saya ingin mendapat notifikasi setiap kali poin saya berubah, sehingga saya selalu aware dengan status poin saya.

#### Acceptance Criteria

1. WHEN Driver menyelesaikan pembayaran parkir, THEN sistem SHALL menampilkan notifikasi pop-up yang menunjukkan jumlah poin yang didapat
2. WHEN Driver menggunakan poin untuk pembayaran, THEN sistem SHALL menampilkan notifikasi konfirmasi penggunaan poin
3. WHEN Driver terkena penalty yang mengurangi poin, THEN sistem SHALL menampilkan notifikasi warning dengan penjelasan alasan penalty
4. WHEN notifikasi ditampilkan, THEN sistem SHALL menyediakan tombol "Lihat Detail" yang membuka halaman poin
5. WHEN Driver membuka aplikasi dan ada perubahan poin sejak terakhir dibuka, THEN sistem SHALL menampilkan badge notifikasi di icon halaman poin

### Requirement 8: Pull-to-Refresh dan Auto-Sync

**User Story:** Sebagai Driver, saya ingin dapat memperbarui data poin saya secara manual dan otomatis, sehingga saya selalu melihat data terkini.

#### Acceptance Criteria

1. WHEN Driver melakukan gesture pull-to-refresh di halaman poin, THEN sistem SHALL mengambil data terbaru dari backend API
2. WHEN refresh berhasil, THEN sistem SHALL menampilkan snackbar "Data berhasil diperbarui"
3. WHEN refresh gagal, THEN sistem SHALL menampilkan snackbar error dengan opsi retry
4. WHEN Driver kembali ke halaman poin dari halaman lain, THEN sistem SHALL otomatis memeriksa dan memperbarui data jika sudah lebih dari 30 detik
5. WHEN data sedang di-refresh, THEN sistem SHALL menampilkan loading indicator tanpa menghilangkan data yang sudah ada

### Requirement 9: Responsive Design dan Accessibility

**User Story:** Sebagai Driver dengan berbagai kondisi, saya ingin halaman poin dapat diakses dengan mudah di berbagai ukuran layar dan mendukung accessibility features.

#### Acceptance Criteria

1. WHEN halaman poin ditampilkan di berbagai ukuran layar Android, THEN sistem SHALL menyesuaikan layout secara responsif
2. WHEN elemen interaktif ditampilkan, THEN sistem SHALL memiliki minimum touch target 48x48 dp sesuai Material Design guidelines
3. WHEN menggunakan screen reader, THEN sistem SHALL menyediakan semantic labels yang jelas untuk semua elemen
4. WHEN teks ditampilkan, THEN sistem SHALL menggunakan contrast ratio yang memenuhi WCAG AA standards
5. WHEN animasi ditampilkan, THEN sistem SHALL menyediakan opsi untuk mengurangi motion bagi pengguna yang sensitif

### Requirement 10: Error Handling dan Offline Support

**User Story:** Sebagai Driver, saya ingin tetap dapat melihat data poin saya meskipun koneksi internet bermasalah, sehingga pengalaman saya tidak terganggu.

#### Acceptance Criteria

1. WHEN koneksi internet terputus, THEN sistem SHALL menampilkan data poin terakhir yang di-cache dengan indikator "Data mungkin tidak terkini"
2. WHEN terjadi error dari backend API, THEN sistem SHALL menampilkan pesan error yang user-friendly dengan kode error untuk debugging
3. WHEN timeout terjadi saat mengambil data, THEN sistem SHALL menampilkan pesan "Koneksi lambat" dengan opsi retry
4. WHEN data berhasil dimuat setelah error, THEN sistem SHALL menghapus pesan error dan menampilkan data terbaru
5. WHEN Driver mencoba melakukan aksi yang memerlukan koneksi (seperti menggunakan poin) saat offline, THEN sistem SHALL menampilkan pesan "Memerlukan koneksi internet"
