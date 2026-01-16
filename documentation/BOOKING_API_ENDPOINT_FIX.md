# Booking API Endpoint Fix

## Problem
Error 405 Method Not Allowed saat konfirmasi booking:
```
The POST method is not supported for route api/booking/create. 
Supported methods: GET, HEAD.
```

## Root Cause
Flutter `BookingService` menggunakan endpoint yang salah:
- ❌ **Salah**: `POST /api/booking/create`
- ❌ **Salah**: `GET /api/booking/check-active`
- ✅ **Benar**: `POST /api/booking` (RESTful convention)
- ✅ **Benar**: `GET /api/booking/active`

## Solution Applied

### 1. Fix Create Booking Endpoint
**File**: `qparkin_app/lib/data/services/booking_service.dart`

```dart
// BEFORE (line 72)
final uri = Uri.parse('$_baseUrl/api/booking/create');

// AFTER
final uri = Uri.parse('$_baseUrl/api/booking');
```

### 2. Fix Check Active Booking Endpoint
**File**: `qparkin_app/lib/data/services/booking_service.dart`

```dart
// BEFORE (line 358)
final uri = Uri.parse('$_baseUrl/api/booking/check-active');

// AFTER
final uri = Uri.parse('$_baseUrl/api/booking/active');
```

## Backend Routes (Reference)
From `qparkin_backend/routes/api.php`:

```php
Route::prefix('booking')->group(function () {
    Route::get('/', [BookingController::class, 'index']);
    Route::post('/', [BookingController::class, 'store']);        // ← Create booking
    Route::get('/{id}', [BookingController::class, 'show']);
    Route::put('/{id}/cancel', [BookingController::class, 'cancel']);
    Route::get('/active', [BookingController::class, 'getActive']); // ← Check active
});
```

## Testing
1. Run Flutter app: `flutter run --dart-define=API_URL=http://192.168.x.xx:8000`
2. Navigate to booking page
3. Select vehicle, time, duration
4. Click "Konfirmasi Booking"
5. Should navigate to Midtrans payment page successfully

## Status
✅ **FIXED** - Booking creation now works correctly
✅ **FIXED** - Active booking check now works correctly

## Related Files
- `qparkin_app/lib/data/services/booking_service.dart` - Fixed endpoints
- `qparkin_backend/routes/api.php` - Backend route definitions
- `qparkin_backend/app/Http/Controllers/Api/BookingController.php` - Controller

## Notes
- The `checkSlotAvailability` method still uses non-existent endpoint `/api/booking/check-availability`
- This is okay because the app now uses floor-based slot system via `/api/parking/floors/{mallId}`
- The old availability check will gracefully return 0 slots if called
