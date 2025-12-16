# Panduan Pengujian Otomatis - Qparkin Backend

## Daftar Isi
1. [Persiapan Environment](#persiapan-environment)
2. [Struktur Test](#struktur-test)
3. [Cara Menjalankan Test](#cara-menjalankan-test)
4. [Troubleshooting](#troubleshooting)

---

## Persiapan Environment

### 1. Install Dependencies

```bash
cd qparkin_backend
composer install
```

### 2. Setup Environment Testing

Buat file `.env.testing` di root directory:

```env
APP_NAME=Qparkin
APP_ENV=testing
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=true
APP_URL=http://localhost

# Database Testing (SQLite in-memory)
DB_CONNECTION=sqlite
DB_DATABASE=:memory:

# Sanctum
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1

# Session
SESSION_DRIVER=array
QUEUE_CONNECTION=sync
```

### 3. Generate Application Key (jika belum)

```bash
php artisan key:generate
```

---

## Struktur Test

```
tests/
├── Unit/
│   └── SlotAutoAssignmentServiceTest.php    # 7 tests
├── Feature/
│   ├── BookingModelTest.php                 # 6 tests
│   ├── BookingControllerTest.php            # 10 tests
│   └── TransaksiControllerTest.php          # 5 tests
└── TestCase.php
```

### Unit Test
- **File**: `tests/Unit/SlotAutoAssignmentServiceTest.php`
- **Target**: `app/Services/SlotAutoAssignmentService.php`
- **Fokus**: Logika bisnis auto-assignment slot parkir
- **Jumlah**: 7 test cases

### Feature Test - Model
- **File**: `tests/Feature/BookingModelTest.php`
- **Target**: `app/Models/Booking.php`
- **Fokus**: CRUD operations (Create, Read, Update, Delete)
- **Jumlah**: 6 test cases

### Feature Test - Controller (Booking)
- **File**: `tests/Feature/BookingControllerTest.php`
- **Target**: `app/Http/Controllers/Api/BookingController.php`
- **Fokus**: API endpoints dengan berbagai status HTTP
- **Jumlah**: 10 test cases

### Feature Test - Controller (QR)
- **File**: `tests/Feature/TransaksiControllerTest.php`
- **Target**: `app/Http/Controllers/Api/TransaksiController.php`
- **Fokus**: Scan QR masuk/keluar
- **Jumlah**: 5 test cases

---

## Cara Menjalankan Test

### 1. Jalankan Semua Test

```bash
php artisan test
```

Output yang diharapkan:
```
   PASS  Tests\Unit\SlotAutoAssignmentServiceTest
   PASS  Tests\Feature\BookingModelTest
   PASS  Tests\Feature\BookingControllerTest
   PASS  Tests\Feature\TransaksiControllerTest

  Tests:  28 passed (2 skipped)
  Duration: XX.XXs
```

### 2. Jalankan Test Berdasarkan Suite

```bash
# Unit Test saja
php artisan test --testsuite=Unit

# Feature Test saja
php artisan test --testsuite=Feature
```

### 3. Jalankan Test File Spesifik

```bash
# Unit Test
php artisan test tests/Unit/SlotAutoAssignmentServiceTest.php

# Feature Test - Model
php artisan test tests/Feature/BookingModelTest.php

# Feature Test - Controller Booking
php artisan test tests/Feature/BookingControllerTest.php

# Feature Test - Controller QR
php artisan test tests/Feature/TransaksiControllerTest.php
```

### 4. Jalankan Test Method Spesifik

```bash
# Format: --filter=nama_method
php artisan test --filter=test_can_assign_available_slot

# Atau dengan file spesifik
php artisan test tests/Unit/SlotAutoAssignmentServiceTest.php --filter=test_can_assign_available_slot
```

### 5. Jalankan dengan Verbose Output

```bash
# Menampilkan detail setiap test
php artisan test --verbose

# Atau
php artisan test -v
```

### 6. Jalankan dengan Coverage (Opsional)

```bash
# Memerlukan Xdebug atau PCOV
php artisan test --coverage

# Dengan minimum coverage threshold
php artisan test --coverage --min=80
```

### 7. Jalankan dengan Parallel Testing (Opsional)

```bash
# Jalankan test secara parallel untuk speed up
php artisan test --parallel
```

---

## Troubleshooting

### Error: "Class 'Database\Factories\UserFactory' not found"

**Solusi**:
```bash
composer dump-autoload
```

### Error: "SQLSTATE[HY000]: General error: 1 no such table"

**Penyebab**: Database migration belum dijalankan untuk testing

**Solusi**: Test menggunakan `RefreshDatabase` trait yang otomatis menjalankan migration. Pastikan file migration ada di `database/migrations/`

### Error: "Target class [App\Services\SlotAutoAssignmentService] does not exist"

**Solusi**:
```bash
composer dump-autoload
php artisan clear-compiled
php artisan config:clear
```

### Error: "Unauthenticated"

**Penyebab**: Test memerlukan autentikasi tapi tidak menggunakan `Sanctum::actingAs()`

**Solusi**: Pastikan test menggunakan:
```php
Sanctum::actingAs($this->user);
```

### Test Berjalan Lambat

**Solusi**:
1. Gunakan SQLite in-memory untuk testing (sudah dikonfigurasi)
2. Gunakan parallel testing:
   ```bash
   php artisan test --parallel
   ```
3. Jalankan hanya test yang diperlukan

### Error: "Too few arguments to function"

**Penyebab**: Method signature berubah atau parameter tidak lengkap

**Solusi**: Periksa method yang dipanggil dan pastikan semua parameter required diberikan

---

## Tips untuk Laporan Praktikum

### 1. Screenshot yang Diperlukan

Ambil screenshot untuk:

1. **Struktur File Test**
   ```bash
   # Di Windows Explorer atau VS Code
   - tests/Unit/SlotAutoAssignmentServiceTest.php
   - tests/Feature/BookingModelTest.php
   - tests/Feature/BookingControllerTest.php
   - tests/Feature/TransaksiControllerTest.php
   ```

2. **Kode Test** (pilih beberapa test penting)
   - Buka file test di editor
   - Screenshot method test yang representatif

3. **Hasil Eksekusi**
   ```bash
   php artisan test
   ```
   - Screenshot output terminal yang menunjukkan semua test PASS

4. **File yang Diuji**
   - Screenshot file service, model, dan controller yang diuji

### 2. Informasi untuk Laporan

Catat informasi berikut:

- **Total Test**: 28 test cases
- **Unit Test**: 7 tests
- **Feature Test**: 21 tests (6 model + 10 controller booking + 5 controller QR)
- **Test Skipped**: 2 tests (QR validation belum implement)
- **Assertions Used**: assertEquals, assertNull, assertTrue, assertFalse, assertDatabaseHas, assertStatus, assertJson, dll.

### 3. Penjelasan untuk Setiap Test

Gunakan format:

```
Test: test_can_assign_available_slot()
File: tests/Unit/SlotAutoAssignmentServiceTest.php
Target: app/Services/SlotAutoAssignmentService.php
Method: assignSlot()
Assertion: assertEquals
Tujuan: Memastikan service dapat menemukan dan assign slot yang tersedia
Expected: Slot ID yang di-assign sama dengan slot yang dibuat
```

---

## Referensi

- [Laravel Testing Documentation](https://laravel.com/docs/testing)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Laravel Sanctum Testing](https://laravel.com/docs/sanctum#testing)

---

**Catatan**: Untuk pertanyaan atau issue, hubungi tim development atau buka issue di repository.
