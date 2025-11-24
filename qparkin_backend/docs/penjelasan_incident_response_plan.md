# Penjelasan Incident Response Plan (IRP) untuk QParkIn Backend

## Pendahuluan
Incident Response Plan (IRP) adalah rencana terstruktur untuk mendeteksi, merespons, dan memulihkan dari insiden keamanan yang terjadi pada sistem, termasuk basis data. Dalam konteks QParkIn (sistem parkir berbasis Laravel), IRP penting untuk melindungi data sensitif seperti transaksi parkir, informasi pengguna, dan riwayat pembayaran dari ancaman seperti breach data, serangan SQL injection, atau downtime sistem.

## Status Implementasi Saat Ini
**Belum ada fitur keamanan basis data yang diterapkan untuk Incident Response Plan pada website admin mall dan superadmin.** Sistem saat ini hanya mengandalkan logging dasar Laravel (seperti di `config/logging.php` dan `.env` dengan `LOG_CHANNEL=stack`), yang mencatat error umum dan query database. Namun, tidak ada mekanisme otomatis untuk:
- Deteksi insiden real-time (misalnya, aktivitas mencurigakan atau anomali data).
- Alerting otomatis (notifikasi ke admin saat insiden terjadi).
- Audit trail lengkap untuk perubahan data sensitif.
- Prosedur respons terstruktur (isolasi, investigasi, pemulihan).

Tanpa IRP, risiko seperti data breach atau downtime tidak dapat ditangani secara efektif, yang dapat mengakibatkan kerugian finansial dan reputasi.

## Potensi Implementasi
IRP dapat diimplementasikan menggunakan ekosistem Laravel, yang mendukung integrasi dengan package pihak ketiga dan fitur bawaan seperti event system. Berikut adalah langkah-langkah potensial untuk mengimplementasikan IRP:

### 1. **Audit Logging dan Monitoring**
   - **Tujuan**: Mencatat semua aktivitas kritis pada basis data untuk deteksi insiden.
   - **Langkah**:
     - Install package `spatie/laravel-activitylog` via Composer: `composer require spatie/laravel-activitylog`.
     - Buat model audit untuk tabel utama seperti `user`, `transaksi_parkir`, `pembayaran`, dan `booking`.
     - Integrasikan dengan trigger di `qparkin.sql` untuk log perubahan (insert/update/delete) secara otomatis.
     - Tambahkan middleware di `routes/web.php` untuk log semua request ke database.

### 2. **Deteksi Insiden**
   - **Tujuan**: Identifikasi aktivitas mencurigakan secara real-time.
   - **Langkah**:
     - Gunakan Laravel Telescope (`laravel/telescope`) untuk monitoring query database dan error.
     - Tambahkan rate limiting di middleware untuk mencegah brute-force atau serangan DDoS.
     - Buat event listener untuk mendeteksi anomali, seperti query gagal berulang atau akses tidak sah ke data sensitif.

### 3. **Alerting dan Notifikasi**
   - **Tujuan**: Memberitahu admin/superadmin saat insiden terjadi.
   - **Langkah**:
     - Integrasikan dengan sistem notifikasi Laravel (misalnya, email atau Slack) di controller seperti `AdminController.php` dan `SuperAdminController.php`.
     - Tambahkan view di `resources/views/superadmin/dashboard.blade.php` untuk dashboard monitoring insiden, menampilkan log aktivitas dan alert.

### 4. **Prosedur Respons dan Pemulihan**
   - **Tujuan**: Panduan untuk menangani insiden.
   - **Langkah**:
     - Buat dokumentasi manual IRP sebagai bagian dari file ini, dengan langkah-langkah seperti:
       - **Deteksi**: Monitor log dan alert.
       - **Respons**: Isolasi sistem (misalnya, blokir IP mencurigakan).
       - **Investigasi**: Analisis log audit.
       - **Pemulihan**: Restore dari backup (lihat penjelasan Backup and Restore).
       - **Pelaporan**: Laporkan ke pihak berwenang jika diperlukan.
     - Integrasikan dengan backup otomatis untuk pemulihan cepat.

### 5. **Testing dan Validasi**
   - **Tujuan**: Pastikan IRP berfungsi.
   - **Langkah**:
     - Simulasi insiden (misalnya, inject query berbahaya) dan uji respons sistem.
     - Lakukan audit berkala pada log untuk memastikan integritas.

## Rekomendasi
- **Prioritas Tinggi**: Implementasikan audit logging dan alerting terlebih dahulu, karena ini dasar untuk IRP.
- **Risiko Tanpa IRP**: Sistem rentan terhadap insiden tanpa deteksi atau respons cepat.
- **Integrasi dengan UI**: Tambahkan fitur di dashboard admin/superadmin untuk memantau status IRP.
- Jika diperlukan, konsultasikan dengan spesialis keamanan untuk IRP yang lebih komprehensif.

IRP ini akan meningkatkan keamanan basis data QParkIn secara signifikan, memastikan kepatuhan terhadap standar seperti GDPR atau regulasi lokal.
