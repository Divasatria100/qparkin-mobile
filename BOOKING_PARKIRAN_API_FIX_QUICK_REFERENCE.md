# Booking Parkiran API Fix - Quick Reference

## What Was Fixed
✅ Backend API now includes `id_parkiran` in mall response  
✅ Mobile app MallModel updated to parse `id_parkiran`  
✅ Removed hardcode mapping from map_page.dart  
✅ Booking flow now uses API data instead of hardcoded values  

## Quick Test

### 1. Test Backend API
```bash
test-booking-parkiran-api-fix.bat
```

Expected: Each mall has `id_parkiran` field in response

### 2. Test Mobile App
1. Restart app
2. Go to Map page → Select mall → Booking
3. Fill form → Tap "Konfirmasi Booking"
4. Expected: No "id_parkiran not found" error

## Key Changes

### Backend (MallController.php)
```php
// Added to both index() and show() methods:
$firstParkiran = \App\Models\Parkiran::where('id_mall', $mall->id_mall)
    ->where('status', 'Tersedia')
    ->first();

return [
    'id_parkiran' => $firstParkiran ? $firstParkiran->id_parkiran : null,
    // ... rest of fields
];
```

### Mobile App (MallModel.dart)
```dart
class MallModel {
  final String? idParkiran;  // NEW FIELD
  
  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      idParkiran: json['id_parkiran']?.toString(),  // PARSE FROM API
      // ... rest of fields
    );
  }
}
```

### Mobile App (map_page.dart)
```dart
// REMOVED hardcode dictionary
// BEFORE:
final parkiranIdMap = {'1': '2', '2': '3', '3': '4', '4': '1'};
'id_parkiran': parkiranIdMap[mall.id] ?? mall.id,

// AFTER:
'id_parkiran': mall.idParkiran ?? mall.id,  // Use API data
```

## Database Reference
| Mall | Parkiran ID |
|------|-------------|
| Mega Mall Batam Centre | 2 |
| One Batam Mall | 3 |
| SNL Food Bengkong | 4 |
| Panbil Mall | 1 |

## Troubleshooting

### Error: "id_parkiran not found"
- Check API response includes `id_parkiran` field
- Verify MallModel.fromJson() parses it correctly
- Ensure app is restarted after code changes

### Error: "id_parkiran is null"
- Check database has parkiran record for that mall
- Verify parkiran status is 'Tersedia'
- Run: `php artisan tinker` → `Mall::with('parkiran')->find(X)`

## Files Modified
- `qparkin_backend/app/Http/Controllers/Api/MallController.php`
- `qparkin_app/lib/data/models/mall_model.dart`
- `qparkin_app/lib/presentation/screens/map_page.dart`

## Documentation
See `BOOKING_PARKIRAN_API_FIX_COMPLETE.md` for full details

---
**Status**: ✅ Complete | **Date**: Jan 15, 2026
