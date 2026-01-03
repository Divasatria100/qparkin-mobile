# Vehicle POST 404 - Quick Fix Guide

## Problem Summary
POST `/api/kendaraan` returns 404, but GET `/api/kendaraan` works fine.

## Root Cause Analysis

### What We Know:
1. ✅ Backend route exists: `POST /api/kendaraan` 
2. ✅ Controller method exists: `KendaraanController@store`
3. ✅ GET request works perfectly
4. ✅ Same base URL used for both GET and POST
5. ✅ Auth token is present
6. ❌ POST request fails with 404

### Possible Causes:

#### 1. MultipartRequest Issue (Most Likely)
Flutter's `MultipartRequest` might be constructing the URL differently or adding extra path segments.

#### 2. Laravel Route Caching
Routes might be cached with old configuration.

#### 3. Middleware Interference
Sanctum's `EnsureFrontendRequestsAreStateful` might be interfering.

## Fix Applied

### Solution 1: Conditional Request Type
Modified `vehicle_api_service.dart` to use:
- **Regular JSON POST** when no photo (simpler, less prone to issues)
- **Multipart POST** only when photo is provided

```dart
// Use multipart only if photo is provided
if (foto != null) {
  // Multipart request for photo upload
  var request = http.MultipartRequest('POST', uri);
  // ... multipart logic
} else {
  // Regular JSON POST without photo
  response = await http.post(
    uri,
    headers: headers,
    body: json.encode(body),
  );
}
```

**Benefits:**
- Simpler request for common case (no photo)
- Easier to debug
- Less chance of URL construction issues
- Still supports photo upload when needed

### Solution 2: Enhanced Debug Logging
Added comprehensive logging to track:
- Full URL being called
- Token presence
- Whether photo is included
- Response status and body

## Testing Instructions

### 1. Clear Backend Caches
```bash
cd qparkin_backend
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan optimize:clear
```

### 2. Verify Routes
```bash
php artisan route:list | grep kendaraan
```

Expected output:
```
POST   api/kendaraan .............. kendaraan.store › Api\KendaraanController@store
GET    api/kendaraan .............. kendaraan.index › Api\KendaraanController@index
```

### 3. Test Flutter App
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.x.xx:8000/api
```

### 4. Test Add Vehicle
1. Open app
2. Go to Profile
3. Click "Tambah Kendaraan"
4. Fill form WITHOUT photo first
5. Submit
6. Check console logs

Expected logs:
```
[VehicleApiService] POST URL: http://192.168.x.xx:8000/api/kendaraan
[VehicleApiService] Base URL: http://192.168.x.xx:8000/api
[VehicleApiService] Token present: true
[VehicleApiService] Has photo: false
[VehicleApiService] Response status: 201
[VehicleApiService] Response body: {"success":true,...}
```

### 5. Test with Photo
1. Try adding vehicle WITH photo
2. Verify multipart request works

## Alternative Solutions (If Above Doesn't Work)

### Option A: Check Laravel Logs
```bash
cd qparkin_backend
tail -f storage/logs/laravel.log
```

Look for:
- Route not found errors
- Authentication errors
- Validation errors

### Option B: Test with Postman/curl

#### Get Token:
```bash
curl -X POST http://192.168.x.xx:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

#### Test POST (JSON):
```bash
curl -X POST http://192.168.x.xx:8000/api/kendaraan \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "plat_nomor": "B1234XYZ",
    "jenis_kendaraan": "Roda Empat",
    "merk": "Toyota",
    "tipe": "Avanza",
    "warna": "Hitam",
    "is_active": true
  }'
```

#### Test POST (Multipart):
```bash
curl -X POST http://192.168.x.xx:8000/api/kendaraan \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json" \
  -F "plat_nomor=B1234XYZ" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true"
```

### Option C: Add Backend Logging

Add to `KendaraanController@store`:
```php
public function store(Request $request)
{
    \Log::info('Vehicle store called', [
        'method' => $request->method(),
        'url' => $request->fullUrl(),
        'headers' => $request->headers->all(),
        'data' => $request->all(),
    ]);
    
    // ... rest of method
}
```

### Option D: Check .env Configuration
```bash
cd qparkin_backend
cat .env | grep -E "APP_URL|SANCTUM"
```

Ensure:
```
APP_URL=http://192.168.x.xx:8000
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1
```

## Verification Checklist

- [ ] Backend caches cleared
- [ ] Routes verified with `route:list`
- [ ] Flutter app runs without errors
- [ ] GET vehicles works (baseline)
- [ ] POST vehicle without photo works
- [ ] POST vehicle with photo works
- [ ] Debug logs show correct URL
- [ ] Response status is 201
- [ ] Vehicle appears in list

## Success Criteria

✅ POST request returns 201
✅ Vehicle is created in database
✅ Vehicle appears in GET list
✅ No 404 errors in logs
✅ Both JSON and multipart requests work

## Rollback Plan

If fix doesn't work, revert to original multipart-only approach:
```bash
cd qparkin_app
git checkout lib/data/services/vehicle_api_service.dart
```

## Next Steps After Fix

1. Remove debug logging (or keep for production debugging)
2. Test all vehicle operations (GET, POST, PUT, DELETE)
3. Test with various network conditions
4. Update documentation
5. Create regression test

## Contact

If issue persists after trying all solutions:
1. Collect all logs (Flutter + Laravel)
2. Test with curl to isolate Flutter vs backend issue
3. Check network inspector in Flutter DevTools
4. Verify database migrations are up to date
