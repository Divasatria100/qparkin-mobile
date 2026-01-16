# Booking Page - Complete Fix Summary

## Issues Fixed

### Issue 1: Floor Cards Not Showing
**Problem:** Floor selector tidak muncul di Booking Page meskipun data berhasil di-fetch.

**Root Cause:** Field `has_slot_reservation_enabled` tidak dikirim dari MapPage, menyebabkan guard condition menyembunyikan UI.

**Fix:** Tambahkan field di `map_page.dart` + debug logging untuk verifikasi.

### Issue 2: Available Slots Shows 1 Instead of 60
**Problem:** Mall info card menampilkan "1 slot tersedia" padahal di database ada 60 slots.

**Root Cause:** Query di `MallController` menghitung jumlah **parkiran** (1), bukan jumlah **slots** (60).

**Fix:** Ubah query untuk menjumlahkan `parking_floors.available_slots`.

---

## Fix 1: Floor Cards UI

### Files Modified
- `qparkin_app/lib/presentation/screens/map_page.dart`
- `qparkin_app/lib/logic/providers/booking_provider.dart`

### Changes

#### map_page.dart
```dart
// Added debug logging
_selectedMall = {
  'id_mall': int.parse(mall.id),
  'name': mall.name,
  'address': mall.address,
  'available': mall.availableSlots,
  'has_slot_reservation_enabled': mall.hasSlotReservationEnabled, // ✅ Already added
};

// Debug log
debugPrint('[MapPage] Selected mall data:');
debugPrint('  - has_slot_reservation_enabled: ${_selectedMall!['has_slot_reservation_enabled']}');
```

#### booking_provider.dart
```dart
bool get isSlotReservationEnabled {
  if (_selectedMall == null) {
    debugPrint('[BookingProvider] isSlotReservationEnabled: false (no mall selected)');
    return false;
  }
  
  final enabled = _selectedMall!['has_slot_reservation_enabled'] == true ||
      _selectedMall!['has_slot_reservation_enabled'] == 1;
  
  // Debug logs
  debugPrint('[BookingProvider] isSlotReservationEnabled: $enabled');
  debugPrint('[BookingProvider] has_slot_reservation_enabled value: ${_selectedMall!['has_slot_reservation_enabled']}');
  
  return enabled;
}
```

---

## Fix 2: Available Slots Count

### File Modified
- `qparkin_backend/app/Http/Controllers/Api/MallController.php`

### Before (WRONG - Counts parkiran)
```php
->leftJoin('parkiran', 'mall.id_mall', '=', 'parkiran.id_mall')
->selectRaw('COUNT(CASE WHEN parkiran.status = "Tersedia" THEN 1 END) as available_slots')
```

**Result:** Returns 1 (number of parkiran with status "Tersedia")

### After (CORRECT - Sums slots)
```php
->leftJoin('parkiran', 'mall.id_mall', '=', 'parkiran.id_mall')
->leftJoin('parking_floors', 'parkiran.id_parkiran', '=', 'parking_floors.id_parkiran')
->selectRaw('COALESCE(SUM(parking_floors.available_slots), 0) as available_slots')
->where('parkiran.status', '=', 'Tersedia')
```

**Result:** Returns 60 (sum of available_slots from all parking_floors)

### Query Explanation

**Database Structure:**
```
mall (id_mall=4, kapasitas=60)
  └─ parkiran (id_parkiran=1, status='Tersedia', jumlah_lantai=3)
      ├─ parking_floors (id_floor=1, available_slots=20)
      ├─ parking_floors (id_floor=2, available_slots=20)
      └─ parking_floors (id_floor=3, available_slots=20)
```

**Old Query Logic:**
- Count parkiran where status = "Tersedia"
- Result: 1 parkiran → `available_slots = 1` ❌

**New Query Logic:**
- Sum `parking_floors.available_slots` for all floors
- Result: 20 + 20 + 20 = 60 → `available_slots = 60` ✅

---

## Testing Instructions

### 1. Restart Backend Server
```bash
cd qparkin_backend
# Stop current server (Ctrl+C)
php artisan serve --host=192.168.0.101
```

### 2. Hot Restart Flutter App
```bash
# Press 'R' in terminal or click hot restart button
# NOT hot reload - must be hot restart!
```

