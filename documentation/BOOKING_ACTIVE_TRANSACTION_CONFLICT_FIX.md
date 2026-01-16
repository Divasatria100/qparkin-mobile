# Booking Active Transaction Conflict - Fix Guide

## Problem
Error saat membuat booking baru:
```
SQLSTATE[45000]: <<Unknown error>>: 1644 Kendaraan ini masih memiliki transaksi aktif
```

**Root Cause**: Database trigger mencegah pembuatan transaksi baru jika kendaraan masih memiliki transaksi aktif. Ini terjadi karena:
1. Booking sebelumnya berhasil dibuat
2. Payment page error (missing `id_booking`)
3. Transaksi tidak selesai/dibatalkan
4. Kendaraan masih terkunci dengan transaksi aktif

## Database Trigger
Database memiliki trigger yang memeriksa transaksi aktif sebelum insert:
```sql
CREATE TRIGGER before_transaksi_insert
BEFORE INSERT ON transaksi_parkir
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM transaksi_parkir 
        WHERE id_kendaraan = NEW.id_kendaraan 
        AND status IN ('booked', 'active')
        AND waktu_keluar IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Kendaraan ini masih memiliki transaksi aktif';
    END IF;
END;
```

## Solution

### Quick Fix (Recommended)
Gunakan script cleanup sederhana yang langsung menghapus transaksi:

```bash
php qparkin_backend/cleanup_simple.php 2
```

Ganti `2` dengan Vehicle ID yang bermasalah.

### Option 1: Check Active Bookings
Lihat semua transaksi aktif di sistem:

```bash
check-active-bookings.bat
```

Atau manual:
```bash
cd qparkin_backend
php check_active_transactions.php
```

Output akan menampilkan:
- Transaction ID
- User & Vehicle info
- Slot assignment
- Status (transaksi & booking)
- Timing information
- Warning jika booking sudah expired

### Option 2: Cleanup Incomplete Booking (Simple Method)
Bersihkan transaksi dengan menghapus data:

```bash
cd qparkin_backend
php cleanup_simple.php 2
```

Script akan:
1. ✅ Delete booking record
2. ✅ Release parking slot
3. ✅ Delete transaction record

### Option 3: Check Active Bookings
Bersihkan transaksi yang tidak selesai untuk kendaraan tertentu:

```bash
cleanup-booking.bat
```

Kemudian masukkan Vehicle ID (contoh: 2)

Atau manual:
```bash
cd qparkin_backend
php cleanup_incomplete_booking.php 2
```

Script akan:
1. ✅ Find active transactions for the vehicle
2. ✅ Cancel related booking
3. ✅ Cancel slot reservation
4. ✅ Release parking slot (mark as available)
5. ✅ Cancel transaction (set status to 'cancelled')

### Option 3: Manual Database Cleanup (Advanced)
Jika script tidak bekerja, gunakan SQL manual:

```sql
-- 1. Check active transactions
SELECT 
    t.id_transaksi,
    t.id_kendaraan,
    k.plat_nomor,
    t.status,
    t.waktu_masuk,
    b.status as booking_status
FROM transaksi_parkir t
LEFT JOIN booking b ON t.id_transaksi = b.id_transaksi
LEFT JOIN kendaraan k ON t.id_kendaraan = k.id_kendaraan
WHERE t.id_kendaraan = 2 
AND t.status IN ('booked', 'active')
AND t.waktu_keluar IS NULL;

-- 2. Cancel booking
UPDATE booking 
SET status = 'cancelled' 
WHERE id_transaksi IN (
    SELECT id_transaksi FROM transaksi_parkir 
    WHERE id_kendaraan = 2 AND status IN ('booked', 'active')
);

-- 3. Release slot
UPDATE parking_slots 
SET status = 'available' 
WHERE id_slot IN (
    SELECT id_slot FROM transaksi_parkir 
    WHERE id_kendaraan = 2 AND status IN ('booked', 'active')
);

-- 4. Cancel transaction
UPDATE transaksi_parkir 
SET status = 'cancelled', waktu_keluar = NOW() 
WHERE id_kendaraan = 2 
AND status IN ('booked', 'active')
AND waktu_keluar IS NULL;
```

