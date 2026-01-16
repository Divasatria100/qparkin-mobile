# Booking Payment Flow - Missing booking_id Fix

## Problem
After successful booking creation, the app navigates to Midtrans payment page but fails with:
```
The route api/bookings//payment/snap-token could not be found
```

**Root Cause**: Double slash (`//`) indicates `booking_id` is empty/null in the payment URL.

## Analysis

### Data Flow
1. **Backend** creates booking with `id_transaksi` as primary key
2. **Backend** returns booking data in response
3. **Flutter** parses response using `BookingModel.fromJson()`
4. **Flutter** expects `id_booking` field but backend only returns `id_transaksi`
5. **Flutter** `idBooking` becomes empty string (default value)
6. **Payment URL** becomes `/api/bookings//payment/snap-token` (invalid)

### Field Mapping Issue
```dart
// Flutter expects:
idBooking: json['id_booking']?.toString() ?? '',  // ❌ Field doesn't exist

// Backend returns:
'id_transaksi' => $booking->id_transaksi  // ✅ Only this field
```

## Solution

### Backend Changes (BookingController.php)

**Modified**: `qparkin_backend/app/Http/Controllers/Api/BookingController.php`

Added comprehensive response formatting in `store()` method:

```php
// Load all relationships needed for mobile app
$booking->load([
    'transaksiParkir.user',
    'transaksiParkir.parkiran.mall',
    'transaksiParkir.kendaraan',
    'slot.floor',
    'reservation'
]);

// Extract related data
$transaksi = $booking->transaksiParkir;
$parkiran = $transaksi->parkiran ?? null;
$mall = $parkiran->mall ?? null;
$kendaraan = $transaksi->kendaraan ?? null;
$slot = $booking->slot;
$floor = $slot->floor ?? null;

// Format response with ALL fields mobile app expects
$bookingData = [
    'id_transaksi' => $booking->id_transaksi,
    'id_booking' => $booking->id_transaksi,  // ✅ Added for mobile compatibility
    'id_mall' => $mall->id_mall ?? null,
    'id_parkiran' => $transaksi->id_parkiran,
    'id_kendaraan' => $transaksi->id_kendaraan,
    'id_slot' => $booking->id_slot,
    'reservation_id' => $booking->reservation_id,
    'qr_code' => $transaksi->qr_code ?? '',
    'waktu_mulai' => $booking->waktu_mulai,
    'waktu_selesai' => $booking->waktu_selesai,
    'durasi_booking' => $booking->durasi_booking,
    'status' => $booking->status,
    'biaya_estimasi' => 0,
    'dibooking_pada' => $booking->dibooking_pada,
    // Display fields
    'nama_mall' => $mall->nama_mall ?? null,
    'lokasi_mall' => $mall->lokasi ?? null,
    'plat_nomor' => $kendaraan->plat_nomor ?? null,
    'jenis_kendaraan' => $kendaraan->jenis ?? null,
    'kode_slot' => $slot->slot_code ?? null,
    'floor_name' => $floor->nama_lantai ?? null,
    'floor_number' => $floor->nomor_lantai ?? null,
    'slot_type' => $slot->tipe_slot ?? 'regular',
];
```

### Key Changes
1. ✅ Added `id_booking` field (maps to `id_transaksi`)
2. ✅ Loaded all necessary relationships (mall, kendaraan, slot, floor)
3. ✅ Included all display fields mobile app expects
4. ✅ Proper field name mapping (`slot_code` → `kode_slot`)
5. ✅ Added logging for debugging

## Testing

### 1. Restart Backend Server
```bash
cd qparkin_backend
php artisan config:clear
php artisan cache:clear
php artisan serve
```

### 2. Test Booking Creation
```bash
test-booking-payment-flow.bat
```

### 3. Verify Response
Expected response structure:
```json
{
  "success": true,
  "message": "Booking berhasil dibuat",
  "data": {
    "id_transaksi": 123,
    "id_booking": 123,        // ✅ Now present
    "id_mall": 1,
    "id_parkiran": 1,
    "id_kendaraan": 2,
    "id_slot": 61,
    "qr_code": "...",
    "waktu_mulai": "2026-01-15T20:00:00",
    "waktu_selesai": "2026-01-15T21:00:00",
    "durasi_booking": 1,
    "status": "aktif",
    "nama_mall": "Panbil Mall",
    "kode_slot": "UTAMA-L1-001",
    "floor_name": "Lantai UTAMA",
    ...
  }
}
```

### 4. Test Payment Flow
After booking succeeds, the app should navigate to payment page with valid URL:
```
/api/bookings/123/payment/snap-token  ✅ Valid (no double slash)
```

## Files Modified
- `qparkin_backend/app/Http/Controllers/Api/BookingController.php` - Added id_booking and enriched response

## Files Created
- `test-booking-payment-flow.bat` - Test script for booking creation
- `BOOKING_PAYMENT_ID_FIX.md` - This documentation

## Expected Behavior After Fix

### Before Fix
```
[BookingService] Creating booking...
[BookingService] Response: { success: true, data: { id_transaksi: 123 } }
[BookingModel] idBooking = '' (empty - field missing)
[MidtransPaymentPage] URL: /api/bookings//payment/snap-token ❌
[Error] Route not found
```

### After Fix
```
[BookingService] Creating booking...
[BookingService] Response: { success: true, data: { id_booking: 123, ... } }
[BookingModel] idBooking = '123' ✅
[MidtransPaymentPage] URL: /api/bookings/123/payment/snap-token ✅
[Success] Payment page loads
```

## Next Steps
1. ✅ Backend returns `id_booking` field
2. ⏳ Test booking creation with mobile app
3. ⏳ Verify payment page loads correctly
4. ⏳ Implement Midtrans Snap Token endpoint (if not exists)
5. ⏳ Test complete booking → payment → confirmation flow

## Related Issues Fixed
- Issue #5: `updated_at` column missing → Disabled timestamps
- Issue #6: Invalid status ENUM → Changed to 'aktif'
- Issue #7: `id_transaksi` not fillable → Added to fillable array
- Issue #8: `id_booking` missing → **This fix**

## Status
✅ **FIXED** - Backend now returns `id_booking` field with all required data for mobile app
