# Vehicle Selector Dropdown Equality Fix

## Problem
Ketika memilih kendaraan di VehicleSelector (booking_page), muncul error:
```
'package:flutter/src/material/dropdown.dart': Failed assertion: line 1796 pos 10: 
'items == null || items.isEmpty || (initialValue == null && value == null) || 
items.where((DropdownMenuItem<T> item) => item.value == (initialValue ?? value)).length == 1': 
There should be exactly one item with [DropdownButton]'s value: Instance of 'VehicleModel'.
Either zero or 2 or more [DropdownMenuItem]s were detected with the same value
```

**Log:**
```
I/flutter (10214): [BookingProvider] Selecting vehicle: B 1234 XY
I/flutter (10214): [BookingProvider] isSlotReservationEnabled: true
Another exception was thrown: There should be exactly one item with [DropdownButton]'s value: Instance of 'VehicleModel'.
```

## Root Cause

### Issue 1: Missing Equality Operator
`VehicleModel` tidak memiliki implementasi `==` operator dan `hashCode`. Flutter membandingkan object berdasarkan **instance reference**, bukan **value**.

**Flow yang menyebabkan masalah:**
1. VehicleSelector fetch vehicles → `List<VehicleModel>` (instance A)
2. User pilih vehicle → `onVehicleSelected(vehicleA)`
3. booking_page convert ke JSON → `vehicle.toJson()`
4. BookingProvider simpan sebagai Map → `_selectedVehicle = map`
5. booking_page convert kembali → `VehicleModel.fromJson(map)` (instance B)
6. VehicleSelector terima selectedVehicle → instance B
7. **Dropdown compare: instance B != instance A** ❌
8. Error: "value not found in items"

### Issue 2: Instance Mismatch
Dropdown menerima `selectedVehicle` yang merupakan **instance berbeda** dari items di list, meskipun datanya sama.

## Solution Applied

### 1. Add Equality Operator to VehicleModel
**File:** `qparkin_app/lib/data/models/vehicle_model.dart`

```dart
/// Override equality operator to compare vehicles by ID
/// This is crucial for DropdownButton to work correctly
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  return other is VehicleModel && other.idKendaraan == idKendaraan;
}

/// Override hashCode to match equality operator
@override
int get hashCode => idKendaraan.hashCode;
```

**Why this works:**
- Sekarang `vehicleA == vehicleB` jika `idKendaraan` sama
- Tidak peduli apakah instance berbeda
- Dropdown bisa menemukan matching item

### 2. Find Matching Vehicle by ID
**File:** `qparkin_app/lib/presentation/widgets/vehicle_selector.dart`

```dart
Widget _buildVehicleDropdown() {
  // Find matching vehicle in list by ID (not by instance)
  VehicleModel? matchingVehicle;
  if (widget.selectedVehicle != null) {
    try {
      matchingVehicle = _vehicles.firstWhere(
        (v) => v.idKendaraan == widget.selectedVehicle!.idKendaraan,
      );
      debugPrint('[VehicleSelector] Found matching vehicle: ${matchingVehicle.platNomor}');
    } catch (e) {
      debugPrint('[VehicleSelector] No matching vehicle found in list');
      matchingVehicle = null;
    }
  }
  
  return DropdownButtonFormField<VehicleModel>(
    value: matchingVehicle, // Use matching vehicle from list, not the passed one
    // ... rest of code
  );
}
```

**Why this works:**
- Cari vehicle di `_vehicles` list yang punya `idKendaraan` sama
- Gunakan instance dari list, bukan instance yang dikirim dari parent
- Dropdown pasti menemukan value di items karena menggunakan instance yang sama

### 3. Add Debug Logging
```dart
debugPrint('[VehicleSelector] Building dropdown with ${_vehicles.length} vehicles');
debugPrint('[VehicleSelector] Selected vehicle ID: ${widget.selectedVehicle!.idKendaraan}');
debugPrint('[VehicleSelector] Found matching vehicle: ${matchingVehicle.platNomor}');
debugPrint('[VehicleSelector] Vehicle selected: ${newValue?.platNomor}');
```

