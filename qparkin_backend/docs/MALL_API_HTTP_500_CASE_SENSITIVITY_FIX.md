# Mall API HTTP 500 Fix - Case Sensitivity Issue

## Problem Summary

HTTP 500 Internal Server Error terjadi pada endpoint `/api/mall` setelah auth flow diperbaiki.

## Root Cause Analysis

### Issue: Case-Sensitive Enum Mismatch

**Database Schema** (dari migration `2025_09_24_151634_parkiran.php`):
```php
enum('status', ['Tersedia', 'Ditutup'])  // Kapitalisasi
```

**Controller Query** (sebelum fix):
```php
->where('parkiran.status', 'tersedia')  // lowercase ❌
```

MySQL enum values are **case-sensitive**. Query dengan `'tersedia'` (lowercase) tidak match dengan enum value `'Tersedia'` (kapitalisasi), menyebabkan SQL error.

## Solution Applied

### File: `qparkin_backend/app/Http/Controllers/Api/MallController.php`

**Changed in `index()` method:**
```php
// BEFORE (WRONG)
->selectRaw('COUNT(CASE WHEN parkiran.status = "tersedia" THEN 1 END) as available_slots')

// AFTER (CORRECT)
->selectRaw('COUNT(CASE WHEN parkiran.status = "Tersedia" THEN 1 END) as available_slots')
```

**Changed in `show()` method:**
```php
// BEFORE (WRONG)
$availableSlots = $mall->parkiran()
    ->where('status', 'tersedia')
    ->count();

// AFTER (CORRECT)
$availableSlots = $mall->parkiran()
    ->where('status', 'Tersedia')
    ->count();
```

## Database Schema Reference

### Table: `mall`

**Kolom yang digunakan di API:**
- ✅ `id_mall` (primary key)
- ✅ `nama_mall` (string)
- ✅ `alamat_lengkap` (text) - dari migration `2025_12_21_180728`
- ✅ `latitude` (decimal) - dari migration `2026_01_08_164629`
- ✅ `longitude` (decimal) - dari migration `2026_01_08_164629`
- ✅ `google_maps_url` (string) - dari migration `2026_01_08_193321`
- ✅ `status` (enum: 'active', 'inactive', 'maintenance')
- ✅ `kapasitas` (integer)
- ✅ `has_slot_reservation_enabled` (boolean) - dari migration `2025_12_05_100005`

**Kolom yang TIDAK digunakan lagi:**
- ❌ `lokasi` - DIHAPUS oleh migration `2026_01_09_000001`

### Table: `parkiran`

**Status enum values (case-sensitive):**
- `'Tersedia'` (kapitalisasi)
- `'Ditutup'` (kapitalisasi)

## Testing

### Manual Test dengan curl:

```bash
# 1. Login untuk mendapatkan token
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# 2. Test endpoint /api/mall
curl -X GET http://localhost:8000/api/mall \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Expected Response (200 OK):

```json
{
  "success": true,
  "message": "Malls retrieved successfully",
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "BCS Mall",
      "alamat_lengkap": "Jl. Engku Putri no.1, Batam Centre",
      "latitude": 1.12345678,
      "longitude": 104.12345678,
      "google_maps_url": "https://www.google.com/maps/dir/?api=1&destination=1.12345678,104.12345678",
      "status": "active",
      "kapasitas": 100,
      "available_slots": 50,
      "has_slot_reservation_enabled": true
    }
  ]
}
```

## Lessons Learned

1. **Always check migration files** untuk memahami schema database yang sebenarnya
2. **MySQL enum values are case-sensitive** - harus match persis dengan definisi di migration
3. **Don't assume schema structure** - selalu verify dengan migration files, bukan asumsi
4. **Check error logs** di `storage/logs/laravel.log` untuk mendapatkan stack trace yang akurat

## Related Files

- `qparkin_backend/app/Http/Controllers/Api/MallController.php` (FIXED)
- `qparkin_backend/database/migrations/2025_09_24_151634_parkiran.php` (schema reference)
- `qparkin_backend/database/migrations/2025_09_24_151026_mall.php` (base schema)
- `qparkin_backend/database/migrations/2025_12_21_180728_add_extended_fields_to_mall_table.php` (extended fields)
- `qparkin_backend/database/migrations/2026_01_08_164629_add_location_coordinates_to_mall_table.php` (lat/lng)
- `qparkin_backend/database/migrations/2026_01_08_193321_add_google_maps_url_to_mall_table.php` (google maps)
- `qparkin_backend/database/migrations/2026_01_09_000001_remove_lokasi_from_mall_table.php` (removed lokasi)
- `qparkin_backend/database/migrations/2025_12_05_100005_add_slot_reservation_feature_flag_to_mall_table.php` (slot reservation flag)

## Status

✅ **FIXED** - Endpoint `/api/mall` sekarang menggunakan:
1. Kapitalisasi yang benar untuk enum status parkiran (`'Tersedia'`)
2. Qualified column name untuk menghindari ambiguity (`'mall.status'`)

## Additional Changes

✅ **MallSeeder DISABLED** - Mall data sekarang dibuat via Admin Mall Registration flow. Lihat `qparkin_backend/docs/MALL_SEEDER_DISABLED.md` untuk detail.

## Next Steps

1. Test endpoint dengan Flutter app
2. Verify bahwa daftar mall tampil dengan benar di MapPage
3. Verify bahwa `available_slots` count akurat
4. Create new malls via Admin Mall Registration flow (not seeder)
