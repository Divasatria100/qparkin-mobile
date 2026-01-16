# Quick Fix: Booking ID Zero Error

## Problem
Booking berhasil dibuat tapi payment page error dengan URL `/api/bookings/0/payment/snap-token`

## Quick Solution

### Step 1: Clean Up Incomplete Transaction
```bash
php qparkin_backend/cleanup_simple.php 2
```

Expected output:
```
✓ Booking deleted
✓ Slot released
✓ Transaction deleted
```

### Step 2: Restart Backend
```bash
restart-backend-clean.bat
```

Atau manual:
```bash
php qparkin_backend/artisan config:clear
php qparkin_backend/artisan cache:clear
php qparkin_backend/artisan serve
```

### Step 3: Restart Flutter App
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.0.101:8000
```

### Step 4: Test Booking
1. Buka app
2. Pilih mall
3. Pilih kendaraan
4. Pilih durasi
5. Klik "Konfirmasi Booking"

### Step 5: Verify Logs

**Backend Terminal** - Harus muncul:
```
[BookingService] Booking committed
  booking_id_transaksi: 28
  transaksi_id: 28
  booking_exists: true

[BookingService] Booking created successfully
  id_transaksi: 28
  id_booking: 28
```

**Flutter Console** - Harus muncul:
```
[BookingService] id_booking value: 28
[BookingService] id_transaksi value: 28
[BookingResponse] Parsed booking - idBooking: 28, idTransaksi: 28
[BookingProvider] Booking created successfully: 28
[MidtransPayment] Requesting snap token for booking: 28
```

## Success Indicators

✅ Backend logs menunjukkan ID > 0
✅ Mobile app logs menunjukkan ID > 0
✅ Payment URL benar: `/api/bookings/28/payment/snap-token`
✅ Midtrans payment page terbuka
✅ Tidak ada error "route not found"

## If Still Error

### Check 1: Backend Response
```bash
php qparkin_backend/test_booking_response.php
```

Harus menunjukkan:
```
✅ No active transactions
✅ Booking has valid ID
✅ TransaksiParkir relationship loaded
```

### Check 2: Database
```bash
php qparkin_backend/check_active_simple.php 2
```

Harus menunjukkan:
```
No active transactions found
```

### Check 3: Backend Code
Pastikan file `qparkin_backend/app/Http/Controllers/Api/BookingController.php` sudah ter-update dengan fix terbaru.

## Prevention

Untuk mencegah masalah ini terulang:

1. **Selalu cleanup sebelum test ulang**
   ```bash
   php qparkin_backend/cleanup_simple.php 2
   ```

2. **Restart backend setelah code changes**
   ```bash
   restart-backend-clean.bat
   ```

3. **Check logs untuk verify**
   - Backend: `[BookingService] Booking created successfully`
   - Mobile: `[BookingProvider] Booking created successfully: <ID>`

## Root Cause

Masalah ini disebabkan oleh:
1. Laravel model dengan custom primary key tidak auto-reload setelah create
2. Variable naming conflict di backend
3. Kurangnya fallback logic di mobile app

**Sudah diperbaiki di**:
- Backend: Reload booking setelah commit
- Mobile: Fallback ke id_transaksi jika id_booking null
- Logging: Comprehensive debug logs

## Related Files

- `qparkin_backend/app/Http/Controllers/Api/BookingController.php` - Backend fix
- `qparkin_app/lib/data/models/booking_model.dart` - Mobile fallback
- `BOOKING_ID_ZERO_ROOT_CAUSE_FIX.md` - Detailed explanation

## Support

Jika masih error setelah mengikuti semua step:
1. Check `BOOKING_ID_ZERO_ROOT_CAUSE_FIX.md` untuk penjelasan detail
2. Verify semua file sudah ter-update
3. Check database schema dengan `php qparkin_backend/test_booking_response.php`
