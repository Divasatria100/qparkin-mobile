# Booking HTTP 422 Error Fix - Parkiran ID Missing

## Problem Summary

**Error**: HTTP 422 validation error when creating booking
```
"The id parkiran field is required. (and 1 more error)"
"errors": {
  "id_parkiran": ["The id parkiran field is required."],
  "durasi_booking": ["The durasi booking field is required."]
}
```

**Root Cause**: Field name mismatch and incorrect ID type
- Flutter was sending `id_mall` (mall ID)
- Backend expects `id_parkiran` (parking area ID)
- **Key insight**: A mall can have multiple parkiran (parking areas), so `id_mall ≠ id_parkiran`

## Database Structure

```
mall (id_mall)
  └── parkiran (id_parkiran, id_mall)  ← One-to-many relationship
        └── parking_floors (id_floor, id_parkiran)
              └── parking_slots (id_slot, id_floor)
```

## Solution Implemented

### 1. Added Parkiran Fetching to BookingProvider

**File**: `qparkin_app/lib/logic/providers/booking_provider.dart`

- Changed `initialize()` from sync to async
- Added `_fetchParkiranForMall()` method to get parkiran ID
- Stores `id_parkiran` in `_selectedMall` for booking creation

```dart
Future<void> initialize(Map<String, dynamic> mallData, {String? token}) async {
  // ... existing code ...
  
  // Fetch parkiran ID for this mall (required for booking)
  if (token != null && mallId.isNotEmpty) {
    await _fetchParkiranForMall(mallId, token);
  }
}

Future<void> _fetchParkiranForMall(String mallId, String token) async {
  final parkiran = await _bookingService.getParkiranForMall(
    mallId: mallId,
    token: token,
  );
  
  if (parkiran != null && parkiran.isNotEmpty) {
    final idParkiran = parkiran[0]['id_parkiran']?.toString() ?? '';
    _selectedMall!['id_parkiran'] = idParkiran;
  }
}
```

### 2. Updated Booking Request Creation

**File**: `qparkin_app/lib/logic/providers/booking_provider.dart`

Changed from using `id_mall` to `id_parkiran`:

```dart
// Before
final request = BookingRequest(
  idMall: _selectedMall!['id_mall']?.toString() ?? '',
  // ...
);

// After
final idParkiran = _selectedMall!['id_parkiran']?.toString();

if (idParkiran == null || idParkiran.isEmpty) {
  _errorMessage = 'Data parkiran tidak tersedia. Silakan pilih mall lagi.';
  return false;
}

final request = BookingRequest(
  idMall: idParkiran, // Use parkiran ID (not mall ID)
  // ...
);
```

### 3. Added API Method to BookingService

**File**: `qparkin_app/lib/data/services/booking_service.dart`

Added method to fetch parkiran for a mall:

```dart
Future<List<Map<String, dynamic>>?> getParkiranForMall({
  required String mallId,
  required String token,
}) async {
  final uri = Uri.parse('$_baseUrl/api/mall/$mallId/parkiran');
  
  final response = await _client.get(uri, headers: {
    'Authorization': 'Bearer $token',
  });
  
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }
  return null;
}
```

### 4. Updated Booking Page Initialization

**File**: `qparkin_app/lib/presentation/screens/booking_page.dart`

Changed to await the async initialize:

```dart
// Before
_bookingProvider!.initialize(widget.mall);

// After
await _bookingProvider!.initialize(widget.mall, token: _authToken);
```

## Backend API Used

**Endpoint**: `GET /api/mall/{id}/parkiran`

**Controller**: `MallController@getParkiran`

**Response**:
```json
{
  "success": true,
  "message": "Parking areas retrieved successfully",
  "data": [
    {
      "id_parkiran": 1,
      "nama_parkiran": "Parkiran Utama",
      "lantai": 3,
      "kapasitas": 200,
      "status": "Tersedia"
    }
  ]
}
```

## Field Mapping Summary

| Flutter Field | Backend Field | Description |
|--------------|---------------|-------------|
| `idMall` (in BookingRequest) | `id_parkiran` | Parking area ID (not mall ID!) |
| `durasiJam` | `durasi_booking` | Duration in hours |
| `waktuMulai` | `waktu_mulai` | Start time (ISO 8601) |
| `idKendaraan` | `id_kendaraan` | Vehicle ID |

## Testing

1. **Run Flutter app**:
   ```bash
   cd qparkin_app
   flutter run --dart-define=API_URL=http://192.168.x.xx:8000
   ```

2. **Test booking flow**:
   - Select a mall from map
   - Navigate to booking page
   - Check logs for: `[BookingProvider] Parkiran ID set: X`
   - Select vehicle, time, duration
   - Confirm booking
   - Should succeed with HTTP 201

3. **Expected logs**:
   ```
   [BookingProvider] Initializing with mall: Mall Name
   [BookingService] Fetching parkiran for mall: 4
   [BookingService] Found 1 parkiran
   [BookingProvider] Parkiran ID set: 1
   [BookingProvider] Sending booking request: {id_parkiran: 1, ...}
   ```

## Notes

- **Assumption**: Most malls have one parkiran, so we use the first one
- **Future enhancement**: If a mall has multiple parkiran, add UI to let user select
- **Error handling**: If parkiran fetch fails, user will see error when trying to book
- **Backward compatibility**: The `idMall` field in `BookingRequest` model is kept for compatibility but now contains `id_parkiran`

## Files Modified

1. `qparkin_app/lib/logic/providers/booking_provider.dart`
2. `qparkin_app/lib/data/services/booking_service.dart`
3. `qparkin_app/lib/presentation/screens/booking_page.dart`
4. `qparkin_app/lib/data/models/booking_request.dart` (already fixed in previous task)

## Related Documentation

- `BOOKING_API_ENDPOINT_FIX.md` - Previous fix for endpoint URLs
- Backend: `qparkin_backend/app/Http/Controllers/Api/MallController.php`
- Backend: `qparkin_backend/app/Models/Parkiran.php`
