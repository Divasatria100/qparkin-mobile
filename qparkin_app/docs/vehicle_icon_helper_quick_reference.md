# Vehicle Icon Helper - Quick Reference

## 📦 Import
```dart
import 'package:qparkin_app/utils/vehicle_icon_helper.dart';
```

## 🎯 Quick Usage

### Get Vehicle Icon
```dart
IconData icon = VehicleIconHelper.getIcon(vehicle.jenisKendaraan);
```

### Get Vehicle Color
```dart
Color color = VehicleIconHelper.getColor(vehicle.jenisKendaraan);
```

### Get Background Color
```dart
Color bgColor = VehicleIconHelper.getBackgroundColor(vehicle.jenisKendaraan);
```

## 📋 Complete Example

```dart
// In your widget
Container(
  width: 64,
  height: 64,
  decoration: BoxDecoration(
    color: VehicleIconHelper.getBackgroundColor(vehicle.jenisKendaraan),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(
    VehicleIconHelper.getIcon(vehicle.jenisKendaraan),
    color: VehicleIconHelper.getColor(vehicle.jenisKendaraan),
    size: 36,
  ),
)
```

## 🎨 Mapping Reference

| Input | Icon | Color | Hex |
|-------|------|-------|-----|
| `"Roda Dua"` | 🏍️ two_wheeler | Teal | #009688 |
| `"Roda Tiga"` | 🛺 electric_rickshaw | Orange | #FF9800 |
| `"Roda Empat"` | 🚗 directions_car | Blue | #1872B3 |
| `"Lebih dari Enam"` | 🚚 local_shipping | Grey | #757575 |
| Other | 🚚 local_shipping | Grey | #757575 |

## ✨ Features

- ✅ **Case-insensitive**: `"Roda Dua"`, `"roda dua"`, `"RODA DUA"` all work
- ✅ **Null-safe**: Returns default for unknown types
- ✅ **Consistent**: Same icon/color everywhere
- ✅ **Tested**: 16 unit tests

## 📍 Where It's Used

1. **List Kendaraan Page** (`list_kendaraan.dart`)
   - Vehicle list items

2. **Profile Page** (`vehicle_card.dart`)
   - Vehicle cards in profile

3. **Future Usage**
   - Any page displaying vehicles
   - Booking page vehicle selection
   - Vehicle detail pages

## 🧪 Testing

```bash
# Run helper tests
flutter test test/utils/vehicle_icon_helper_test.dart

# Run widget tests
flutter test test/widgets/vehicle_card_test.dart
```

## 💡 Tips

1. **Always use the helper** - Don't hardcode icons or colors
2. **Pass vehicle type directly** - No need to transform the string
3. **Use all three methods** - Icon, color, and background for consistency

## ⚠️ Don't Do This

```dart
// ❌ BAD - Hardcoded
Icon(Icons.directions_car, color: Colors.blue)

// ❌ BAD - Local function
IconData _getIcon(String type) { ... }

// ❌ BAD - Inconsistent colors
Icon(getIcon(type), color: Colors.purple) // Always purple
```

## ✅ Do This Instead

```dart
// ✅ GOOD - Using helper
Icon(
  VehicleIconHelper.getIcon(vehicle.jenisKendaraan),
  color: VehicleIconHelper.getColor(vehicle.jenisKendaraan),
)
```

## 🔗 Related Files

- **Implementation**: `lib/utils/vehicle_icon_helper.dart`
- **Tests**: `test/utils/vehicle_icon_helper_test.dart`
- **Documentation**: `docs/vehicle_icon_consistency_fix.md`
- **Usage Example 1**: `lib/presentation/screens/list_kendaraan.dart`
- **Usage Example 2**: `lib/presentation/widgets/profile/vehicle_card.dart`
