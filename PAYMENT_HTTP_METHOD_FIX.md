# Payment Endpoint HTTP Method Fix

## Problem

Mobile app mengirim request dengan **POST method**:
```dart
final response = await http.post(
  Uri.parse('$baseUrl/api/bookings/${widget.booking.idBooking}/payment/snap-token'),
```

Backend route menggunakan **GET method**:
```php
Route::get('/bookings/{id}/payment/snap-token', [BookingController::class, 'getSnapToken']);
```

**Error**: `The POST method is not supported for route api/bookings/30/payment/snap-token. Supported methods: GET, HEAD.`

## Solution

Ubah backend route dari GET ke POST:

```php
// BEFORE
Route::get('/bookings/{id}/payment/snap-token', [BookingController::class, 'getSnapToken']);

// AFTER
Route::post('/bookings/{id}/payment/snap-token', [BookingController::class, 'getSnapToken']);
```

## Why POST?

POST lebih semantik untuk operasi "create token" karena:
- Membuat resource baru (snap token)
- Tidak idempotent (setiap call generate token baru)
- Sesuai dengan RESTful best practices

## Files Changed

- `qparkin_backend/routes/api.php` - Changed GET to POST

## Testing

Restart backend dan test dari mobile app:
```bash
# Cleanup incomplete booking first
php qparkin_backend/cleanup_simple.php 2

# Restart backend (optional if using php artisan serve)
# Ctrl+C to stop, then:
# php artisan serve
```

Then create booking from mobile app - payment page should now work!

## Expected Flow

1. User creates booking → Success (id_booking: 30)
2. App navigates to payment page
3. App calls POST `/api/bookings/30/payment/snap-token`
4. Backend returns snap_token
5. WebView opens Midtrans payment page

## Status

✅ **FIXED** - HTTP method mismatch resolved
