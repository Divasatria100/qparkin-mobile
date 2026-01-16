# Mall API - Quick Test Guide

## Problem Fixed

✅ HTTP 500 Internal Server Error pada endpoint `/api/mall`  
✅ Root cause: Case-sensitive enum mismatch (`'tersedia'` vs `'Tersedia'`)  
✅ Solution: Update query untuk gunakan kapitalisasi yang benar  

## Quick Test

### Option 1: Using test-mall-api.bat

```bash
# Run the test script
test-mall-api.bat

# Script akan meminta token, dapatkan dari:
# 1. Login via Flutter app
# 2. Atau login via curl (lihat Option 2)
```

### Option 2: Manual curl test

```bash
# Step 1: Login untuk mendapatkan token
curl -X POST http://localhost:8000/api/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"user@example.com\",\"password\":\"password123\"}"

# Response akan berisi token:
# {
#   "success": true,
#   "token": "1|abcdef123456...",
#   "user": {...}
# }

# Step 2: Test endpoint /api/mall
curl -X GET http://localhost:8000/api/mall ^
  -H "Accept: application/json" ^
  -H "Authorization: Bearer 1|abcdef123456..."

# Expected: 200 OK dengan data mall
```

### Option 3: Test via Flutter App

```bash
# 1. Start Laravel server
cd qparkin_backend
php artisan serve

# 2. Run Flutter app (di terminal lain)
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# 3. Test flow:
#    - Login dengan user credentials
#    - Navigate ke MapPage
#    - Tap tab "Daftar Mall"
#    - Verify: Daftar mall tampil dengan data dari database
```

## Expected Response

### Success (200 OK):

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

### Error Scenarios:

**401 Unauthorized:**
```json
{
  "message": "Unauthenticated."
}
```
→ Solution: Pastikan token dikirim di header `Authorization: Bearer {token}`

**500 Internal Server Error (FIXED):**
```json
{
  "success": false,
  "message": "Failed to fetch malls",
  "error": "..."
}
```
→ Solution: Sudah diperbaiki dengan fix case-sensitive enum

## What Was Fixed

### File: `MallController.php`

**Method `index()` - Line 33:**
```php
// BEFORE (WRONG)
->selectRaw('COUNT(CASE WHEN parkiran.status = "tersedia" THEN 1 END) as available_slots')

// AFTER (CORRECT)
->selectRaw('COUNT(CASE WHEN parkiran.status = "Tersedia" THEN 1 END) as available_slots')
```

**Method `show()` - Line 77:**
```php
// BEFORE (WRONG)
$availableSlots = $mall->parkiran()->where('status', 'tersedia')->count();

// AFTER (CORRECT)
$availableSlots = $mall->parkiran()->where('status', 'Tersedia')->count();
```

## Database Schema Reference

### Table: `parkiran`

```sql
CREATE TABLE parkiran (
  id_parkiran BIGINT PRIMARY KEY,
  id_mall BIGINT,
  jenis_kendaraan ENUM('Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'),
  kapasitas INT,
  status ENUM('Tersedia', 'Ditutup') DEFAULT 'Tersedia',  -- ⚠️ Case-sensitive!
  ...
);
```

**Important:** MySQL enum values are **case-sensitive**. Query harus match persis:
- ✅ `'Tersedia'` (correct)
- ❌ `'tersedia'` (wrong - causes SQL error)

## Troubleshooting

### Issue: Still getting 500 error

**Check:**
1. Apakah Laravel server running? (`php artisan serve`)
2. Apakah database connection OK? (check `.env`)
3. Apakah ada data di tabel `mall`? (run seeder jika perlu)
4. Check error log: `qparkin_backend/storage/logs/laravel.log`

**Run seeder jika database kosong:**
```bash
cd qparkin_backend
php artisan db:seed --class=MallSeeder
php artisan db:seed --class=ParkiranSeeder
```

### Issue: Getting 401 Unauthorized

**Check:**
1. Apakah user sudah login?
2. Apakah token valid dan tidak expired?
3. Apakah header `Authorization: Bearer {token}` dikirim?

**Get new token:**
```bash
curl -X POST http://localhost:8000/api/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"user@example.com\",\"password\":\"password123\"}"
```

### Issue: Empty data array

**Check:**
1. Apakah ada mall dengan `status = 'active'` di database?
2. Run query manual:
   ```sql
   SELECT * FROM mall WHERE status = 'active';
   ```
3. Jika kosong, run seeder atau tambah data manual

## Related Documentation

- `qparkin_backend/docs/MALL_API_HTTP_500_CASE_SENSITIVITY_FIX.md` - Detailed fix explanation
- `qparkin_app/docs/MAP_PAGE_MALL_LIST_COMPLETE_FIX.md` - Complete fix timeline
- `qparkin_app/docs/MAP_PAGE_AUTH_FLOW_FIX.md` - Auth flow fix
- `qparkin_app/docs/MAP_PAGE_MALL_LIST_NO_DUMMY_FIX.md` - Dummy data removal

## Status

✅ **FIXED AND TESTED**

Endpoint `/api/mall` sekarang:
- Return 200 OK dengan data yang benar
- Query enum status dengan kapitalisasi yang benar
- Protected dengan auth:sanctum
- Available slots count akurat
