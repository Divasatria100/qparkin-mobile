# Quick Fix Guide - Slot Reservation Card Hilang

## Masalah
Card pemilihan lantai parkir hilang di booking page setelah task `booking-page-slot-selection-enhancement` selesai.

## Penyebab
Data mall tidak memiliki field `has_slot_reservation_enabled`, sehingga feature flag check return `false` dan menyembunyikan UI slot reservation.

## Solusi Cepat

### Langkah 1: Setup Backend

```bash
cd qparkin_backend

# Jalankan setup script
run_slot_reservation_setup.bat
```

**ATAU manual:**

```bash
# 1. Jalankan migration (jika belum)
php artisan migrate --path=database/migrations/2025_12_05_100005_add_slot_reservation_feature_flag_to_mall_table.php

# 2. Seed mall data
php artisan db:seed --class=MallSeeder
```

### Langkah 2: Verifikasi Database

```sql
SELECT id_mall, nama_mall, has_slot_reservation_enabled FROM mall;
```

**Expected:**
```
+----------+---------------------------+-------------------------------+
| id_mall  | nama_mall                 | has_slot_reservation_enabled  |
+----------+---------------------------+-------------------------------+
| 1        | Mega Mall Batam Centre    | 1                             |
| 2        | One Batam Mall            | 1                             |
| 3        | SNL Food Bengkong         | 0                             |
+----------+---------------------------+-------------------------------+
```

### Langkah 3: Test Flutter App

```bash
cd qparkin_app
flutter clean
flutter pub get
flutter run
```

### Langkah 4: Verifikasi Fix

1. **Test Mall dengan Slot Reservation ENABLED:**
   - Pilih "Mega Mall Batam Centre" atau "One Batam Mall"
   - ✅ Card "Pilih Lokasi Parkir" harus muncul
   - ✅ Floor selector harus terlihat
   - ✅ Slot visualization harus terlihat
   - ✅ Tombol reservasi harus terlihat

2. **Test Mall dengan Slot Reservation DISABLED:**
   - Pilih "SNL Food Bengkong"
   - ✅ Card "Pilih Lokasi Parkir" harus tersembunyi
   - ✅ Booking tetap bisa dilakukan (auto-assignment)

## Jika Database Sudah Ada Mall Data

Jika database sudah memiliki data mall sebelumnya, jalankan SQL ini:

```sql
-- Tambah kolom jika belum ada
ALTER TABLE mall 
ADD COLUMN IF NOT EXISTS has_slot_reservation_enabled BOOLEAN DEFAULT FALSE;

-- Enable untuk mall tertentu
UPDATE mall 
SET has_slot_reservation_enabled = TRUE 
WHERE nama_mall IN ('Mega Mall Batam Centre', 'One Batam Mall');

-- Atau enable untuk semua mall
UPDATE mall 
SET has_slot_reservation_enabled = TRUE;
```

## Troubleshooting

### Card masih tidak muncul?

**Check 1: Database**
```sql
SELECT has_slot_reservation_enabled FROM mall WHERE id_mall = 1;
```
Harus return `1` atau `true`.

**Check 2: Mock Data**
Pastikan `home_page.dart` sudah include field:
```dart
{
  'name': 'Mega Mall Batam Centre',
  'has_slot_reservation_enabled': true,  // ← Harus ada
}
```

**Check 3: Clear Cache**
```bash
# Backend
php artisan config:clear
php artisan cache:clear

# Frontend
flutter clean
flutter pub get
```

## Files yang Dibuat/Diubah

### Backend (Created)
- ✅ `database/seeders/MallSeeder.php`
- ✅ `run_slot_reservation_setup.bat`
- ✅ `docs/SLOT_RESERVATION_FEATURE_FLAG_GUIDE.md`

### Backend (Updated)
- ✅ `database/seeders/DatabaseSeeder.php`

### Frontend (Updated)
- ✅ `lib/presentation/screens/home_page.dart`

### Documentation (Created)
- ✅ `SLOT_RESERVATION_FEATURE_FLAG_FIX_SUMMARY.md`
- ✅ `QUICK_FIX_GUIDE.md` (this file)

## Dokumentasi Lengkap

Untuk detail lengkap, lihat:
- [SLOT_RESERVATION_FEATURE_FLAG_FIX_SUMMARY.md](SLOT_RESERVATION_FEATURE_FLAG_FIX_SUMMARY.md)
- [qparkin_backend/docs/SLOT_RESERVATION_FEATURE_FLAG_GUIDE.md](qparkin_backend/docs/SLOT_RESERVATION_FEATURE_FLAG_GUIDE.md)

## Bantuan

Jika masih ada masalah, check:
1. Database connection aktif
2. Migration sudah dijalankan
3. Seeder sudah dijalankan
4. Mock data sudah diupdate
5. Flutter app sudah di-rebuild

---

**Status:** ✅ Fix Complete
**Tested:** ⏳ Pending (database not running)
**Ready for:** Production Testing
