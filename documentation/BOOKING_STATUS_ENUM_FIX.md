# Booking Status ENUM Fix

## Issue
After fixing timestamps, booking fails with:
```
Data truncated for column 'status' at row 1
```

## Root Cause Analysis

### Database Schema
The `booking` table's `status` column is defined as ENUM with only these values:
- `'aktif'` (default)
- `'selesai'`
- `'expired'`

### Code Problem
The `BookingController` was trying to insert `'confirmed'` and query for `'confirmed'` and `'active'`, which are **NOT** valid ENUM values for the `booking` table.

**Note**: The `slot_reservations` table has different ENUM values (`'active'`, `'confirmed'`, `'expired'`, `'cancelled'`), which caused confusion.

## Solution Applied

### File: `qparkin_backend/app/Http/Controllers/Api/BookingController.php`

#### Fix 1: Booking Creation (Line ~135)
**Before**:
```php
$booking = Booking::create([
    'id_transaksi' => $transaksi->id_transaksi,
    'id_slot' => $idSlot,
    'reservation_id' => $reservationId,
    'waktu_mulai' => $waktuMulai,
    'waktu_selesai' => $waktuSelesai,
    'durasi_booking' => $request->durasi_booking,
    'status' => 'confirmed', // ❌ INVALID
    'dibooking_pada' => Carbon::now()
]);
```

**After**:
```php
$booking = Booking::create([
    'id_transaksi' => $transaksi->id_transaksi,
    'id_slot' => $idSlot,
    'reservation_id' => $reservationId,
    'waktu_mulai' => $waktuMulai,
    'waktu_selesai' => $waktuSelesai,
    'durasi_booking' => $request->durasi_booking,
    'status' => 'aktif', // ✅ VALID - matches ENUM
    'dibooking_pada' => Carbon::now()
]);
```

#### Fix 2: Get Active Bookings Query (Line ~243)
**Before**:
```php
->whereIn('status', ['confirmed', 'active']) // ❌ INVALID values
```

**After**:
```php
->whereIn('status', ['aktif']) // ✅ VALID - matches ENUM
```

## ENUM Values Comparison

### `booking` table (Indonesian)
- ✅ `'aktif'` - Active booking
- ✅ `'selesai'` - Completed booking
- ✅ `'expired'` - Expired booking

### `slot_reservations` table (English)
- ✅ `'active'` - Active reservation
- ✅ `'confirmed'` - Confirmed reservation
- ✅ `'expired'` - Expired reservation
- ✅ `'cancelled'` - Cancelled reservation

**Important**: These are **different tables** with **different ENUM values**!

## Testing

### 1. Verify ENUM Values
```bash
php qparkin_backend/check_booking_status_enum.php
```

Expected output:
```
Valid ENUM values:
  - 'aktif'
  - 'selesai'
  - 'expired'
```

### 2. Restart Backend
```bash
cd qparkin_backend
php artisan config:clear
php artisan cache:clear
php artisan serve
```

### 3. Test Booking
Try creating a booking from mobile app. Should now succeed!

### Expected Result
✅ Booking created with status 'aktif'
✅ Returns 201 with booking data
✅ No more "Data truncated" error

## Complete Fix Chain

This completes the **6th fix** in the booking flow:

1. ✅ **id_parkiran not found** - Added to MallModel
2. ✅ **jenis_kendaraan null** - Changed to use `jenis` field
3. ✅ **reserved_from/reserved_until missing** - Changed to `reserved_at`/`expires_at`
4. ✅ **id_kendaraan and id_floor missing** - Added to slot reservation creation
5. ✅ **updated_at column not found** - Disabled timestamps in Booking model
6. ✅ **Data truncated for status** - Changed 'confirmed' to 'aktif' (this fix)

## Files Modified
1. `qparkin_backend/app/Http/Controllers/Api/BookingController.php`
   - Line ~135: Changed status from 'confirmed' to 'aktif'
   - Line ~243: Changed whereIn status from ['confirmed', 'active'] to ['aktif']

## Files Created
1. `qparkin_backend/check_booking_status_enum.php` - Diagnostic script
2. `BOOKING_STATUS_ENUM_FIX.md` - This documentation

## Status
✅ **FIXED** - Ready to test

## Notes for Future Development

If you need to add more status values to the `booking` table, you must:

1. **Create a migration** to alter the ENUM:
```php
Schema::table('booking', function (Blueprint $table) {
    $table->enum('status', ['aktif', 'selesai', 'expired', 'dibatalkan'])
          ->default('aktif')
          ->change();
});
```

2. **Run the migration**:
```bash
php artisan migrate
```

3. **Update the code** to use the new values

**Do NOT** just change the code without updating the database schema!
