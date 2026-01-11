# Booking HTTP 422 Error - Complete Fix Summary

## Error Timeline

### Task 1: Flutter Compilation Errors ✅
**Status**: Fixed
- Removed orphaned code in booking_page.dart
- Fixed `fetchActiveParking` method calls (positional → named parameter)
- Fixed undefined color constants
- Deleted obsolete payment_page.dart

### Task 2: HTTP 405 Method Not Allowed ✅
**Status**: Fixed
- Changed `POST /api/booking/create` → `POST /api/booking`
- Changed `GET /api/booking/check-active` → `GET /api/booking/active`
- Backend uses RESTful routes

### Task 3: HTTP 422 Validation Error ✅
**Status**: Fixed (THIS TASK)

## Current Fix: Parkiran ID Missing

### Problem
```json
{
  "message": "The id parkiran field is required. (and 1 more error)",
  "errors": {
    "id_parkiran": ["The id parkiran field is required."],
    "durasi_booking": ["The durasi booking field is required."]
  }
}
```

### Root Cause
**Database Structure**:
```
mall (id_mall: 4)
  └── parkiran (id_parkiran: 1, id_mall: 4)  ← One-to-many relationship
```

**The Issue**:
- Flutter was sending `id_mall: 4` (mall ID)
- Backend expects `id_parkiran: 1` (parking area ID)
- These are **different entities** - a mall can have multiple parkiran

### Solution Implemented

#### 1. Fetch Parkiran ID on Initialization

**File**: `qparkin_app/lib/logic/providers/booking_provider.dart`

```dart
// Changed from sync to async
Future<void> initialize(Map<String, dynamic> mallData, {String? token}) async {
  // ... existing initialization ...
  
  // NEW: Fetch parkiran ID for this mall
  if (token != null && mallId.isNotEmpty) {
    await _fetchParkiranForMall(mallId, token);
  }
}

// NEW: Fetch parkiran from API
Future<void> _fetchParkiranForMall(String mallId, String token) async {
  final parkiran = await _bookingService.getParkiranForMall(
    mallId: mallId,
    token: token,
  );
  
  if (parkiran != null && parkiran.isNotEmpty) {
    // Store parkiran ID in mall data
    _selectedMall!['id_parkiran'] = parkiran[0]['id_parkiran']?.toString();
  }
}
```

#### 2. Use Parkiran ID in Booking Request

**File**: `qparkin_app/lib/logic/providers/booking_provider.dart`

```dart
// Get parkiran ID (not mall ID!)
final idParkiran = _selectedMall!['id_parkiran']?.toString();

if (idParkiran == null || idParkiran.isEmpty) {
  _errorMessage = 'Data parkiran tidak tersedia. Silakan pilih mall lagi.';
  return false;
}

final request = BookingRequest(
  idMall: idParkiran,  // ← Uses parkiran ID (field name kept for compatibility)
  idKendaraan: _selectedVehicle!['id_kendaraan']?.toString() ?? '',
  waktuMulai: _startTime!,
  durasiJam: durationHours,
  // ...
);
```

#### 3. Added API Method to BookingService

**File**: `qparkin_app/lib/data/services/booking_service.dart`

```dart
Future<List<Map<String, dynamic>>?> getParkiranForMall({
  required String mallId,
  required String token,
}) async {
  final uri = Uri.parse('$_baseUrl/api/mall/$mallId/parkiran');
  
  final response = await _client.get(uri, headers: {
    'Authorization': 'Bearer $token',
  }).timeout(_timeout);
  
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }
  return null;
}
```

#### 4. Updated Booking Page

**File**: `qparkin_app/lib/presentation/screens/booking_page.dart`

```dart
// Changed to await async initialize
await _bookingProvider!.initialize(widget.mall, token: _authToken);
```

## Complete Field Mapping

