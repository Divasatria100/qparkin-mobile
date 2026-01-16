# Vehicle POST 404 Debug Guide

## Problem
POST tambah kendaraan gagal dengan error 404, padahal GET kendaraan berhasil.

## Investigation Steps

### 1. Backend Routes Verification ✅
**File:** `qparkin_backend/routes/api.php`

```php
// Line 48-54: Vehicle routes inside auth:sanctum middleware
Route::prefix('kendaraan')->group(function () {
    Route::get('/', [KendaraanController::class, 'index']);      // ✅ GET works
    Route::post('/', [KendaraanController::class, 'store']);     // ❓ POST fails
    Route::get('/{id}', [KendaraanController::class, 'show']);
    Route::put('/{id}', [KendaraanController::class, 'update']);
    Route::delete('/{id}', [KendaraanController::class, 'destroy']);
    Route::put('/{id}/set-active', [KendaraanController::class, 'setActive']);
});
```

**Expected Endpoint:** `POST /api/kendaraan`
**Status:** Route exists ✅

### 2. Controller Verification ✅
**File:** `qparkin_backend/app/Http/Controllers/Api/KendaraanController.php`

- `store()` method exists ✅
- Accepts multipart/form-data ✅
- Returns 201 on success ✅
- Has proper validation ✅

### 3. Flutter API Service Verification ✅
**File:** `qparkin_app/lib/data/services/vehicle_api_service.dart`

```dart
// Line 68: POST endpoint construction
final uri = Uri.parse('$baseUrl/kendaraan');
```

**Base URL from main.dart:**
```dart
const String apiBaseUrl = String.fromEnvironment('API_URL', 
    defaultValue: 'http://localhost:8000/api');
```

**Expected URL:** `http://localhost:8000/api/kendaraan`

### 4. Comparison: GET vs POST

| Aspect | GET (Works ✅) | POST (Fails ❌) |
|--------|---------------|----------------|
| Endpoint | `/api/kendaraan` | `/api/kendaraan` |
| Method | `http.get()` | `http.MultipartRequest('POST')` |
| Headers | `Authorization`, `Accept` | `Authorization`, `Accept` |
| Auth | Bearer token | Bearer token |

### 5. Debug Logging Added

Added debug logging to both methods to compare actual URLs:

```dart
// GET method
print('[VehicleApiService] GET URL: $uri');
print('[VehicleApiService] Base URL: $baseUrl');
print('[VehicleApiService] GET Response status: ${response.statusCode}');

// POST method  
print('[VehicleApiService] POST URL: $uri');
print('[VehicleApiService] Base URL: $baseUrl');
print('[VehicleApiService] Token present: ${token != null && token.isNotEmpty}');
print('[VehicleApiService] Response status: ${response.statusCode}');
print('[VehicleApiService] Response body: ${response.body}');
```

## Testing Instructions

### Run Flutter App with Logging

```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.x.xx:8000/api
```

### Test Sequence

1. **Test GET (should work):**
   - Open Profile page
   - Check console for GET logs
   - Verify URL is correct

2. **Test POST (currently fails):**
   - Click "Tambah Kendaraan"
   - Fill form and submit
   - Check console for POST logs
   - Compare URLs between GET and POST

### Expected Log Output

```
[VehicleApiService] GET URL: http://192.168.x.xx:8000/api/kendaraan
[VehicleApiService] Base URL: http://192.168.x.xx:8000/api
[VehicleApiService] GET Response status: 200

[VehicleApiService] POST URL: http://192.168.x.xx:8000/api/kendaraan
[VehicleApiService] Base URL: http://192.168.x.xx:8000/api
[VehicleApiService] Token present: true
[VehicleApiService] Response status: 404
[VehicleApiService] Response body: {...}
```

## Possible Causes

### Hypothesis 1: Token Issue
- GET might be using cached/valid token
- POST might have expired/invalid token
- **Check:** Compare token values in logs

### Hypothesis 2: Middleware Issue
- Laravel might be rejecting POST for some reason
- CSRF protection? (shouldn't apply to API)
- **Check:** Backend logs

### Hypothesis 3: Content-Type Issue
- MultipartRequest might need different headers
- **Check:** Request headers in network inspector

### Hypothesis 4: Route Caching
- Laravel route cache might be stale
- **Fix:** Run `php artisan route:clear`

## Next Steps

1. ✅ Add debug logging (DONE)
2. ⏳ Run app and collect logs
3. ⏳ Compare GET vs POST URLs
4. ⏳ Check backend Laravel logs
5. ⏳ Verify token validity
6. ⏳ Test with Postman/curl to isolate issue

## Backend Debug Commands

```bash
cd qparkin_backend

# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# View routes
php artisan route:list | grep kendaraan

# Check logs
tail -f storage/logs/laravel.log
```

## Manual API Test

Test POST directly with curl:

```bash
# Get token first (login)
curl -X POST http://192.168.x.xx:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Use token to POST vehicle
curl -X POST http://192.168.x.xx:8000/api/kendaraan \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json" \
  -F "plat_nomor=B1234XYZ" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true"
```

## Status

- [x] Routes verified
- [x] Controller verified  
- [x] API service verified
- [x] Debug logging added
- [ ] Logs collected
- [ ] Root cause identified
- [ ] Fix implemented
- [ ] Tested and verified

## Notes

- GET works perfectly, so auth and base URL are correct
- POST uses same base URL construction
- Issue is specific to POST method
- Need to see actual logs to determine root cause
