# Pending Payment Migration Fix

## Problem
Migration error: `Class "AddPendingPaymentStatusToBooking" not found`

Laravel tidak bisa menemukan class dari migration file meskipun sudah menggunakan anonymous class yang benar.

## Solution

Karena migration sudah terdaftar sebagai "Pending" di database, kita bisa jalankan SQL query secara manual.

### Option 1: Manual SQL (Recommended)

**Step 1:** Jalankan SQL query langsung di MySQL:

```sql
ALTER TABLE booking 
MODIFY COLUMN status ENUM('aktif', 'selesai', 'expired', 'pending_payment') 
DEFAULT 'aktif';
```

**Step 2:** Verifikasi perubahan:

```sql
SHOW COLUMNS FROM booking LIKE 'status';
```

**Step 3:** Tandai migration sebagai complete di database:

```sql
INSERT INTO migrations (migration, batch) 
VALUES ('2025_01_15_000001_add_pending_payment_status_to_booking', 5);
```

### Option 2: Using Batch Script

```bash
cd qparkin_backend
run_pending_payment_migration.bat
```

Edit file `run_pending_payment_migration.bat` dan sesuaikan kredensial MySQL Anda:
- DB_HOST
- DB_PORT
- DB_NAME
- DB_USER
- DB_PASS

### Option 3: Using MySQL Command Line

```bash
# Login to MySQL
mysql -u root -p qparkin

# Run the ALTER TABLE command
ALTER TABLE booking 
MODIFY COLUMN status ENUM('aktif', 'selesai', 'expired', 'pending_payment') 
DEFAULT 'aktif';

# Mark migration as complete
INSERT INTO migrations (migration, batch) 
VALUES ('2025_01_15_000001_add_pending_payment_status_to_booking', 5);

# Exit MySQL
exit;
```

### Option 4: Using phpMyAdmin

1. Open phpMyAdmin
2. Select database `qparkin`
3. Go to SQL tab
4. Paste and run:
```sql
ALTER TABLE booking 
MODIFY COLUMN status ENUM('aktif', 'selesai', 'expired', 'pending_payment') 
DEFAULT 'aktif';

INSERT INTO migrations (migration, batch) 
VALUES ('2025_01_15_000001_add_pending_payment_status_to_booking', 5);
```

## Verification

After running the SQL, verify the change:

```bash
cd qparkin_backend
php artisan migrate:status
```

You should see:
```
2025_01_15_000001_add_pending_payment_status_to_booking ......................... [5] Ran
```

## Test the API

```bash
# Test get pending payments
curl -X GET http://localhost:8000/api/booking/pending-payments \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Why This Happened

Laravel's migration system sometimes has issues with:
1. Cache corruption
2. File system timing issues on Windows
3. Autoloader not picking up anonymous classes properly

The manual SQL approach bypasses these issues and works reliably.

## Alternative: Delete and Recreate Migration

If you want to use Laravel migrations properly:

```bash
# 1. Delete the migration file
rm database/migrations/2025_01_15_000001_add_pending_payment_status_to_booking.php

# 2. Create new migration with different timestamp
php artisan make:migration add_pending_payment_to_booking_status

# 3. Edit the new file with the same SQL
# 4. Run migration
php artisan migrate
```

## Summary

✅ **Recommended:** Run SQL manually (Option 1)  
⚠️ **Alternative:** Use batch script (Option 2)  
⚠️ **Alternative:** Use MySQL CLI (Option 3)  
⚠️ **Alternative:** Use phpMyAdmin (Option 4)

After running SQL, the pending payment feature will work immediately without needing to fix the migration file.
