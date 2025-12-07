# Fitur Tarif Parkir - QParkin Backend

## Overview
Fitur tarif parkir memungkinkan admin mall untuk mengelola tarif parkir berdasarkan jenis kendaraan.

## Struktur Database

### Tabel: `tarif_parkir`
- `id_tarif` (Primary Key)
- `id_mall` (Foreign Key ke tabel mall)
- `jenis_kendaraan` (ENUM: 'Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam')
- `satu_jam_pertama` (Decimal: Tarif untuk 1 jam pertama)
- `tarif_parkir_per_jam` (Decimal: Tarif per jam berikutnya)

## File yang Terlibat

### Model
- `app/Models/TarifParkir.php` - Model untuk tabel tarif_parkir

### Controller
- `app/Http/Controllers/AdminController.php`
  - `tarif()` - Menampilkan halaman tarif
  - `editTarif($id)` - Menampilkan form edit tarif
  - `updateTarif(Request $request, $id)` - Memproses update tarif

### Views
- `resources/views/admin/tarif.blade.php` - Halaman daftar tarif
- `resources/views/admin/edit-tarif.blade.php` - Form edit tarif

### Routes
```php
Route::get('/tarif', [AdminController::class, 'tarif'])->name('admin.tarif');
Route::get('/tarif/{id}/edit', [AdminController::class, 'editTarif'])->name('admin.tarif.edit');
Route::post('/tarif/{id}', [AdminController::class, 'updateTarif'])->name('admin.tarif.update');
```

### Seeder
- `database/seeders/TarifParkirSeeder.php` - Mengisi data tarif default untuk setiap mall

## Cara Menggunakan

### 1. Mengisi Data Tarif (Seeder)
```bash
php artisan db:seed --class=TarifParkirSeeder
```

### 2. Akses Halaman Tarif
- Login sebagai admin mall
- Klik menu "Tarif" di sidebar
- Akan muncul 4 kartu tarif untuk setiap jenis kendaraan

### 3. Edit Tarif
- Klik tombol "Edit" pada kartu tarif yang ingin diubah
- Masukkan tarif baru:
  - Tarif 1 Jam Pertama (Rp)
  - Tarif Per Jam Berikutnya (Rp)
- Klik "Simpan Perubahan"

## Validasi
- Tarif harus berupa angka
- Tarif tidak boleh negatif (min: 0)
- Tarif akan dibulatkan ke bilangan bulat

## Trigger Database
Sistem memiliki trigger otomatis:
- `trg_tarif_before_insert` - Validasi sebelum insert (mencegah duplikat, tarif negatif)
- `trg_tarif_after_update_notify` - Mengirim notifikasi ke admin mall saat tarif diubah

## Perhitungan Biaya Parkir
Rumus: 
- Jika durasi ≤ 1 jam: `biaya = satu_jam_pertama`
- Jika durasi > 1 jam: `biaya = satu_jam_pertama + (durasi - 1) * tarif_parkir_per_jam`

Contoh untuk Roda Empat (1 jam pertama: Rp 5.000, per jam: Rp 3.000):
- 1 jam = Rp 5.000
- 2 jam = Rp 5.000 + (1 × Rp 3.000) = Rp 8.000
- 3 jam = Rp 5.000 + (2 × Rp 3.000) = Rp 11.000

## Testing
Untuk memastikan fitur berjalan dengan baik:
1. Pastikan data mall sudah ada
2. Jalankan seeder tarif
3. Login sebagai admin mall
4. Akses halaman tarif dan pastikan data muncul
5. Coba edit tarif dan pastikan berhasil tersimpan
