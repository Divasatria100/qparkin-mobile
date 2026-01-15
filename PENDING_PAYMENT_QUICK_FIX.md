# Pending Payment - Quick Fix

## ⚡ Solusi Cepat untuk Migration Error

Migration error terjadi karena Laravel cache issue. Gunakan SQL manual untuk fix.

## 🚀 Langkah Cepat (5 menit)

### 1. Buka MySQL/phpMyAdmin

### 2. Jalankan SQL ini:

```sql
-- Add pending_payment status
ALTER TABLE booking 
MODIFY COLUMN status ENUM('aktif', 'selesai', 'expired', 'pending_payment') 
DEFAULT 'aktif';

-- Mark migration as complete
INSERT INTO migrations (migration, batch) 
VALUES ('2025_01_15_000001_add_pending_payment_status_to_booking', 5);
```

### 3. Verifikasi

```bash
cd qparkin_backend
php artisan migrate:status
```

Harus muncul:
```
2025_01_15_000001_add_pending_payment_status_to_booking ........... [5] Ran
```

### 4. Test API

```bash
# Windows
test-pending-payment.bat

# Manual
curl -X GET http://localhost:8000/api/booking/pending-payments ^
  -H "Authorization: Bearer YOUR_TOKEN"
```

## ✅ Selesai!

Fitur pending payment sudah aktif. Tidak perlu restart server.

## 📱 Test di Flutter

```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

1. Buat booking
2. Exit dari Midtrans page
3. Buka Activity page
4. Pending payment card harus muncul

## 🔧 Troubleshooting

**Q: SQL error "Duplicate entry"?**  
A: Migration sudah jalan. Skip step 2 (INSERT INTO migrations).

**Q: Pending payment tidak muncul?**  
A: Pastikan booking dibuat dengan status 'pending_payment' (bukan 'aktif').

**Q: API 404?**  
A: Restart Laravel server: `php artisan serve`

## 📚 Dokumentasi Lengkap

- `PENDING_PAYMENT_IMPLEMENTATION_COMPLETE.md` - Full documentation
- `PENDING_PAYMENT_MIGRATION_FIX.md` - Migration troubleshooting
- `PENDING_PAYMENT_QUICK_REFERENCE.md` - API reference

---

**Status:** ✅ READY TO USE  
**Time:** 5 minutes  
**Difficulty:** Easy