## Prevention - Better Error Handling

### Backend: Catch Trigger Error
Update `BookingController.php` to handle this specific error:

```php
try {
    $transaksi = TransaksiParkir::create([...]);
} catch (\Illuminate\Database\QueryException $e) {
    if (str_contains($e->getMessage(), 'transaksi aktif')) {
        DB::rollBack();
        return response()->json([
            'success' => false,
            'message' => 'ACTIVE_BOOKING_EXISTS',
            'error' => 'Kendaraan ini masih memiliki booking aktif. Selesaikan booking sebelumnya terlebih dahulu.'
        ], 409);
    }
    throw $e;
}
```

### Mobile App: Better Conflict Handling
Update `BookingService` to recognize this error:

```dart
if (response.statusCode == 409 || 
    data['message']?.toString().contains('ACTIVE_BOOKING_EXISTS') == true) {
  return BookingResponse.error(
    message: 'Anda masih memiliki booking aktif. Selesaikan booking sebelumnya terlebih dahulu.',
    errorCode: 'ACTIVE_BOOKING_EXISTS',
  );
}
```

## Testing After Cleanup

### 1. Verify Cleanup
```bash
check-active-bookings.bat
```
Should show: "✓ No active transactions found"

### 2. Test New Booking
Restart mobile app and try booking again:
```
1. Select mall
2. Select vehicle (ID 2)
3. Select time & duration
4. Confirm booking
```

Should succeed without "transaksi aktif" error.

### 3. Verify Payment Flow
After successful booking:
```
1. Should navigate to Midtrans payment page
2. URL should be: /api/bookings/123/payment/snap-token (no double slash)
3. Payment page should load correctly
```

## Files Created
- `qparkin_backend/cleanup_simple.php` - **Simple cleanup (RECOMMENDED)**
- `qparkin_backend/check_active_simple.php` - Simple status checker
- `qparkin_backend/cleanup_incomplete_booking.php` - Complex cleanup (has issues with triggers)
- `qparkin_backend/check_active_transactions.php` - Complex checker
- `cleanup-booking.bat` - Windows cleanup wrapper
- `check-active-bookings.bat` - Windows checker wrapper
- `BOOKING_ACTIVE_TRANSACTION_CONFLICT_FIX.md` - This documentation

## Common Scenarios

### Scenario 1: Payment Failed
**Symptom**: Booking created but payment page error
**Solution**: Run cleanup script for that vehicle

### Scenario 2: App Crashed During Booking
**Symptom**: Transaction stuck in 'booked' status
**Solution**: Run cleanup script

### Scenario 3: Multiple Failed Attempts
**Symptom**: Multiple incomplete transactions
**Solution**: Check active bookings, cleanup each vehicle

### Scenario 4: Expired Booking Not Cleaned
**Symptom**: Booking time passed but still active
**Solution**: Implement auto-cleanup cron job (future enhancement)

## Future Enhancements

### 1. Auto-Cleanup Expired Bookings
Create Laravel command:
```php
php artisan booking:cleanup-expired
```

Schedule in `Kernel.php`:
```php
$schedule->command('booking:cleanup-expired')->hourly();
```

### 2. Better Transaction Management
- Add transaction timeout (e.g., 15 minutes)
- Auto-cancel if payment not completed
- Send notification to user

### 3. Admin Dashboard
- Show all active bookings
- Manual cleanup button
- Transaction history

## Quick Reference

| Command | Purpose |
|---------|---------|
| `php qparkin_backend/cleanup_simple.php 2` | **Clean vehicle ID 2 (RECOMMENDED)** |
| `php qparkin_backend/check_active_simple.php 2` | Check vehicle ID 2 status |
| `check-active-bookings.bat` | View all active transactions |
| `cleanup-booking.bat` | Interactive cleanup (uses complex script) |

## Status
✅ **FIXED** - Scripts created to handle active transaction conflicts
⏳ **PENDING** - Test cleanup and retry booking
⏳ **PENDING** - Implement better error handling in backend/mobile

## Related Issues
- Issue #8: Missing `id_booking` field → Fixed in BOOKING_PAYMENT_ID_FIX.md
- Issue #9: Active transaction conflict → **This fix**
