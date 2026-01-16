# Vehicle Selector Booking Page Fix

## Problem
VehicleSelector di booking_page.dart gagal memuat data kendaraan, padahal data sudah berhasil ditampilkan di:
- ✅ profile_page.dart
- ✅ list_kendaraan.dart  
- ✅ tambah_kendaraan.dart
- ❌ booking_page.dart (GAGAL)

## Root Cause
Ada **2 service berbeda** dengan **endpoint API berbeda**:

1. **VehicleService** (digunakan di booking_page.dart)
   - Endpoint: `/api/vehicles` ❌ (endpoint tidak ada di backend)
   - Method: `fetchVehicles()`
   - Auth: Token dikirim via constructor

2. **VehicleApiService** (digunakan di ProfileProvider)
   - Endpoint: `/api/kendaraan` ✅ (endpoint valid di backend)
   - Method: `getVehicles()`
   - Auth: Token diambil dari FlutterSecureStorage

## Solution Applied

### 1. Update booking_page.dart
**File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Changes:**
```dart
// BEFORE
import '../../data/services/vehicle_service.dart';
VehicleService? _vehicleService;

_vehicleService = VehicleService(
  baseUrl: baseUrl,
  authToken: token,
);

// AFTER
import '../../data/services/vehicle_api_service.dart';
VehicleApiService? _vehicleService;

_vehicleService = VehicleApiService(
  baseUrl: baseUrl,
);
```

### 2. Update vehicle_selector.dart
**File:** `qparkin_app/lib/presentation/widgets/vehicle_selector.dart`

**Changes:**
```dart
// BEFORE
import '../../data/services/vehicle_service.dart';
final VehicleService vehicleService;
final vehicles = await widget.vehicleService.fetchVehicles();

// AFTER
import '../../data/services/vehicle_api_service.dart';
final VehicleApiService vehicleService;
final vehicles = await widget.vehicleService.getVehicles();
```

### 3. Added Debug Logging
```dart
debugPrint('[VehicleSelector] Fetching vehicles from API...');
debugPrint('[VehicleSelector] Vehicles fetched successfully: ${vehicles.length} vehicles');
debugPrint('[VehicleSelector] Error fetching vehicles: $e');
```

## Why This Works

### VehicleApiService Advantages:
1. ✅ **Correct Endpoint**: Uses `/api/kendaraan` (matches backend)
2. ✅ **Secure Auth**: Gets token from FlutterSecureStorage automatically
3. ✅ **Consistent**: Same service used in ProfileProvider (proven working)
4. ✅ **Better Error Handling**: Handles 404 gracefully (empty list)
5. ✅ **Debug Logging**: Built-in logging for troubleshooting

### VehicleService Issues:
1. ❌ **Wrong Endpoint**: Uses `/api/vehicles` (doesn't exist in backend)
2. ❌ **Manual Auth**: Requires token passed via constructor
3. ❌ **Inconsistent**: Different from other pages
4. ❌ **No Debug Logging**: Hard to troubleshoot

## Testing Steps

1. **Hot Restart** aplikasi Flutter:
   ```bash
   # Di terminal Flutter
   r  # hot restart
   ```

2. **Navigate to Booking Page**:
   - Buka map_page.dart
   - Pilih mall
   - Tap "Booking"

3. **Verify Vehicle Selector**:
   - ✅ Loading shimmer muncul
   - ✅ Dropdown kendaraan terisi dengan data
   - ✅ Bisa memilih kendaraan
   - ✅ Data kendaraan sama dengan di profile_page

4. **Check Debug Logs**:
   ```
   [VehicleSelector] Fetching vehicles from API...
   [VehicleApiService] GET URL: http://192.168.0.101:8000/api/kendaraan
   [VehicleApiService] Response status: 200
   [VehicleSelector] Vehicles fetched successfully: X vehicles
   ```

## Expected Behavior

### Before Fix:
```
[VehicleSelector] Error fetching vehicles: Exception: Failed to fetch vehicles: 404
```

### After Fix:
```
[VehicleSelector] Fetching vehicles from API...
[VehicleApiService] GET URL: http://192.168.0.101:8000/api/kendaraan
[VehicleApiService] Response status: 200
[VehicleSelector] Vehicles fetched successfully: 2 vehicles
```

## Files Modified
1. `qparkin_app/lib/presentation/screens/booking_page.dart`
2. `qparkin_app/lib/presentation/widgets/vehicle_selector.dart`

## Related Files (Reference)
- `qparkin_app/lib/data/services/vehicle_api_service.dart` (correct service)
- `qparkin_app/lib/data/services/vehicle_service.dart` (deprecated, wrong endpoint)
- `qparkin_app/lib/logic/providers/profile_provider.dart` (working reference)

## Backend Endpoint
```
GET /api/kendaraan
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "plat_nomor": "B1234XYZ",
      "jenis_kendaraan": "Roda Empat",
      "merk": "Toyota",
      "tipe": "Avanza",
      "warna": "Hitam",
      "is_active": true
    }
  ]
}
```

## Summary
Fix ini menyelesaikan masalah VehicleSelector di booking_page dengan mengganti VehicleService (endpoint salah) dengan VehicleApiService (endpoint benar). Sekarang booking_page menggunakan service yang sama dengan profile_page, memastikan konsistensi dan data kendaraan berhasil dimuat.

## Additional Fix: Dropdown Equality Issue
Setelah data berhasil dimuat, ada masalah kedua: dropdown error saat memilih kendaraan. Fix ini juga sudah diterapkan:

1. **Added equality operator** ke VehicleModel (compare by ID)
2. **Find matching vehicle** dari list berdasarkan ID
3. **Use instance from list** untuk dropdown value

Lihat `VEHICLE_SELECTOR_DROPDOWN_EQUALITY_FIX.md` untuk detail lengkap.

## Additional Fix: Layout Overflow
Setelah dropdown berfungsi, ada masalah layout overflow (21 pixels) di vehicle item. Fix:

**File:** `qparkin_app/lib/presentation/widgets/vehicle_selector.dart`

```dart
Text(
  vehicle.platNomor,
  maxLines: 1,  // Added
  overflow: TextOverflow.ellipsis,  // Added
),
Text(
  '${vehicle.merk} ${vehicle.tipe}',
  maxLines: 1,  // Already had overflow, added maxLines
  overflow: TextOverflow.ellipsis,
),
```

**Why:** Tanpa `maxLines`, Text widget bisa expand melebihi available space, menyebabkan Column overflow.
