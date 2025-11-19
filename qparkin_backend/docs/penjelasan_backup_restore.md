# Penjelasan Backup and Restore untuk QParkIn Backend

## Pendahuluan
Backup and Restore adalah proses penting untuk melindungi integritas dan ketersediaan basis data. Dalam QParkIn (sistem parkir berbasis Laravel), fitur ini memastikan data seperti transaksi parkir, informasi pengguna, dan riwayat pembayaran dapat dipulihkan dari kehilangan akibat insiden seperti hardware failure, serangan cyber, atau error manusia.

## Status Implementasi Saat Ini
**Belum ada fitur keamanan basis data yang diterapkan untuk Backup and Restore pada website admin mall dan superadmin.** Sistem saat ini hanya memiliki file dump manual `qparkin.sql` (dari phpMyAdmin), yang bukanlah mekanisme otomatis. Laravel tidak menyediakan fitur bawaan untuk backup/restore, dan konfigurasi di `.env` hanya mengatur koneksi MySQL tanpa jadwal atau UI untuk operasi ini. Tanpa implementasi, risiko data loss tinggi, terutama dengan kompleksitas database (banyak trigger dan foreign key).

## Potensi Implementasi
Backup and Restore dapat diimplementasikan menggunakan package Laravel seperti `spatie/laravel-backup`, yang terintegrasi dengan scheduler dan storage. Berikut adalah langkah-langkah potensial:

### 1. **Backup Otomatis**
   - **Tujuan**: Membuat salinan data secara terjadwal untuk mencegah kehilangan.
   - **Langkah**:
     - Install package `spatie/laravel-backup`: `composer require spatie/laravel-backup`.
     - Publish konfigurasi: `php artisan vendor:publish --provider="Spatie\Backup\BackupServiceProvider"`.
     - Konfigurasi di `config/backup.php` untuk backup database MySQL, file, dan storage.
     - Jadwalkan backup harian/mingguan di `app/Console/Kernel.php` menggunakan Laravel scheduler: `php artisan backup:run`.
     - Simpan backup ke storage lokal atau cloud (AWS S3, dikonfigurasi di `.env`).

### 2. **Restore dari Backup**
   - **Tujuan**: Memulihkan data dari backup saat diperlukan.
   - **Langkah**:
     - Buat command Artisan khusus: `php artisan make:command RestoreDatabase`.
     - Implementasikan logika di command untuk restore database dari file backup, dengan validasi integritas (misalnya, cek checksum).
     - Tambahkan opsi untuk restore parsial (tabel tertentu) atau full restore.

### 3. **Integrasi dengan UI Admin/Superadmin**
   - **Tujuan**: Memungkinkan admin mengelola backup secara manual.
   - **Langkah**:
     - Tambahkan tombol di `resources/views/admin/dashboard.blade.php` dan `resources/views/superadmin/dashboard.blade.php` untuk:
       - Trigger backup manual.
       - Lihat status backup terakhir.
       - Download atau restore backup.
     - Gunakan AJAX atau form untuk interaksi tanpa reload halaman.

### 4. **Keamanan Backup**
   - **Tujuan**: Melindungi file backup dari akses tidak sah.
   - **Langkah**:
     - Enkripsi file backup menggunakan Laravel's encryption (dikonfigurasi di `.env`).
     - Simpan di storage aman dengan akses terbatas (misalnya, hanya superadmin).
     - Implementasikan rotasi backup (hapus backup lama otomatis) untuk menghemat space.

### 5. **Testing dan Validasi**
   - **Tujuan**: Pastikan backup/restore berfungsi.
   - **Langkah**:
     - Lakukan backup manual dan uji restore di environment staging.
     - Simulasi skenario failure (misalnya, drop tabel) dan pulihkan data.
     - Monitor ukuran backup dan performa sistem selama proses.

## Rekomendasi
- **Prioritas Tinggi**: Implementasikan backup otomatis segera, karena data transaksi sensitif dan kompleks.
- **Risiko Tanpa Backup**: Kehilangan data permanen dapat menghentikan operasi bisnis.
- **Integrasi dengan IRP**: Backup adalah bagian penting dari Incident Response Plan (lihat penjelasan terpisah).
- Jika diperlukan, gunakan tool eksternal seperti mysqldump untuk backup tambahan.

Implementasi ini akan memastikan ketersediaan data QParkIn, mendukung compliance, dan mengurangi downtime.
