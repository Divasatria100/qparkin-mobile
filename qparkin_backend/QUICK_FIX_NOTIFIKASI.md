# Quick Fix - Notifikasi Timeout Issue

## Problem
Maximum execution time 60s saat akses `/admin/notifikasi`

## Root Cause
Table `notifikasi` belum ada di database (migration belum dijalankan)

## Solution

### 1. Run Migration
```bash
cd qparkin_backend
php artisan migrate
```

Ini akan membuat table `notifikasi` dengan struktur:
- id_notifikasi (PK)
- id_user (FK)
- judul
- pesan
- kategori (enum)
- status (enum)
- dibaca_pada
- timestamps

### 2. Verify Table Created
```bash
php artisan tinker
```

Then run:
```php
\Schema::hasTable('notifikasi')
// Should return: true
```

### 3. Test Notifikasi Page
Navigate to: `http://localhost:8000/admin/notifikasi`

Should show empty state (no notifications yet)

## Alternative: Create Sample Notifications

```bash
php artisan tinker
```

```php
$user = \App\Models\User::where('role', 'admin_mall')->first();

\App\Models\Notifikasi::create([
    'id_user' => $user->id_user,
    'judul' => 'Test Notifikasi',
    'pesan' => 'Ini adalah notifikasi test',
    'kategori' => 'system',
    'status' => 'belum'
]);
```

## What Was Fixed

1. **AdminController@notifikasi**
   - Added try-catch block
   - Check if table exists before query
   - Return empty collection if table doesn't exist

2. **Sidebar**
   - Removed badge query (causing timeout)
   - Badge will be added later after migration

3. **Migration File**
   - Created: `database/migrations/2024_01_01_000006_create_notifikasi_table.php`

## Next Steps

1. Run migration: `php artisan migrate`
2. Test notifikasi page
3. Create sample notifications for testing
4. Badge will appear automatically when there are unread notifications

## If Migration Fails

Check if you have database connection:
```bash
php artisan config:clear
php artisan cache:clear
```

Then try migration again.
