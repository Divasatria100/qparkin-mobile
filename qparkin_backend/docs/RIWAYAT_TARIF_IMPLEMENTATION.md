# Implementasi Fitur Riwayat Perubahan Tarif

## Overview
Fitur riwayat tarif mencatat setiap perubahan tarif parkir yang dilakukan oleh admin mall, termasuk tarif lama, tarif baru, waktu perubahan, dan siapa yang mengubah.

## Database Schema

### Tabel: `riwayat_tarif`
```sql
CREATE TABLE riwayat_tarif (
    id_riwayat BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_tarif BIGINT UNSIGNED NOT NULL,
    id_mall BIGINT UNSIGNED NOT NULL,
    id_user BIGINT UNSIGNED NULL,
    jenis_kendaraan VARCHAR(50) NOT NULL,
    tarif_lama_jam_pertama DECIMAL(10,2) NOT NULL,
    tarif_lama_per_jam DECIMAL(10,2) NOT NULL,
    tarif_baru_jam_pertama DECIMAL(10,2) NOT NULL,
    tarif_baru_per_jam DECIMAL(10,2) NOT NULL,
    keterangan TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (id_tarif) REFERENCES tarif_parkir(id_tarif) ON DELETE CASCADE,
    FOREIGN KEY (id_mall) REFERENCES mall(id_mall) ON DELETE CASCADE
);
```

## File yang Terlibat

### 1. Migration
**File**: `database/migrations/2025_12_07_124219_create_riwayat_tarif_table.php`
- Membuat tabel riwayat_tarif
- Foreign key ke tarif_parkir dan mall

### 2. Model
**File**: `app/Models/RiwayatTarif.php`
```php
class RiwayatTarif extends Model
{
    protected $table = 'riwayat_tarif';
    protected $primaryKey = 'id_riwayat';
    
    // Relationships
    public function tarif() // belongsTo TarifParkir
    public function mall()  // belongsTo Mall
    public function user()  // belongsTo User
}
```

### 3. Controller
**File**: `app/Http/Controllers/AdminController.php`

#### Method: `tarif()`
- Mengambil data tarif untuk mall admin yang login
- Mengambil 10 riwayat perubahan terakhir
- Menampilkan view dengan data tarif dan riwayat

#### Method: `updateTarif(Request $request, $id)`
- Validasi input tarif baru
- **Menyimpan riwayat sebelum update** (penting!)
- Update tarif ke database
- Redirect dengan success message

### 4. View
**File**: `resources/views/admin/tarif.blade.php`

Menampilkan tabel riwayat dengan kolom:
- Tanggal perubahan
- Jenis kendaraan
- Tarif lama (jam pertama + per jam)
- Tarif baru (jam pertama + per jam)
- Diubah oleh (nama user)

## Cara Kerja

### Flow Update Tarif dengan Riwayat:

1. **Admin klik Edit pada kartu tarif**
   - Route: `GET /admin/tarif/{id}/edit`
   - Controller: `AdminController@editTarif`
   - View: `edit-tarif.blade.php`

2. **Admin submit form perubahan**
   - Route: `POST /admin/tarif/{id}`
   - Controller: `AdminController@updateTarif`

3. **Controller menyimpan riwayat**
   ```php
   RiwayatTarif::create([
       'id_tarif' => $tarif->id_tarif,
       'id_mall' => $tarif->id_mall,
       'id_user' => Auth::user()->id_user,
       'jenis_kendaraan' => $tarif->jenis_kendaraan,
       'tarif_lama_jam_pertama' => $tarif->satu_jam_pertama,
       'tarif_lama_per_jam' => $tarif->tarif_parkir_per_jam,
       'tarif_baru_jam_pertama' => $request->satu_jam_pertama,
       'tarif_baru_per_jam' => $request->tarif_parkir_per_jam,
       'keterangan' => 'Perubahan tarif oleh admin',
   ]);
   ```

4. **Controller update tarif**
   ```php
   $tarif->update([
       'satu_jam_pertama' => $request->satu_jam_pertama,
       'tarif_parkir_per_jam' => $request->tarif_parkir_per_jam,
   ]);
   ```

5. **Redirect ke halaman tarif dengan success message**

6. **Halaman tarif menampilkan riwayat terbaru**

## Testing

### Manual Testing:
1. Login sebagai admin mall
2. Buka menu "Tarif"
3. Klik "Edit" pada salah satu kartu tarif
4. Ubah nilai tarif
5. Klik "Simpan Perubahan"
6. Scroll ke bawah untuk melihat "Riwayat Perubahan Tarif"
7. Verifikasi data riwayat muncul dengan benar

### Automated Testing:
```bash
# Run test script
.\test_riwayat_tarif.bat

# Or manual check
php artisan tinker
>>> App\Models\RiwayatTarif::count()
>>> App\Models\RiwayatTarif::latest()->first()
```

## Query untuk Analisis

### Melihat semua riwayat untuk mall tertentu:
```php
RiwayatTarif::where('id_mall', 1)
    ->orderBy('created_at', 'DESC')
    ->get();
```

### Melihat riwayat untuk jenis kendaraan tertentu:
```php
RiwayatTarif::where('jenis_kendaraan', 'Roda Empat')
    ->orderBy('created_at', 'DESC')
    ->get();
```

### Melihat perubahan yang dilakukan user tertentu:
```php
RiwayatTarif::where('id_user', 1)
    ->with('tarif', 'mall')
    ->get();
```

## Fitur Tambahan yang Bisa Dikembangkan

1. **Export Riwayat ke Excel**
   - Untuk audit dan reporting

2. **Filter Riwayat**
   - By date range
   - By jenis kendaraan
   - By user

3. **Rollback Tarif**
   - Kembalikan ke tarif sebelumnya dari riwayat

4. **Notifikasi Email**
   - Kirim email ke super admin saat tarif diubah

5. **Dashboard Analytics**
   - Grafik perubahan tarif over time
   - Statistik frekuensi perubahan

## Status: ✅ SELESAI

Fitur riwayat perubahan tarif sudah terimplementasi lengkap dan siap digunakan.
