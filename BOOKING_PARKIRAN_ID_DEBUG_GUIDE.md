# Booking "id_parkiran not found" Debug Guide

## Quick Diagnosis

Error terjadi di **Panbil Mall** (yang sudah memiliki parkiran di database).

### Step 1: Restart App dengan Logging

```bash
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

### Step 2: Reproduce Error

1. Open app
2. Go to Map page
3. Select **Panbil Mall**
4. Fill booking form (vehicle, time, duration)
5. Click **"Konfirmasi Booking"**

### Step 3: Check Logs

Look for this sequence:

```
[BookingPage] Initializing with baseUrl: http://192.168.0.101:8000
[BookingPage] Auth token available: true/false
[BookingProvider] ========== INITIALIZE START ==========
[BookingProvider] Initializing with mall: Panbil Mall
[BookingProvider] Token provided: true/false
[BookingProvider] Mall ID extracted: "4"
[BookingProvider] _selectedMall set with keys: [...]
[BookingProvider] Calling _fetchParkiranForMall...
[BookingService] Fetching parkiran for mall: 4
[BookingService] Parkiran response status: 200/401/404
[BookingProvider] ✅ Parkiran ID set successfully: 1
[BookingProvider] _selectedMall keys after fetch: [..., id_parkiran, ...]
[BookingProvider] id_parkiran value: 1
[BookingProvider] ========== INITIALIZE END ==========
```

## Diagnosis Tree

### Case 1: Token is null
```
[BookingPage] Auth token available: false
[BookingProvider] Token provided: false
[BookingProvider] ⚠️ SKIPPING _fetchParkiranForMall
```

**Problem:** Token not retrieved from secure storage

**Fix:**
1. Check if user is logged in
2. Verify token in secure storage:
   ```dart
   final token = await _storage.read(key: 'auth_token');
   debugPrint('Token: $token');
   ```
3. Re-login if needed

### Case 2: API Returns 401 Unauthorized
```
[BookingProvider] Calling _fetchParkiranForMall...
[BookingService] Parkiran response status: 401
```

**Problem:** Token expired or invalid

**Fix:**
1. Re-login
2. Check token expiration
3. Verify API authentication

### Case 3: API Returns 404 Not Found
```
[BookingProvider] Calling _fetchParkiranForMall...
[BookingService] Parkiran response status: 404
[BookingProvider] ❌ WARNING: No parkiran found
```

**Problem:** Parkiran not found (but we know it exists!)

**Possible causes:**
- Wrong mall ID being sent
- API endpoint issue
- Database query issue

**Fix:**
1. Check mall ID in logs
2. Verify API endpoint: `GET /api/mall/4/parkiran`
3. Test API directly:
   ```bash
   php qparkin_backend/test_panbil_mall_parkiran.php
   ```

### Case 4: API Returns Empty Array
```
[BookingProvider] Parkiran API response: []
[BookingProvider] Parkiran is empty: true
[BookingProvider] ❌ WARNING: No parkiran found
```

**Problem:** API returns success but empty data

**Fix:**
1. Check `MallController::getParkiran()` implementation
2. Verify mall status is 'active'
3. Check parkiran relationship in Mall model

### Case 5: Success but id_parkiran Still Missing
```
[BookingProvider] ✅ Parkiran ID set successfully: 1
[BookingProvider] _selectedMall keys after fetch: [..., id_parkiran, ...]
[BookingProvider] id_parkiran value: 1
...
[BookingProvider] ERROR: id_parkiran not found in mall data
[BookingProvider] Available keys: [id_mall, name, ...]  // NO id_parkiran!
```

**Problem:** `id_parkiran` was set but disappeared!

**Possible causes:**
- `_selectedMall` reference changed
- Map was copied instead of mutated
- Race condition (very unlikely)

**Fix:**
1. Check if `_selectedMall` is reassigned anywhere
2. Verify Map mutation works correctly
3. Add assertion after `initialize()`:
   ```dart
   assert(_selectedMall!.containsKey('id_parkiran'), 'id_parkiran must be set');
   ```

## Quick Fixes

### Fix 1: Ensure Token is Available

In `BookingPage._initializeAuthData()`:

```dart
final token = await _storage.read(key: 'auth_token');
if (token == null || token.isEmpty) {
  debugPrint('[BookingPage] ❌ No auth token - user must login');
  // Show login dialog or redirect
  return;
}
```

### Fix 2: Add Fallback for Missing id_parkiran

In `BookingProvider.confirmBooking()`:

```dart
final idParkiran = _selectedMall!['id_parkiran']?.toString();

if (idParkiran == null || idParkiran.isEmpty) {
  // Try to fetch parkiran again
  final mallId = _selectedMall!['id_mall']?.toString() ?? '';
  if (mallId.isNotEmpty && token.isNotEmpty) {
    debugPrint('[BookingProvider] Retrying _fetchParkiranForMall...');
    await _fetchParkiranForMall(mallId, token);
    
    // Check again
    final retryIdParkiran = _selectedMall!['id_parkiran']?.toString();
    if (retryIdParkiran == null || retryIdParkiran.isEmpty) {
      _errorMessage = 'Parkiran tidak tersedia. Silakan pilih mall lain.';
      return false;
    }
  } else {
    _errorMessage = 'Parkiran tidak tersedia. Silakan pilih mall lain.';
    return false;
  }
}
```

### Fix 3: Pre-fetch Parkiran in MapPage

Alternative approach - fetch parkiran when mall is selected:

```dart
// In MapPage._selectMall()
final parkiran = await _fetchParkiranForMall(mall.id);
if (parkiran != null && parkiran.isNotEmpty) {
  _selectedMall = {
    'id_mall': int.parse(mall.id),
    'id_parkiran': parkiran[0]['id_parkiran'],  // ✅ Set here
    'name': mall.name,
    // ... other fields
  };
}
```

## Test Commands

```bash
# Check database
cd qparkin_backend
php test_panbil_mall_parkiran.php

# Test API directly
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"

# Run Flutter app with verbose logging
flutter run --dart-define=API_URL=http://192.168.0.101:8000 --verbose
```

## Expected Result

After fix, logs should show:

```
[BookingProvider] ========== INITIALIZE START ==========
[BookingProvider] Token provided: true
[BookingProvider] Mall ID extracted: "4"
[BookingProvider] Calling _fetchParkiranForMall...
[BookingService] Parkiran response status: 200
[BookingProvider] ✅ Parkiran ID set successfully: 1
[BookingProvider] id_parkiran value: 1
[BookingProvider] ========== INITIALIZE END ==========
...
[BookingProvider] Confirming booking...
[BookingProvider] Using parkiran ID: 1
✅ Booking created successfully!
```

## Status

✅ Enhanced logging added
⏳ Waiting for test results
📝 Multiple fix strategies documented
