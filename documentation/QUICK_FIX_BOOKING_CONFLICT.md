# Quick Fix: Booking Conflict Error

## Error Message
```
SQLSTATE[45000]: Kendaraan ini masih memiliki transaksi aktif
```

## Quick Solution (3 Steps)

### Step 1: Check Status
```bash
php qparkin_backend/check_active_simple.php 2
```
*(Ganti `2` dengan Vehicle ID Anda)*

### Step 2: Cleanup
```bash
php qparkin_backend/cleanup_simple.php 2
```

### Step 3: Verify
```bash
php qparkin_backend/check_active_simple.php 2
```

Should show: ✓ No active transactions found

## Done!
Sekarang Anda bisa membuat booking baru dari mobile app.

---

## Troubleshooting

### How to find Vehicle ID?
Check error log atau dari database:
```sql
SELECT id_kendaraan, plat_nomor FROM kendaraan WHERE id_user = YOUR_USER_ID;
```

### Still getting error?
1. Restart backend server:
```bash
cd qparkin_backend
php artisan serve
```

2. Restart mobile app

3. Try booking again

---

## Prevention
Jika payment page error, jangan coba booking lagi sebelum cleanup.

## Need Help?
See: `BOOKING_ACTIVE_TRANSACTION_CONFLICT_FIX.md` for detailed explanation
