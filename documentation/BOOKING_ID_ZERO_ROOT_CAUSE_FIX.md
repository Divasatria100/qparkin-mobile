# Booking ID Zero - Root Cause Fix

## Problem Summary

Booking berhasil dibuat di database, tapi mobile app menerima `id_booking: 0` dan `id_transaksi: 0`, menyebabkan payment URL menjadi `/api/bookings/0/payment/snap-token` (404 Not Found).

## Root Cause Analysis

### Issue #1: Laravel Model Primary Key Behavior

**File**: `qparkin_backend/app/Models/Booking.php`

```php
protected $primaryKey = 'id_transaksi';  // ← Custom primary key
```

**Problem**: 
- Primary key `id_transaksi` adalah **foreign key** ke tabel `transaksi_parkir`
- Nilai di-set **manual** saat create: `'id_transaksi' => $transaksi->id_transaksi`
- Laravel **tidak auto-reload** model setelah `create()` jika primary key di-set manual
- Akibatnya `$booking->id_transaksi` tetap `null` atau `0` setelah create

### Issue #2: Variable Name Conflict

**File**: `qparkin_backend/app/Http/Controllers/Api/BookingController.php`

```php
$transaksi = TransaksiParkir::create([...]); // ← Variable $transaksi

// ... later ...

$transaksi = $booking->transaksiParkir;  // ← Overwrite variable!
```

**Problem**: Variable `$transaksi` di-overwrite, menyebabkan kehilangan reference ke TransaksiParkir yang baru dibuat.

## Solution Implemented

### Fix #1: Reload Booking After Commit

```php
DB::commit();

// IMPORTANT: Reload booking to get actual saved values
$booking = Booking::where('id_transaksi', $transaksi->id_transaksi)->first();

if (!$booking) {
    Log::error('[BookingService] Booking created but not found after commit');
    return response()->json([...], 500);
}

$bookingId = $transaksi->id_transaksi; // Use transaksi ID directly
```

**Why this works**:
- Query database untuk mendapatkan booking yang baru disimpan
- Memastikan semua field ter-load dengan benar
- Menggunakan `$transaksi->id_transaksi` langsung (guaranteed to have value)

### Fix #2: Rename Variable to Avoid Conflict

```php
$transaksi = TransaksiParkir::create([...]); // Original transaksi

// ... later ...

$transaksiData = $booking->transaksiParkir;  // ← Renamed!
$parkiran = $transaksiData ? $transaksiData->parkiran : null;
```

**Why this works**:
- Menghindari overwrite variable `$transaksi`
- Menjaga reference ke TransaksiParkir yang baru dibuat
- Lebih jelas dan mudah di-maintain

### Fix #3: Mobile App Fallback

**File**: `qparkin_app/lib/data/models/booking_model.dart`

```dart
factory BookingModel.fromJson(Map<String, dynamic> json) {
  // Handle id_booking with fallback to id_transaksi
  final idBookingValue = json['id_booking'] ?? json['id_transaksi'];
  final idTransaksiValue = json['id_transaksi'];
  
  return BookingModel(
    idTransaksi: idTransaksiValue?.toString() ?? '',
    idBooking: idBookingValue?.toString() ?? idTransaksiValue?.toString() ?? '',
    // ...
  );
}
```

**Why this works**:
- Jika `id_booking` null/missing, gunakan `id_transaksi` sebagai fallback
- Double safety: mobile app tetap bisa handle response yang tidak sempurna
- Defensive programming untuk mencegah masalah serupa di masa depan

## Testing

### 1. Test Backend Response

```bash
php qparkin_backend/test_booking_response.php
```

Expected output:
```
✅ No active transactions
✅ Booking has valid ID
✅ TransaksiParkir relationship loaded
✅ Slot relationship loaded
```

### 2. Clean Up Incomplete Transactions

```bash
php qparkin_backend/cleanup_simple.php 2
```

### 3. Restart Backend

```bash
cd qparkin_backend
php artisan config:clear
php artisan cache:clear
php artisan serve
```

### 4. Test from Mobile App

```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

### 5. Check Logs

Look for these log entries:

**Backend (Terminal)**:
```
[BookingService] Booking committed
  booking_id_transaksi: 27
  transaksi_id: 27
  booking_exists: true

[BookingService] Booking created successfully
  id_transaksi: 27
  id_booking: 27
  response_data: {...}
```

**Mobile App (Flutter Console)**:
```
[BookingService] id_booking value: 27
[BookingService] id_transaksi value: 27
[BookingResponse] Parsed booking - idBooking: 27, idTransaksi: 27
[BookingProvider] Booking created successfully: 27
[MidtransPayment] Requesting snap token for booking: 27
```

## Prevention Strategy

### 1. Always Use Explicit Queries for Custom Primary Keys

```php
// ❌ BAD: Relying on model property after create
$booking = Booking::create([...]);
$id = $booking->id_transaksi; // May be null!

// ✅ GOOD: Query database explicitly
$booking = Booking::create([...]);
$booking = Booking::where('id_transaksi', $transaksi->id_transaksi)->first();
$id = $booking->id_transaksi; // Guaranteed to have value
```

### 2. Use Descriptive Variable Names

```php
// ❌ BAD: Reusing variable names
$transaksi = TransaksiParkir::create([...]);
$transaksi = $booking->transaksiParkir; // Overwrites!

// ✅ GOOD: Different names for different purposes
$transaksi = TransaksiParkir::create([...]);
$transaksiData = $booking->transaksiParkir;
```

### 3. Add Comprehensive Logging

```php
Log::info('[BookingService] Booking committed', [
    'booking_id_transaksi' => $bookingId,
    'transaksi_id' => $transaksi->id_transaksi,
    'booking_exists' => $booking !== null
]);
```

### 4. Implement Fallback in Mobile App

Always have fallback logic for critical fields:

```dart
idBooking: json['id_booking']?.toString() ?? 
           json['id_transaksi']?.toString() ?? 
           '';
```

## Files Modified

### Backend
- `qparkin_backend/app/Http/Controllers/Api/BookingController.php`
  - Added booking reload after commit
  - Renamed variable to avoid conflict
  - Enhanced logging

### Mobile App
- `qparkin_app/lib/data/models/booking_model.dart`
  - Added fallback logic for id_booking
- `qparkin_app/lib/data/services/booking_service.dart`
  - Added debug logging for response structure
- `qparkin_app/lib/data/models/booking_response.dart`
  - Added parsing verification logging

### Testing
- `qparkin_backend/test_booking_response.php` (NEW)
  - Comprehensive backend testing script

## Related Issues

This fix resolves:
- Issue #12: `id_booking` parsed as 0
- Issue #11: Booking refresh error
- Issue #10: Null pointer error
- Issue #9: Active transaction conflict

## Success Criteria

✅ Backend logs show correct ID values (> 0)
✅ Mobile app logs show correct ID values (> 0)
✅ Payment URL is correct: `/api/bookings/27/payment/snap-token`
✅ Midtrans payment page loads successfully
✅ No more "route not found" errors

## Conclusion

Masalah ini disebabkan oleh kombinasi dari:
1. Laravel model behavior dengan custom primary key
2. Variable naming yang tidak hati-hati
3. Kurangnya defensive programming di mobile app

Solusi yang diimplementasikan mengatasi semua aspek ini dengan:
1. Explicit database query setelah commit
2. Variable naming yang lebih jelas
3. Fallback logic di mobile app
4. Comprehensive logging untuk debugging

**Lesson Learned**: Ketika menggunakan custom primary key yang bukan auto-increment, selalu query ulang dari database setelah create untuk memastikan semua field ter-load dengan benar.
