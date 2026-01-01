# Vehicle Icon Consistency Fix

## Problem
Icon kendaraan tidak konsisten antara:
- **Halaman List Kendaraan**: Icon sesuai jenis kendaraan (motor, mobil, dll)
- **Halaman Profile (Vehicle Card)**: Icon selalu mobil biru, tidak peduli jenis kendaraan

## Root Cause
- `list_kendaraan.dart` memiliki fungsi lokal `_getVehicleIcon()` untuk mapping icon
- `vehicle_card.dart` menggunakan hardcoded `Icons.directions_car` dengan warna biru
- Tidak ada shared logic untuk icon mapping

## Solution
Membuat **centralized helper** untuk mapping icon dan warna kendaraan:

### 1. Created: `lib/utils/vehicle_icon_helper.dart`
Helper class dengan 3 static methods:
- `getIcon(String jenisKendaraan)` → Returns appropriate IconData
- `getColor(String jenisKendaraan)` → Returns appropriate Color
- `getBackgroundColor(String jenisKendaraan)` → Returns light background color

**Icon Mapping:**
- Roda Dua → `Icons.two_wheeler` (Teal - contrasts with purple theme)
- Roda Tiga → `Icons.electric_rickshaw` (Orange)
- Roda Empat → `Icons.directions_car` (Blue)
- Default (Lebih dari Enam) → `Icons.local_shipping` (Grey)

### 2. Updated: `lib/presentation/widgets/profile/vehicle_card.dart`
**Before:**
```dart
Container(
  decoration: BoxDecoration(
    color: const Color(0xFFE3F2FD), // Always blue
  ),
  child: const Icon(
    Icons.directions_car, // Always car icon
    color: Color(0xFF1872B3),
  ),
)
```

**After:**
```dart
Container(
  decoration: BoxDecoration(
    color: VehicleIconHelper.getBackgroundColor(vehicle.jenisKendaraan),
  ),
  child: Icon(
    VehicleIconHelper.getIcon(vehicle.jenisKendaraan),
    color: VehicleIconHelper.getColor(vehicle.jenisKendaraan),
  ),
)
```

### 3. Updated: `lib/presentation/screens/list_kendaraan.dart`
- Removed local `_getVehicleIcon()` function
- Replaced with `VehicleIconHelper.getIcon()`
- Added color consistency with `VehicleIconHelper.getColor()`

**Before:**
```dart
IconData _getVehicleIcon(String jenisKendaraan) {
  switch (jenisKendaraan.toLowerCase()) {
    case 'roda dua': return Icons.two_wheeler;
    // ...
  }
}

// Usage:
Icon(_getVehicleIcon(vehicle.jenisKendaraan), color: const Color(0xFF573ED1))
```

**After:**
```dart
// No local function needed

// Usage:
Icon(
  VehicleIconHelper.getIcon(vehicle.jenisKendaraan),
  color: VehicleIconHelper.getColor(vehicle.jenisKendaraan),
)
```

### 4. Created: `test/utils/vehicle_icon_helper_test.dart`
Comprehensive unit tests covering:
- Icon mapping for all vehicle types
- Color mapping for all vehicle types
- Background color generation
- Case-insensitive matching
- Consistency across variations

**Test Results:** ✅ All 16 tests passed

## Benefits
✅ **Consistency**: Icon dan warna sama di semua halaman
✅ **Maintainability**: Single source of truth untuk icon mapping
✅ **Reusability**: Helper dapat digunakan di halaman lain
✅ **Type Safety**: Centralized logic mengurangi typo
✅ **Testability**: Logic terpisah dan mudah di-test

## Files Changed
1. ✨ **NEW**: `lib/utils/vehicle_icon_helper.dart` (Helper class)
2. ✨ **NEW**: `test/utils/vehicle_icon_helper_test.dart` (Unit tests)
3. 🔧 **MODIFIED**: `lib/presentation/widgets/profile/vehicle_card.dart`
4. 🔧 **MODIFIED**: `lib/presentation/screens/list_kendaraan.dart`

## Visual Result
### Before:
- List Kendaraan: ✅ Icon sesuai jenis (motor/mobil/truck)
- Profile Card: ❌ Selalu icon mobil biru

### After:
- List Kendaraan: ✅ Icon sesuai jenis dengan warna konsisten
- Profile Card: ✅ Icon sesuai jenis dengan warna konsisten

## Testing
```bash
# Run unit tests
flutter test test/utils/vehicle_icon_helper_test.dart

# Run all tests
flutter test
```

## Future Usage
Jika ada halaman baru yang menampilkan kendaraan, gunakan helper ini:

```dart
import 'package:qparkin_app/utils/vehicle_icon_helper.dart';

// Get icon
IconData icon = VehicleIconHelper.getIcon(vehicle.jenisKendaraan);

// Get color
Color color = VehicleIconHelper.getColor(vehicle.jenisKendaraan);

// Get background color
Color bgColor = VehicleIconHelper.getBackgroundColor(vehicle.jenisKendaraan);
```

## Notes
- ✅ No backend changes required
- ✅ No API changes required
- ✅ Production-safe and minimal changes
- ✅ Backward compatible
- ✅ Case-insensitive matching for robustness
