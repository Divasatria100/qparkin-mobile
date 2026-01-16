# Booking Parkiran ID Debug Guide

## Problem Summary

**Error**: "Data parkiran tidak tersedia silahkan pilih mall lagi"

**Log**: `[BookingProvider] ERROR: id_parkiran not found in mall data`

**Root Cause**: The booking flow requires `id_parkiran` (parking area ID), but it's not being fetched or stored properly during initialization.

---

## Architecture Overview

```
Database Structure:
mall (id_mall) → parkiran (id_parkiran, id_mall) → parking_floors → parking_slots
     1                    1-to-many                      1-to-many        1-to-many

Booking Flow:
1. User selects mall from map (has id_mall)
2. BookingProvider.initialize() is called
3. _fetchParkiranForMall() queries /api/mall/{id}/parkiran
4. id_parkiran is stored in _selectedMall
5. User confirms booking
6. BookingRequest uses id_parkiran (NOT id_mall)
```

---

## Debug Steps

### Step 1: Verify Database Has Parkiran

Run this SQL query:

```sql
SELECT 
    m.id_mall,
    m.nama_mall,
    p.id_parkiran,
    p.nama_parkiran,
    p.status
FROM mall m
LEFT JOIN parkiran p ON m.id_mall = p.id_mall
WHERE m.id_mall = 4;
```

**Expected Result**: Should return at least one parkiran row with `id_parkiran` value.

**If No Parkiran Found**:
- Go to Admin Dashboard → Parkiran
- Create a parkiran for the mall
- Note: Each mall should have exactly 1 parkiran (enforced by business logic)

---

### Step 2: Test API Endpoint

Run the test script:

```bash
test-parkiran-fetch-debug.bat
```

Or manually test with curl:

```bash
curl -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:

```json
{
  "success": true,
  "message": "Parking areas retrieved successfully",
  "data": [
    {
      "id_parkiran": 1,
      "nama_parkiran": "Parkiran Mall A",
      "lantai": 3,
      "kapasitas": 100,
      "status": "Tersedia"
    }
  ]
}
```

**Common Issues**:
- **404 Not Found**: Mall doesn't exist or has no parkiran
- **401 Unauthorized**: Token is invalid or expired
- **500 Server Error**: Database connection issue or query error

---

### Step 3: Check Flutter Logs

Run the Flutter app and watch for these log messages:

```
[BookingProvider] Fetching parkiran for mall: 4
[BookingService] Request URL: http://192.168.0.101:8000/api/mall/4/parkiran
[BookingService] Parkiran response status: 200
[BookingService] Parkiran response body: {...}
[BookingService] ✅ Found 1 parkiran
[BookingProvider] Parkiran API response: [...]
[BookingProvider] First parkiran data: {...}
[BookingProvider] Extracted id_parkiran: "1"
[BookingProvider] ✅ Parkiran ID set successfully: 1
```

**If You See**:
- `❌ WARNING: No parkiran found` → Database has no parkiran for this mall
- `❌ API returned success: false` → Backend returned error response
- `❌ Parkiran has no ID` → Database row missing `id_parkiran` field
- `❌ Error fetching parkiran` → Network error or exception

---

### Step 4: Verify Token is Valid

The token must be passed from the previous screen. Check `map_page.dart`:

```dart
// When navigating to booking page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingPage(
      mallData: selectedMall,
      token: token, // ← Must be passed here
    ),
  ),
);
```

And in `booking_page.dart`:

```dart
@override
void initState() {
  super.initState();
  
  // Initialize provider with token
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Provider.of<BookingProvider>(context, listen: false)
        .initialize(widget.mallData, token: widget.token); // ← Token must be passed
  });
}
```

---

### Step 5: Check Timing Issues

The error might occur if booking is confirmed before parkiran fetch completes.

**Solution**: Add loading state check in `booking_page.dart`:

```dart
// Disable confirm button while initializing
ElevatedButton(
  onPressed: bookingProvider.isLoading || bookingProvider.selectedMall?['id_parkiran'] == null
      ? null
      : () => _confirmBooking(),
  child: Text('Konfirmasi Booking'),
)
```

---

## Enhanced Logging (Already Applied)

### BookingProvider Changes

Added detailed logging in `_fetchParkiranForMall()`:
- ✅ Log API response
- ✅ Log parkiran data structure
- ✅ Log extracted id_parkiran
- ✅ Log success/failure with emojis
- ✅ Log stack trace on errors

### BookingService Changes

Added detailed logging in `getParkiranForMall()`:
- ✅ Log request URL
- ✅ Log response status and body
- ✅ Log parsed JSON
- ✅ Log parkiran count and data
- ✅ Handle 404, 401, and other status codes

---

## Quick Fix Checklist

- [ ] Database has parkiran for the mall (SQL query)
- [ ] API endpoint returns 200 with parkiran data (curl test)
- [ ] Token is valid and passed to initialize() method
- [ ] Flutter logs show successful parkiran fetch
- [ ] _selectedMall contains 'id_parkiran' key before booking
- [ ] No timing issues (await initialize() properly)

---

## Common Solutions

### Solution 1: Create Parkiran in Database

If mall has no parkiran:

1. Go to Admin Dashboard
2. Navigate to Parkiran page
3. Click "Tambah Parkiran"
4. Fill in details for the mall
5. Save

### Solution 2: Fix Token Passing

Ensure token is passed through the navigation chain:

```dart
// map_page.dart
final token = await _authService.getToken();

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingPage(
      mallData: mall,
      token: token, // ← Pass token
    ),
  ),
);
```

### Solution 3: Add Loading Indicator

Show loading state while fetching parkiran:

```dart
if (bookingProvider.isLoading) {
  return Center(child: CircularProgressIndicator());
}

if (bookingProvider.selectedMall?['id_parkiran'] == null) {
  return Center(
    child: Text('Memuat data parkiran...'),
  );
}
```

---

## Testing After Fix

1. **Run Flutter app** with enhanced logging
2. **Select a mall** from map page
3. **Watch logs** for parkiran fetch
4. **Verify** id_parkiran is set
5. **Confirm booking** and check if error is gone

---

## Related Files

- `qparkin_app/lib/logic/providers/booking_provider.dart` (initialize, _fetchParkiranForMall)
- `qparkin_app/lib/data/services/booking_service.dart` (getParkiranForMall)
- `qparkin_backend/app/Http/Controllers/Api/MallController.php` (getParkiran)
- `qparkin_backend/routes/api.php` (route definition)
- `qparkin_app/lib/presentation/screens/booking_page.dart` (UI initialization)
- `qparkin_app/lib/presentation/screens/map_page.dart` (navigation with token)

---

## Next Steps

1. **Run the test script** to verify API endpoint
2. **Check database** for parkiran data
3. **Run Flutter app** and watch enhanced logs
4. **Report findings** with log output

The enhanced logging will show exactly where the issue is occurring!
