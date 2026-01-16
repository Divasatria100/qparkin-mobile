# Admin Mall Registration - Quick Reference

## 🎯 Field Mapping (PENTING!)

### ❌ SALAH (Sebelum Fix)
```php
'mall_name' => $validated['mall_name'],           // Field tidak ada
'mall_location' => $validated['location'],        // Field tidak ada
'mall_latitude' => $validated['latitude'],        // Field tidak ada
'mall_longitude' => $validated['longitude'],      // Field tidak ada
'mall_photo' => $photoPath,                       // Field tidak ada
'role' => 'admin',                                // Role tidak valid
'status' => 'pending',                            // Status salah
```

### ✅ BENAR (Setelah Fix)
```php
'requested_mall_name' => $validated['mall_name'],
'requested_mall_location' => $validated['location'],
'application_notes' => json_encode([
    'latitude' => $validated['latitude'],
    'longitude' => $validated['longitude'],
    'photo_path' => $photoPath,
]),
'role' => 'customer',                             // Akan diubah saat approved
'status' => 'aktif',                              // Status user
'application_status' => 'pending',                // Status pengajuan
'applied_at' => now(),
```

---

## 🔍 Query Mapping

### ❌ SALAH
```php
User::where('status', 'pending')->get();
```

### ✅ BENAR
```php
User::where('application_status', 'pending')
    ->whereNotNull('applied_at')
    ->orderBy('applied_at', 'desc')
    ->get();
```

---

## 📊 View Field Mapping

### ❌ SALAH
```blade
{{ $request->mall_name }}
{{ $request->location }}
{{ $request->status }}
{{ $request->created_at }}
```

### ✅ BENAR
```blade
{{ $request->requested_mall_name }}
{{ $request->requested_mall_location }}
{{ $request->application_status }}
{{ $request->applied_at }}
```

---

## 🗂️ Database Schema

### Tabel: `user`

**Field untuk Admin Mall Registration:**
```sql
application_status      ENUM('pending', 'approved', 'rejected')
requested_mall_name     VARCHAR(255)
requested_mall_location VARCHAR(255)
application_notes       TEXT (JSON format)
applied_at             TIMESTAMP
reviewed_at            TIMESTAMP
reviewed_by            BIGINT (FK ke user.id_user)
```

**Field yang TIDAK ADA:**
- ❌ `mall_name`
- ❌ `mall_location`
- ❌ `mall_latitude`
- ❌ `mall_longitude`
- ❌ `mall_photo`

---

## 🔄 Application Flow

### 1. Registration (Customer)
```
User submits form
↓
Controller saves:
- role = 'customer'
- status = 'aktif'
- application_status = 'pending'
- requested_mall_name
- requested_mall_location
- application_notes (JSON)
- applied_at = now()
```

### 2. Pending (Waiting Review)
```
SuperAdmin views:
- Query: application_status = 'pending'
- Display: requested_mall_name, requested_mall_location
- Actions: Approve / Reject
```

### 3. Approved (Becomes Admin Mall)
```
SuperAdmin clicks Approve
↓
System:
1. Parse application_notes (get coordinates & photo)
2. Create Mall (with coordinates)
3. Update User:
   - role = 'admin_mall'
   - status = 'aktif'
   - application_status = 'approved'
   - reviewed_at = now()
4. Create AdminMall entry (link user to mall)
```

### 4. Rejected
```
SuperAdmin clicks Reject
↓
System:
- application_status = 'rejected'
- reviewed_at = now()
```

---

## 🧪 Quick Test Commands

### Check Pending Applications
```bash
cd qparkin_backend
php artisan tinker
>>> User::where('application_status', 'pending')->count();
>>> User::where('application_status', 'pending')->get(['name', 'requested_mall_name', 'applied_at']);
```

### Check Database
```sql
SELECT id_user, name, email, application_status, requested_mall_name, applied_at
FROM user
WHERE application_status = 'pending';
```

### Clear Cache
```bash
php artisan view:clear
php artisan cache:clear
php artisan config:clear
```

---

## 📝 Common Issues & Solutions

### Issue 1: Data tidak muncul di halaman pengajuan
**Cause:** Query menggunakan `status` bukan `application_status`
**Solution:** Ganti query ke `application_status = 'pending'`

### Issue 2: Field tidak tersimpan
**Cause:** Menggunakan field yang tidak ada (`mall_name`, dll)
**Solution:** Gunakan `requested_mall_name`, `requested_mall_location`, `application_notes`

### Issue 3: Counter sidebar menunjukkan 0
**Cause:** Query counter menggunakan `status = 'pending'`
**Solution:** Ganti ke `application_status = 'pending'`

### Issue 4: Koordinat hilang saat approve
**Cause:** Tidak parse `application_notes`
**Solution:** Parse JSON dari `application_notes` untuk mendapatkan koordinat

---

## 🎨 Status Badge Colors

```css
.status-badge.pending   { background: #FEF3C7; color: #92400E; }
.status-badge.approved  { background: #D1FAE5; color: #065F46; }
.status-badge.rejected  { background: #FEE2E2; color: #991B1B; }
```

---

## 📂 Files Modified

1. `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`
2. `qparkin_backend/app/Http/Controllers/SuperAdminController.php`
3. `qparkin_backend/resources/views/superadmin/pengajuan.blade.php`
4. `qparkin_backend/resources/views/partials/superadmin/sidebar.blade.php`

---

## 🚀 Testing URLs

- Registration: `http://localhost:8000/signup`
- Pengajuan List: `http://localhost:8000/superadmin/pengajuan`
- Dashboard: `http://localhost:8000/superadmin/dashboard`

---

## 📞 Support

Jika masih ada masalah:
1. Cek log: `storage/logs/laravel.log`
2. Jalankan: `test-admin-mall-registration.bat`
3. Cek SQL: `test_admin_mall_registration.sql`
4. Baca: `ADMIN_MALL_REGISTRATION_FIX_COMPLETE.md`

---

**Last Updated:** 8 Januari 2025
**Status:** ✅ FIXED & TESTED
