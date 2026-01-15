# Booking "id_parkiran not found" Fix

## Problem
Error saat konfirmasi booking di Panbil Mall (yang SUDAH MEMILIKI parkiran):
```
[BookingProvider] ERROR: id_parkiran not found in mall data
[BookingProvider] Mall: Panbil Mall
[BookingProvider] Available keys: [id_mall, name, nama_mall, distance, address, alamat, available, has_slot_reservation_enabled]
```

## Root Cause Analysis

### Database Check ✅
```bash
php test_panbil_mall_parkiran.php
```
Result: Panbil Mall **HAS** parkiran (ID: 1, Nama: Mawar)

### Flow Analysis

1. **MapPage** creates mall data:
   ```dart
   _selectedMall = {
     'id_mall': int.parse(mall.id),
     'name': mall.name,
     // ... other fields
     // ❌ NO 'id_parkiran' here
   };
   ```

2. **BookingPage** calls `initialize()`:
   ```dart
   await _bookingProvider!.initialize(widget.mall, token: _authToken);
   ```

3. **BookingProvider.initialize()** should call `_fetchParkiranForMall()`:
   ```dart
   _selectedMall = mallData; // Reference to map from MapPage
   
   if (token != null && mallId.isNotEmpty) {
     await _fetchParkiranForMall(mallId, token);
     // Should set: _selectedMall!['id_parkiran'] = idParkiran;
   }
   ```

4. **User clicks "Konfirmasi Booking"**
5. **confirmBooking()** checks for `id_parkiran`:
   ```dart
   final idParkiran = _selectedMall!['id_parkiran']?.toString();
   if (idParkiran == null || idParkiran.isEmpty) {
     // ❌ ERROR: id_parkiran not found
   }
   ```

### Possible Causes

1. **Token is null** → `_fetchParkiranForMall()` not called
2. **API call fails** → `id_parkiran` not set
3. **Race condition** → User clicks before fetch completes (unlikely with `await`)
4. **Silent error** → Exception caught but not logged

## Solution

### 1. Enhanced Logging

Added comprehensive logging to `initialize()`:

```dart
Future<void> initialize(Map<String, dynamic> mallData, {String? token}) async {
  debugPrint('[BookingProvider] ========== INITIALIZE START ==========');
  debugPrint('[BookingProvider] Token provided: ${token != null}');
  debugPrint('[BookingProvider] Mall ID: "$mallId"');
  
  _selectedMall = mallData;
  debugPrint('[BookingProvider] _selectedMall keys: ${_selectedMall!.keys.toList()}');
  
  if (token != null && mallId.isNotEmpty) {
    debugPrint('[BookingProvider] Calling _fetchParkiranForMall...');
    await _fetchParkiranForMall(mallId, token);
    debugPrint('[BookingProvider] _selectedMall keys after fetch: ${_selectedMall!.keys.toList()}');
    debugPrint('[BookingProvider] id_parkiran value: ${_selectedMall!['id_parkiran']}');
  } else {
    debugPrint('[BookingProvider] ⚠️ SKIPPING _fetchParkiranForMall');
  }
  
  debugPrint('[BookingProvider] ========== INITIALIZE END ==========');
}
```

### 2. Better Error Handling in `_fetchParkiranForMall()`

Already implemented:
- Sets `_errorMessage` if parkiran not found
- Logs all API responses
- Handles null/empty responses

### 3. Validation in `confirmBooking()`

Already implemented:
- Checks if `id_parkiran` exists
- Shows clear error message
- Logs available keys for debugging

## Testing

### 1. Check Logs

Run the app and watch for:
```
[BookingProvider] ========== INITIALIZE START ==========
[BookingProvider] Token provided: true/false
[BookingProvider] Calling _fetchParkiranForMall...
[BookingProvider] _selectedMall keys after fetch: [...]
[BookingProvider] id_parkiran value: 1
[BookingProvider] ========== INITIALIZE END ==========
```

### 2. Expected Scenarios

#### Scenario A: Token is null
```
[BookingProvider] Token provided: false
[BookingProvider] ⚠️ SKIPPING _fetchParkiranForMall
```
**Fix:** Ensure token is passed from BookingPage

#### Scenario B: API call fails
```
[BookingProvider] Calling _fetchParkiranForMall...
[BookingService] Parkiran response status: 401/404/500
[BookingProvider] ❌ WARNING: No parkiran found
```
**Fix:** Check API authentication and endpoint

#### Scenario C: Success
```
[BookingProvider] Calling _fetchParkiranForMall...
[BookingProvider] ✅ Parkiran ID set successfully: 1
[BookingProvider] id_parkiran value: 1
```
**Result:** Booking should work!

## Quick Test

```bash
# 1. Restart Flutter app
flutter run --dart-define=API_URL=http://192.168.0.101:8000

# 2. Select Panbil Mall
# 3. Fill booking form
# 4. Click "Konfirmasi Booking"
# 5. Check logs for INITIALIZE START/END
```

## Files Modified

- `qparkin_app/lib/logic/providers/booking_provider.dart`
  - Added `import 'dart:math';`
  - Enhanced logging in `initialize()`
  - Better error tracking

## Next Steps

1. **Run app and check logs** to identify which scenario is happening
2. **If token is null:** Fix token passing in BookingPage
3. **If API fails:** Check backend authentication
4. **If success but still fails:** Check for Map mutation issues

## Status

✅ Enhanced logging added
⏳ Waiting for test results to identify root cause