## How It Works Now

### Before Fix:
```
1. Fetch vehicles → [vehicleA, vehicleB] (instances from API)
2. Select vehicleA → convert to JSON → convert back to vehicleA' (new instance)
3. Dropdown compare: vehicleA' == vehicleA? → FALSE (different instances)
4. Error: value not found in items
```

### After Fix:
```
1. Fetch vehicles → [vehicleA, vehicleB] (instances from API)
2. Select vehicleA → convert to JSON → convert back to vehicleA' (new instance)
3. Find matching: vehicleA'.idKendaraan == vehicleA.idKendaraan? → TRUE
4. Use vehicleA from list (same instance as items)
5. Dropdown compare: vehicleA == vehicleA? → TRUE ✅
6. Success: vehicle selected
```

## Testing Steps

1. **Hot Restart** aplikasi:
   ```bash
   r  # di terminal Flutter
   ```

2. **Navigate to Booking Page**:
   - Buka map_page
   - Pilih mall
   - Tap "Booking"

3. **Test Vehicle Selection**:
   - ✅ Dropdown terbuka tanpa error
   - ✅ Bisa memilih kendaraan
   - ✅ Kendaraan terpilih ditampilkan dengan benar
   - ✅ Tidak ada error "There should be exactly one item"

4. **Check Debug Logs**:
   ```
   [VehicleSelector] Fetching vehicles from API...
   [VehicleSelector] Vehicles fetched successfully: 2 vehicles
   [VehicleSelector] Building dropdown with 2 vehicles
   [VehicleSelector] Selected vehicle ID: 1
   [VehicleSelector] Found matching vehicle: B 1234 XY
   [VehicleSelector] Vehicle selected: B 1234 XY
   ```

## Expected Behavior

### Before Fix:
```
❌ Error: There should be exactly one item with [DropdownButton]'s value
❌ Dropdown tidak bisa dibuka
❌ App crash saat pilih kendaraan
```

### After Fix:
```
✅ Dropdown terbuka normal
✅ Kendaraan bisa dipilih
✅ Selected vehicle ditampilkan dengan benar
✅ Tidak ada error
```

## Technical Details

### Dart Equality Rules
Tanpa override `==` operator:
```dart
VehicleModel a = VehicleModel(idKendaraan: '1', ...);
VehicleModel b = VehicleModel(idKendaraan: '1', ...);
print(a == b); // FALSE (different instances)
```

Dengan override `==` operator:
```dart
VehicleModel a = VehicleModel(idKendaraan: '1', ...);
VehicleModel b = VehicleModel(idKendaraan: '1', ...);
print(a == b); // TRUE (same idKendaraan)
```

### DropdownButton Requirements
DropdownButton requires:
1. `value` must be found in `items` list
2. Comparison uses `==` operator
3. Only **one** item should match the value

## Files Modified
1. `qparkin_app/lib/data/models/vehicle_model.dart` - Added `==` and `hashCode`
2. `qparkin_app/lib/presentation/widgets/vehicle_selector.dart` - Find matching vehicle by ID

## Related Issues
- Similar issue might occur in other dropdowns using custom models
- Always implement `==` and `hashCode` for models used in dropdowns
- Consider using `Equatable` package for automatic equality implementation

## Best Practices
1. **Always override `==` and `hashCode`** for models used in:
   - DropdownButton
   - ListView with keys
   - Set/Map as keys
   - Any comparison logic

2. **Use ID for comparison**, not all fields:
   ```dart
   @override
   bool operator ==(Object other) {
     return other is VehicleModel && other.idKendaraan == idKendaraan;
   }
   ```

3. **Match hashCode with equality**:
   ```dart
   @override
   int get hashCode => idKendaraan.hashCode;
   ```

## Summary
Fix ini menyelesaikan error dropdown dengan:
1. Menambahkan equality operator ke VehicleModel (compare by ID)
2. Mencari matching vehicle dari list berdasarkan ID
3. Menggunakan instance dari list, bukan instance baru

Sekarang VehicleSelector di booking_page berfungsi dengan benar dan user bisa memilih kendaraan tanpa error.
