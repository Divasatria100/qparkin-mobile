# Map to Booking - Mall ID Missing Fix

## Problem

BookingPage tidak bisa fetch floors karena mall data dari MapPage tidak menyertakan `id_mall`.

## Error Log

```
[BookingProvider] ERROR: Cannot fetch floors - invalid mall ID
[BookingProvider] Mall data: {name: Panbil Mall, distance: , address: ..., available: 1}
```

## Root Cause

MapPage mengirim mall data ke BookingPage tanpa `id_mall`, padahal BookingProvider membutuhkan `id_mall` untuk:
1. Fetch parking floors via API
2. Fetch parking slots
3. Calculate parking rates

## Solution

### File: `qparkin_app/lib/presentation/screens/map_page.dart`

**Method `_selectMall()` - Line ~62:**
```dart
void _selectMall(int index, MapProvider mapProvider) {
  final mall = mapProvider.malls[index];
  
  if (!mounted) return;
  setState(() {
    _selectedMallIndex = index;
    _selectedMall = {
      'id_mall': int.parse(mall.id), // ✅ CRITICAL: Add id_mall
      'name': mall.name,
      'nama_mall': mall.name,
      'distance': '',
      'address': mall.address,
      'alamat': mall.address,
      'available': mall.availableSlots,
    };
  });
}
```

**Method `_selectMallAndShowMap()` - Line ~82:**
```dart
Future<void> _selectMallAndShowMap(int index, MapProvider mapProvider) async {
  final mall = mapProvider.malls[index];
  
  if (!mounted) return;
  setState(() {
    _selectedMallIndex = index;
    _selectedMall = {
      'id_mall': int.parse(mall.id), // ✅ CRITICAL: Add id_mall
      'name': mall.name,
      'nama_mall': mall.name,
      'distance': '',
      'address': mall.address,
      'alamat': mall.address,
      'available': mall.availableSlots,
    };
  });
  
  // ... rest of the method
}
```

## Key Points

1. **MallModel property:** `mall.id` (String) - NOT `mall.idMall`
2. **BookingProvider expects:** `id_mall` (int)
3. **Conversion needed:** `int.parse(mall.id)`

## Testing

### Before Fix:
```dart
// Mall data sent to BookingPage
{
  'name': 'Panbil Mall',
  'address': '...',
  'available': 1
}
// ❌ Missing id_mall → BookingProvider can't fetch floors
```

### After Fix:
```dart
// Mall data sent to BookingPage
{
  'id_mall': 1,              // ✅ Now included
  'name': 'Panbil Mall',
  'nama_mall': 'Panbil Mall',
  'address': '...',
  'alamat': '...',
  'available': 1
}
// ✅ BookingProvider can fetch floors successfully
```

## Verification Steps

1. **Hot restart** Flutter app (not just hot reload)
2. Navigate to MapPage
3. Select a mall from list
4. Tap "Booking Sekarang"
5. Check logs - should see:
   ```
   [BookingProvider] Initializing with mall: Panbil Mall
   [BookingProvider] Fetching floors for mall ID: 1
   [BookingProvider] Floors fetched successfully
   ```

## Related Files

- `qparkin_app/lib/presentation/screens/map_page.dart` - Fixed
- `qparkin_app/lib/data/models/mall_model.dart` - Reference for property names
- `qparkin_app/lib/logic/providers/booking_provider.dart` - Expects id_mall
- `qparkin_app/lib/presentation/screens/booking_page.dart` - Receives mall data

## Status

✅ **FIXED** - MapPage now sends `id_mall` to BookingPage

## Notes

- **Hot reload won't work** - Need full restart because `_selectedMall` is state variable
- **Type conversion** - `mall.id` is String, must parse to int
- **Backward compatibility** - Added both `name`/`nama_mall` and `address`/`alamat` aliases
