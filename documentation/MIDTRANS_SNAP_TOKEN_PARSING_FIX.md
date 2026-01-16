# Midtrans Snap Token Parsing Fix

## Problem

Mobile app error saat parsing response:
```
NoSuchMethodError: The method '[]' was called on null.
Receiver: null
Tried calling: []("snap_token")
```

**Backend Response** (correct):
```json
{
  "success": true,
  "snap_token": "c24bafe9-3391-45dd-861f-dbf4a9003007",
  "order_id": "BOOKING-31-1768483247",
  "amount": 10000,
  "booking_id": "31",
  "message": "Snap token generated successfully"
}
```

**Mobile App Code** (incorrect):
```dart
final data = json.decode(response.body);
final snapToken = data['data']['snap_token'];  // ❌ Expects nested 'data'
```

Error terjadi karena `data['data']` is null (field tidak ada), lalu mencoba akses `['snap_token']` pada null.

## Solution

Ubah mobile app untuk mengakses `snap_token` di root level:

```dart
// BEFORE (WRONG)
final snapToken = data['data']['snap_token'];

// AFTER (CORRECT)
final snapToken = data['snap_token'];
```

## Files Changed

- `qparkin_app/lib/presentation/screens/midtrans_payment_page.dart`

## Testing

1. Cleanup incomplete booking:
```bash
php qparkin_backend/cleanup_simple.php 2
```

2. Create booking from mobile app
3. Payment page should now load successfully with Midtrans WebView

## Expected Flow

1. ✅ User creates booking → Success (id_booking: 31)
2. ✅ App calls POST `/api/bookings/31/payment/snap-token` → 200 OK
3. ✅ Backend returns snap_token
4. ✅ App parses snap_token correctly
5. ✅ WebView loads Midtrans payment page

## Status

✅ **FIXED** - Snap token parsing corrected