| Flutter Field | JSON Key | Backend Field | Type | Notes |
|--------------|----------|---------------|------|-------|
| `idMall` | `id_parkiran` | `id_parkiran` | int | **Parkiran ID, not mall ID!** |
| `idKendaraan` | `id_kendaraan` | `id_kendaraan` | int | Vehicle ID |
| `waktuMulai` | `waktu_mulai` | `waktu_mulai` | datetime | ISO 8601 format |
| `durasiJam` | `durasi_booking` | `durasi_booking` | int | Duration in hours |
| `idSlot` | `id_slot` | `id_slot` | int? | Optional: reserved slot |
| `reservationId` | `reservation_id` | `reservation_id` | string? | Optional: reservation ID |

## Testing the Fix

### 1. Check Parkiran Endpoint
```bash
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": [
    {
      "id_parkiran": 1,
      "nama_parkiran": "Parkiran Utama",
      "kapasitas": 200,
      "status": "Tersedia"
    }
  ]
}
```

### 2. Run Flutter App
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

### 3. Test Booking Flow
1. Select mall from map
2. Navigate to booking page
3. **Check logs**:
   ```
   [BookingProvider] Initializing with mall: Mall Name
   [BookingService] Fetching parkiran for mall: 4
   [BookingService] Found 1 parkiran
   [BookingProvider] Parkiran ID set: 1
   ```
4. Select vehicle, time, duration
5. Confirm booking
6. **Expected**: HTTP 201 Created

### 4. Verify Booking Request
**Check logs for**:
```
[BookingProvider] Sending booking request: {
  id_parkiran: 1,
  id_kendaraan: 2,
  waktu_mulai: 2026-01-12T10:00:00.000,
  durasi_booking: 2
}
```

## Files Modified

1. ✅ `qparkin_app/lib/data/models/booking_request.dart` (Task 2)
2. ✅ `qparkin_app/lib/logic/providers/booking_provider.dart` (Task 3)
3. ✅ `qparkin_app/lib/data/services/booking_service.dart` (Task 2 & 3)
4. ✅ `qparkin_app/lib/presentation/screens/booking_page.dart` (Task 1 & 3)

## Known Issues & Future Work

### Test Files Need Updating
Test files call `initialize()` synchronously - need to add `await`:
- `qparkin_app/test/integration/booking_e2e_test.dart`
- `qparkin_app/test/integration/complete_booking_flow_test.dart`
- `qparkin_app/test/integration/booking_slot_reservation_integration_test.dart`
- `qparkin_app/test/booking_page_responsive_test.dart`

**Fix**: Add `await` before `bookingProvider.initialize()`

### Multiple Parkiran Support
Current implementation assumes one parkiran per mall (uses first one).

**Future Enhancement**: If mall has multiple parkiran, add UI to let user select which one.

### Error Handling
If parkiran fetch fails, error only shows when user tries to book.

**Future Enhancement**: Show warning immediately if parkiran fetch fails.

## Debug Checklist

When booking fails, check:

- [ ] Mall exists in database
- [ ] Mall has at least one parkiran
- [ ] Parkiran status is "Tersedia"
- [ ] Auth token is valid
- [ ] Parkiran endpoint returns data
- [ ] `id_parkiran` is stored in `_selectedMall`
- [ ] Booking request includes `id_parkiran` (not `id_mall`)
- [ ] Backend receives correct field names

## Related Documentation

- `BOOKING_API_ENDPOINT_FIX.md` - Task 2 fix
- `BOOKING_PARKIRAN_ID_FIX.md` - Detailed Task 3 documentation
- `BOOKING_PARKIRAN_QUICK_REFERENCE.md` - Quick reference guide
- `test-booking-parkiran-fix.bat` - Test script

## Backend References

- **Controller**: `qparkin_backend/app/Http/Controllers/Api/MallController.php`
- **Model**: `qparkin_backend/app/Models/Parkiran.php`
- **Route**: `GET /api/mall/{id}/parkiran`
- **Validation**: `qparkin_backend/app/Http/Controllers/Api/BookingController.php` (line 47-53)