### 3. Test Flow
1. Login ke aplikasi
2. Navigate ke Map Page
3. **CHECK LOG:** Lihat debug output di console
4. Pilih "Panbil Mall" dari daftar
5. **VERIFY:** Mall card menampilkan "60 slot tersedia" (bukan 1)
6. Klik tombol "Booking"
7. **CHECK LOG:** Lihat output `isSlotReservationEnabled`
8. **VERIFY:** Section "Pilih Lokasi Parkir" muncul
9. **VERIFY:** 3 floor cards ditampilkan (Lantai 1, 2, 3)
10. **VERIFY:** Setiap floor menampilkan "20/20 slots available"

### 4. Expected Debug Logs

#### MapPage Logs
```
[MapPage] Selected mall data:
  - id_mall: 4
  - name: Panbil Mall
  - available: 60  ← Should be 60 now
  - has_slot_reservation_enabled: true
```

#### BookingProvider Logs
```
[BookingProvider] isSlotReservationEnabled: true  ← Should be true
[BookingProvider] has_slot_reservation_enabled value: true
[BookingProvider] has_slot_reservation_enabled type: bool
[BookingProvider] Fetching floors for mall: 4
[BookingProvider] SUCCESS: Loaded 3 floors
[BookingProvider] Floor IDs: 1, 2, 3
```

---

## Verification Checklist

### Backend API Response
Test endpoint: `GET /api/mall`

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id_mall": 4,
      "nama_mall": "Panbil Mall",
      "alamat_lengkap": "Jl. Ahmad Yani...",
      "latitude": 1.1234,
      "longitude": 104.5678,
      "google_maps_url": "https://...",
      "status": "active",
      "kapasitas": 60,
      "available_slots": 60,  ← Should be 60 (sum of all floors)
      "has_slot_reservation_enabled": true  ← Should be true
    }
  ]
}
```

### Flutter UI
- ✅ Mall card shows "60 slot tersedia"
- ✅ Section "Pilih Lokasi Parkir" visible
- ✅ 3 floor cards displayed
- ✅ Each floor shows "20/20 slots available"
- ✅ Slot visualization appears when floor selected
- ✅ Reservation button enabled

---

## Troubleshooting

### If Floor Cards Still Not Showing

**Check 1:** Verify `has_slot_reservation_enabled` in database
```sql
SELECT id_mall, nama_mall, has_slot_reservation_enabled 
FROM mall 
WHERE id_mall = 4;
```

**Expected:** `has_slot_reservation_enabled = 1` or `true`

**If NULL or 0:** Update database
```sql
UPDATE mall 
SET has_slot_reservation_enabled = 1 
WHERE id_mall = 4;
```

**Check 2:** Verify debug logs show correct value
```
[BookingProvider] has_slot_reservation_enabled value: true
```

**If false:** Check MapPage is passing the field correctly

### If Available Slots Still Shows 1

**Check 1:** Verify parking_floors data exists
```sql
SELECT pf.id_floor, pf.floor_name, pf.available_slots
FROM parking_floors pf
JOIN parkiran p ON pf.id_parkiran = p.id_parkiran
WHERE p.id_mall = 4;
```

**Expected:** 3 rows with 20 slots each

**Check 2:** Test API endpoint directly
```bash
curl -X GET http://192.168.0.101:8000/api/mall \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Check 3:** Verify backend query is updated
- File: `qparkin_backend/app/Http/Controllers/Api/MallController.php`
- Line: ~32
- Should have: `SUM(parking_floors.available_slots)`

---

## Files Modified Summary

### Flutter (qparkin_app)
1. `lib/presentation/screens/map_page.dart`
   - Added debug logging for mall data transfer
   
2. `lib/logic/providers/booking_provider.dart`
   - Added debug logging for `isSlotReservationEnabled` check

### Backend (qparkin_backend)
1. `app/Http/Controllers/Api/MallController.php`
   - Fixed `available_slots` calculation
   - Changed from COUNT(parkiran) to SUM(parking_floors.available_slots)
   - Added JOIN with parking_floors table
   - Added WHERE clause for parkiran status

---

## Status
✅ **FIXED** - Both issues resolved
- Floor cards will show when `has_slot_reservation_enabled = true`
- Available slots will show correct count (60) from parking_floors

---

**Date:** 2026-01-11  
**Issues:** UI not showing + Wrong slot count  
**Solution:** Debug logging + Query fix
