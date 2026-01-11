# Parking Floors API - HTTP 500 Fix

## Issue Summary
**Endpoint:** `GET /api/parking/floors/{mall_id}`  
**Error:** HTTP 500 - "Undefined variable $mallId"  
**Date Fixed:** 2026-01-11

## Root Cause
The `getFloors()` method in `ParkingSlotController` used `$mallId` inside a closure without passing it via `use ($mallId)`. This caused a PHP error when the closure tried to access the variable.

## Fix Applied
**File:** `qparkin_backend/app/Http/Controllers/Api/ParkingSlotController.php`  
**Line:** 42

### Before:
```php
->map(function ($floor) {
    return [
        'id_floor' => $floor->id_floor,
        'id_mall' => $mallId,  // ❌ Undefined variable
        // ...
    ];
})
```

### After:
```php
->map(function ($floor) use ($mallId) {  // ✅ Pass $mallId to closure
    return [
        'id_floor' => $floor->id_floor,
        'id_mall' => $mallId,  // ✅ Now accessible
        // ...
    ];
})
```

## Verification Results

### Test 1: Database Check
```
✅ Parkiran exists for mall_id=4 (ID: 1, Nama: Mawar)
✅ 3 floors found with 60 total slots (20 per floor)
✅ All floors have status 'active'
```

### Test 2: Direct Controller Test
```bash
php test_floors_api.php
```

**Result:**
```json
{
    "success": true,
    "data": [
        {
            "id_floor": 1,
            "id_mall": 4,
            "floor_number": 1,
            "floor_name": "Lantai 1",
            "total_slots": 20,
            "available_slots": 20,
            "occupied_slots": 0,
            "reserved_slots": 0,
            "last_updated": "2026-01-11T10:14:49+00:00"
        },
        // ... 2 more floors
    ]
}
```

**Status:** ✅ HTTP 200 OK

## Cache Clearing
After the fix, Laravel cache was cleared:
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## API Response Format
The endpoint now returns:
- `success`: boolean
- `data`: array of floor objects with:
  - `id_floor`: Floor ID
  - `id_mall`: Mall ID (now correctly populated)
  - `floor_number`: Floor number (1, 2, 3, etc.)
  - `floor_name`: Display name (e.g., "Lantai 1")
  - `total_slots`: Total parking slots on this floor
  - `available_slots`: Currently available slots
  - `occupied_slots`: Currently occupied slots
  - `reserved_slots`: Currently reserved slots
  - `last_updated`: ISO 8601 timestamp

## Flutter Integration
The Flutter app (`BookingProvider`) expects this exact format and will now receive:
1. Valid floor data with correct `id_mall`
2. Real-time slot availability counts
3. Proper error handling for empty results

## Testing Commands

### Test the endpoint directly:
```bash
cd qparkin_backend
php test_floors_api.php
```

### Test with Flutter app:
1. Ensure backend is running: `php artisan serve --host=192.168.0.101`
2. Run Flutter app: `flutter run --dart-define=API_URL=http://192.168.0.101:8000`
3. Navigate: Map Page → Select Mall → Booking Page
4. Verify: Floor selector shows "Lantai 1", "Lantai 2", "Lantai 3"

## Related Files
- Controller: `app/Http/Controllers/Api/ParkingSlotController.php`
- Model: `app/Models/ParkingFloor.php`
- Migration: `database/migrations/2025_12_05_100000_create_parking_floors_table.php`
- Test Script: `test_floors_api.php`
- Debug Script: `test_floors_debug.php`

## Status
✅ **FIXED** - Endpoint returns HTTP 200 with correct floor data
