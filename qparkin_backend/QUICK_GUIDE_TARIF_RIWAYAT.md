# Quick Guide: Fitur Tarif & Riwayat Perubahan

## 🎯 Fitur yang Sudah Diimplementasi

### 1. Manajemen Tarif Parkir
- ✅ Tampilan kartu tarif untuk 4 jenis kendaraan
- ✅ Edit tarif dengan form yang user-friendly
- ✅ Validasi input (tidak boleh negatif)
- ✅ Update ke database
- ✅ Success notification

### 2. Riwayat Perubahan Tarif
- ✅ Otomatis mencatat setiap perubahan
- ✅ Menyimpan tarif lama dan baru
- ✅ Mencatat siapa yang mengubah
- ✅ Menampilkan 10 riwayat terakhir
- ✅ Format tampilan yang informatif

## 📁 File Penting

```
qparkin_backend/
├── app/
│   ├── Http/Controllers/
│   │   └── AdminController.php          # Method: tarif(), editTarif(), updateTarif()
│   └── Models/
│       ├── TarifParkir.php              # Model tarif
│       └── RiwayatTarif.php             # Model riwayat (NEW)
├── database/
│   ├── migrations/
│   │   └── 2025_12_07_124219_create_riwayat_tarif_table.php  # Migration riwayat (NEW)
│   └── seeders/
│       └── TarifParkirSeeder.php        # Seeder data tarif (NEW)
├── resources/views/admin/
│   ├── tarif.blade.php                  # Halaman daftar tarif
│   └── edit-tarif.blade.php             # Form edit tarif (NEW)
└── routes/
    └── web.php                          # Routes: /tarif, /tarif/{id}/edit, /tarif/{id}
```

## 🚀 Cara Menggunakan

### Untuk Admin Mall:
1. Login ke admin panel
2. Klik menu **"Tarif"** di sidebar
3. Lihat kartu tarif untuk setiap jenis kendaraan
4. Klik tombol **"Edit"** pada tarif yang ingin diubah
5. Masukkan tarif baru:
   - Tarif 1 Jam Pertama
   - Tarif Per Jam Berikutnya
6. Klik **"Simpan Perubahan"**
7. Scroll ke bawah untuk melihat **"Riwayat Perubahan Tarif"**

### Untuk Developer:

#### Check Data Tarif:
```bash
php artisan tinker
>>> App\Models\TarifParkir::count()
>>> App\Models\TarifParkir::all()
```

#### Check Riwayat:
```bash
php artisan tinker
>>> App\Models\RiwayatTarif::count()
>>> App\Models\RiwayatTarif::with('user')->latest()->get()
```

#### Run Test Scripts:
```bash
# Test tarif
.\test_tarif.bat

# Test riwayat
.\test_riwayat_tarif.bat
```

## 🔧 Troubleshooting

### Riwayat tidak muncul?
1. Pastikan tabel riwayat_tarif sudah ada:
   ```bash
   php artisan tinker --execute="echo Schema::hasTable('riwayat_tarif') ? 'OK' : 'NOT FOUND';"
   ```

2. Jika belum ada, jalankan migrasi:
   ```bash
   php artisan migrate --path=database/migrations/2025_12_07_124219_create_riwayat_tarif_table.php
   ```

### Data tarif kosong?
Jalankan seeder:
```bash
php artisan db:seed --class=TarifParkirSeeder
```

### Error saat update tarif?
1. Check validasi input (harus angka, tidak boleh negatif)
2. Check koneksi database
3. Check log: `storage/logs/laravel.log`

## 📊 Database Schema

### Tabel: tarif_parkir
- id_tarif (PK)
- id_mall (FK)
- jenis_kendaraan (ENUM)
- satu_jam_pertama (DECIMAL)
- tarif_parkir_per_jam (DECIMAL)

### Tabel: riwayat_tarif (NEW)
- id_riwayat (PK)
- id_tarif (FK)
- id_mall (FK)
- id_user
- jenis_kendaraan
- tarif_lama_jam_pertama
- tarif_lama_per_jam
- tarif_baru_jam_pertama
- tarif_baru_per_jam
- keterangan
- created_at
- updated_at

## 🎨 UI Components

### Halaman Tarif (`/admin/tarif`)
- Breadcrumb
- Success alert (jika ada)
- 4 kartu tarif (horizontal scroll)
- Tabel riwayat perubahan

### Halaman Edit (`/admin/tarif/{id}/edit`)
- Breadcrumb
- Badge jenis kendaraan
- Form input tarif
- Tombol Batal & Simpan

## ✅ Status: PRODUCTION READY

Semua fitur sudah ditest dan siap digunakan di production.
