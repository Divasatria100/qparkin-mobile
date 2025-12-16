# Migration & Seeder Fix Summary

## 🐛 Masalah yang Ditemukan

### 1. Column Mismatch Error - User Table
```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'no_hp' in 'field list'
```

**Penyebab:**
- Migration menggunakan kolom `nomor_hp`
- Seeder menggunakan kolom `no_hp` (salah)

### 2. Login Username Mismatch
**Penyebab:**
- Form login web menggunakan field `name` sebagai username
- Seeder membuat user dengan `name` = "Admin Mall" (display name, bukan username)
- User tidak bisa login karena harus memasukkan "Admin Mall" sebagai username

### 3. Column Mismatch Error - Mall Table & AdminMall Table
```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'created_at' in 'field list'
```

**Penyebab:**
- Migration mall & admin_mall tidak memiliki `timestamps()` (created_at, updated_at)
- MallSeeder & AdminMallSeeder mencoba insert kolom `created_at` dan `updated_at` yang tidak ada
- Mall Model & AdminMall Model tidak disable timestamps

### 4. Dashboard View Variable Mismatch
**Penyebab:**
- Controller mengirim: `$pendapatanHarian`, `$masuk`, `$keluar`, `$aktif`, `$transaksiTerbaru`
- View mengharapkan: `$dailyRevenue`, `$ticketsIn`, `$ticketsOut`, `$currentParking`, `$recentTransactions`

---

## ✅ Perbaikan yang Dilakukan

### 1. UserSeeder.php
**Perubahan:**
- ❌ `'no_hp'` → ✅ `'nomor_hp'` (3 tempat)
- ❌ `'name' => 'Admin Mall'` → ✅ `'name' => 'adminmall'`

**Hasil:**
```php
// Super Admin
'name' => 'qparkin',           // Username untuk login
'password' => bcrypt('superadmin123'),

// Admin Mall  
'name' => 'adminmall',         // Username untuk login
'email' => 'admin@qparkin.com',
'password' => bcrypt('admin123'),

// Customer
'name' => 'berkat',            // Username untuk login
'nomor_hp' => '082284710929',
```

### 2. AdminMallSeeder.php (Baru)
**Dibuat file baru** untuk link user admin_mall dengan mall:
```php
DB::table('admin_mall')->insert([
    'id_user' => 3,
    'id_mall' => 1, // Mega Mall Batam Centre
]);
```

### 3. DatabaseSeeder.php
**Ditambahkan** AdminMallSeeder ke urutan seeding:
```php
$this->call([
    UserSeeder::class,
    SuperAdminSeeder::class,
    MallSeeder::class,
    AdminMallSeeder::class,  // ← Baru
    TarifParkirSeeder::class,
    NotifikasiSeeder::class,
]);
```

### 4. SEEDER_CREDENTIALS.md
**Diperbarui** dengan kredensial yang benar dan penjelasan lengkap.

### 5. MallSeeder.php
**Dihapus** kolom `created_at` dan `updated_at` dari insert data:
```php
// Sebelum
'created_at' => now(),
'updated_at' => now(),

// Sesudah
// Dihapus karena tabel tidak punya timestamps
```

### 6. Mall.php Model
**Ditambahkan** `public $timestamps = false;`:
```php
class Mall extends Model
{
    public $timestamps = false; // ← Baru ditambahkan
    // ...
}
```

### 7. AdminMallSeeder.php
**Dihapus** kolom `created_at` dan `updated_at`:
```php
// Sebelum
'created_at' => now(),
'updated_at' => now(),

// Sesudah
// Dihapus karena tabel tidak punya timestamps
```

### 8. AdminMall.php Model
**Ditambahkan** `public $timestamps = false;`:
```php
class AdminMall extends Model
{
    public $timestamps = false; // ← Baru ditambahkan
    // ...
}
```

### 9. admin/dashboard.blade.php
**Diperbaiki** nama variable agar sesuai dengan controller:
```php
// Sebelum
$dailyRevenue, $weeklyRevenue, $monthlyRevenue
$ticketsIn, $ticketsOut, $currentParking
$recentTransactions

// Sesudah
$pendapatanHarian, $pendapatanMingguan, $pendapatanBulanan
$masuk, $keluar, $aktif
$transaksiTerbaru
```

---

## 🚀 Cara Menjalankan

```bash
cd qparkin_backend

# Drop semua tabel dan migrate ulang dengan seeding
php artisan migrate:fresh --seed
```

---

## 🔑 Kredensial Login

### Web Login (http://localhost:8000/signin)

| Role | Username | Password |
|------|----------|----------|
| Super Admin | `qparkin` | `superadmin123` |
| Admin Mall | `adminmall` | `admin123` |

**PENTING:** Gunakan `name` (username), bukan email!

### API Login (POST /api/login)

```json
{
  "username": "adminmall",
  "password": "admin123"
}
```

---

## 📋 Struktur Data Setelah Seeding

### Tabel `user`
| id_user | name | nomor_hp | email | role | assigned_mall |
|---------|------|----------|-------|------|---------------|
| 1 | qparkin | - | - | super_admin | - |
| 2 | berkat | 082284710929 | - | customer | - |
| 3 | adminmall | 081234567890 | admin@qparkin.com | admin_mall | Mega Mall Batam Centre |

### Tabel `admin_mall`
| id_user | id_mall |
|---------|---------|
| 3 | 1 |

### Tabel `super_admin`
| id_user | hak_akses |
|---------|-----------|
| 1 | developer |

---

## ✨ Testing

Setelah migrate:fresh --seed, test login:

1. **Buka browser:** http://localhost:8000/signin
2. **Login Super Admin:**
   - Username: `qparkin`
   - Password: `superadmin123`
   - Redirect ke: `/superadmin/dashboard`

3. **Login Admin Mall:**
   - Username: `adminmall`
   - Password: `admin123`
   - Redirect ke: `/admin/dashboard`

---

## 📝 File yang Diubah

1. ✅ `database/seeders/UserSeeder.php` - Fix kolom dan username
2. ✅ `database/seeders/AdminMallSeeder.php` - File baru + hapus timestamps
3. ✅ `database/seeders/DatabaseSeeder.php` - Tambah AdminMallSeeder
4. ✅ `database/seeders/MallSeeder.php` - Hapus created_at/updated_at
5. ✅ `app/Models/Mall.php` - Tambah $timestamps = false
6. ✅ `app/Models/AdminMall.php` - Tambah $timestamps = false
7. ✅ `resources/views/admin/dashboard.blade.php` - Fix variable names
8. ✅ `SEEDER_CREDENTIALS.md` - Update dokumentasi
9. ✅ `MIGRATION_FIX_SUMMARY.md` - File ini (dokumentasi fix)
