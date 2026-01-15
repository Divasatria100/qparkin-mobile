# Quick Start - Fix Booking Payment Amount

## Problem
Booking Rp 5.000 → Midtrans menampilkan Rp 10.000 ❌

## Solution
Backend sekarang menghitung biaya dari tarif parkir ✅

## Quick Fix Steps

### 1. Add Database Column

**Option A: Using phpMyAdmin**
1. Buka phpMyAdmin
2. Pilih database `qparkin_db`
3. Pilih tabel `booking`
4. Klik tab "Structure"
5. Klik "Add column" setelah `durasi_booking`
6. Isi:
   - Name: `biaya_estimasi`
   - Type: `DECIMAL(10,2)`
   - Default: `0`
7. Klik "Save"

**Option B: Using SQL Query**
1. Buka phpMyAdmin
2. Pilih database `qparkin_db`
3. Klik tab "SQL"
4. Copy-paste query ini:

```sql
ALTER TABLE `booking` 
ADD COLUMN `biaya_estimasi` DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER `durasi_booking`;
```

5. Klik "Go"

**Option C: Using Command Line** (if MySQL is in PATH)
```bash
cd qparkin_backend
mysql -u root -p qparkin_db < add_biaya_estimasi_column.sql
```

### 2. Restart Backend

```bash
restart-backend-clean.bat
```

Or manually:
```bash
cd qparkin_backend
php artisan serve
```

### 3. Test

1. **Buat booking baru** dengan durasi 1 jam
2. **Cek log backend** - harus muncul:
   ```
   Calculated booking cost: Rp 5000 for 1 hours
   ```
3. **Lanjut ke pembayaran**
4. **Cek Midtrans** - harus menampilkan **Rp 5.000** ✅

## How It Works

### Before (❌ Wrong)
```
Frontend: Rp 5.000 (calculated)
   ↓
Backend: biaya_estimasi = 0 (not calculated)
   ↓
Midtrans: Rp 10.000 (default fallback)
```

### After (✅ Correct)
```
Frontend: Rp 5.000 (calculated)
   ↓
Backend: biaya_estimasi = 5.000 (calculated from tarif)
   ↓
Midtrans: Rp 5.000 (from biaya_estimasi)
```

## Cost Calculation

Backend menggunakan formula yang sama dengan frontend:

```
1 jam = biaya_jam_pertama
2 jam = biaya_jam_pertama + (1 × biaya_jam_berikutnya)
3 jam = biaya_jam_pertama + (2 × biaya_jam_berikutnya)
```

**Example (Motor)**:
- Jam pertama: Rp 5.000
- Jam berikutnya: Rp 3.000

| Duration | Cost |
|----------|------|
| 1 jam | Rp 5.000 |
| 2 jam | Rp 8.000 |
| 3 jam | Rp 11.000 |

## Verify Database

Check if column exists:

```sql
DESCRIBE booking;
```

Should show:
```
+------------------+--------------+------+-----+---------+-------+
| Field            | Type         | Null | Key | Default | Extra |
+------------------+--------------+------+-----+---------+-------+
| ...              | ...          | ...  | ... | ...     | ...   |
| durasi_booking   | int          | NO   |     | NULL    |       |
| biaya_estimasi   | decimal(10,2)| NO   |     | 0.00    |       | <- NEW
| status           | enum(...)    | NO   |     | aktif   |       |
| ...              | ...          | ...  | ... | ...     | ...   |
+------------------+--------------+------+-----+---------+-------+
```

## Troubleshooting

### Migration Failed
- ✅ Use SQL query directly in phpMyAdmin
- ✅ Check if column already exists: `DESCRIBE booking;`
- ✅ If column exists, skip migration

### Backend Error
- ✅ Clear cache: `php artisan config:clear`
- ✅ Restart server: `restart-backend-clean.bat`
- ✅ Check logs: `storage/logs/laravel.log`

### Still Shows Rp 10.000
- ✅ Check if tarif parkir exists for the mall
- ✅ Check backend logs for "Tarif not found" warning
- ✅ Verify vehicle type matches tarif (Motor/Mobil)

## Files Changed

1. `app/Models/Booking.php` - Added `biaya_estimasi` field
2. `app/Http/Controllers/Api/BookingController.php` - Added cost calculation
3. Database: `booking` table - Added `biaya_estimasi` column

## Next Steps

After fix is applied:
1. Test with different durations (1, 2, 3 hours)
2. Test with different vehicle types (Motor, Mobil)
3. Verify Midtrans shows correct amounts
4. Check booking history shows correct costs

## Support

If you encounter issues:
1. Check `BOOKING_PAYMENT_AMOUNT_FIX.md` for detailed documentation
2. Check backend logs: `qparkin_backend/storage/logs/laravel.log`
3. Verify tarif parkir is configured in admin panel

---

**Status**: ✅ Ready to deploy
**Impact**: High - Fixes critical payment amount mismatch
**Risk**: Low - Backward compatible (existing bookings unaffected)
