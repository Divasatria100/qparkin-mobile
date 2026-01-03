# Quick Test Guide - Qparkin Backend

## 🚀 Quick Start

### 1. Setup (Sekali Saja)

```bash
cd qparkin_backend
composer install
cp .env.example .env.testing
php artisan key:generate
```

Edit `.env.testing`:
```env
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### 2. Jalankan Test

```bash
# Semua test
php artisan test

# Unit test saja
php artisan test --testsuite=Unit

# Feature test saja
php artisan test --testsuite=Feature

# Test spesifik
php artisan test tests/Unit/SlotAutoAssignmentServiceTest.php
```

---

## 📁 File Test yang Dibuat

| File Test | Target | Jumlah Test | Status |
|-----------|--------|-------------|--------|
| `tests/Unit/SlotAutoAssignmentServiceTest.php` | `app/Services/SlotAutoAssignmentService.php` | 7 | ✅ 7 PASS |
| `tests/Feature/BookingModelTest.php` | `app/Models/Booking.php` | 6 | ✅ 6 PASS |
| `tests/Feature/BookingControllerTest.php` | `app/Http/Controllers/Api/BookingController.php` | 10 | ✅ 10 PASS |
| `tests/Feature/TransaksiControllerTest.php` | `app/Http/Controllers/Api/TransaksiController.php` | 7 | ⚠️ 5 PASS, 2 FAIL |
| **TOTAL** | | **30** | **26 PASS, 2 FAIL** |

---

## 📊 Ringkasan Test

### A. Unit Test (7 tests)

**File**: `tests/Unit/SlotAutoAssignmentServiceTest.php`

1. ✅ `test_can_assign_available_slot` - Assign slot tersedia
2. ✅ `test_cannot_assign_reserved_slot` - Cegah booking bentrok
3. ✅ `test_returns_null_when_no_slots_available` - Tidak ada slot
4. ✅ `test_calculates_available_slot_count_correctly` - Hitung slot
5. ✅ `test_should_auto_assign_based_on_mall_config` - Validasi config
6. ✅ `test_returns_null_when_vehicle_not_found` - Kendaraan invalid
7. ✅ `test_does_not_assign_slot_for_different_vehicle_type` - Jenis kendaraan

### B. Feature Test - Model (6 tests)

**File**: `tests/Feature/BookingModelTest.php`

1. ✅ `test_can_create_booking` - CREATE
2. ✅ `test_can_read_booking` - READ
3. ✅ `test_can_update_booking_status` - UPDATE
4. ✅ `test_can_delete_booking` - DELETE
5. ✅ `test_booking_has_transaksi_parkir_relation` - Relasi
6. ✅ `test_booking_has_slot_relation` - Relasi

### C. Feature Test - Controller Booking (10 tests)

**File**: `tests/Feature/BookingControllerTest.php`

1. ✅ `test_can_get_all_bookings` - 200 GET all
2. ✅ `test_can_get_booking_detail` - 200 GET detail
3. ✅ `test_can_create_booking` - 201 POST create
4. ✅ `test_can_cancel_booking` - 200 PUT cancel
5. ✅ `test_can_delete_booking_via_cancel` - 200 DELETE
6. ✅ `test_create_booking_validation_error` - 400 Validation
7. ✅ `test_get_booking_not_found` - 404 Not Found
8. ✅ `test_booking_requires_authentication` - 401 Unauthorized
9. ✅ `test_create_booking_with_invalid_reservation` - 400 Invalid
10. ✅ `test_create_booking_no_slots_available` - 404 No slots

### D. Feature Test - Controller QR (7 tests)

**File**: `tests/Feature/TransaksiControllerTest.php`

1. ✅ `test_can_scan_qr_masuk_with_valid_booking` - QR masuk valid
2. ✅ `test_can_scan_qr_keluar_with_valid_booking` - QR keluar valid
3. ❌ `test_cannot_scan_expired_qr` - QR expired (FAIL - Expected)
4. ❌ `test_cannot_scan_invalid_qr` - QR invalid (FAIL - Expected)
5. ✅ `test_can_get_active_transaksi` - Get active
6. ✅ `test_can_get_all_transaksi` - Get all
7. ✅ `test_transaksi_requires_authentication` - Auth required

**Catatan**: Test 3 & 4 akan FAIL karena controller belum implement validasi

---

## 🎯 Assertions yang Digunakan

| Assertion | Kegunaan | Contoh |
|-----------|----------|--------|
| `assertEquals` | Bandingkan nilai | `$this->assertEquals(3, $count)` |
| `assertNull` | Nilai null | `$this->assertNull($result)` |
| `assertTrue/False` | Boolean | `$this->assertTrue($condition)` |
| `assertDatabaseHas` | Data ada di DB | `$this->assertDatabaseHas('booking', [...])` |
| `assertDatabaseMissing` | Data tidak ada | `$this->assertDatabaseMissing('booking', [...])` |
| `assertStatus` | HTTP status | `$response->assertStatus(200)` |
| `assertJson` | JSON response | `$response->assertJson([...])` |
| `assertCreated` | Status 201 | `$response->assertCreated()` |
| `assertNotFound` | Status 404 | `$response->assertNotFound()` |

---

## 📸 Screenshot untuk Laporan

### 1. Struktur File
- Screenshot folder `tests/` di VS Code/Explorer

### 2. Kode Test (pilih 3-4 test)
- `test_can_assign_available_slot()` (Unit)
- `test_can_create_booking()` (Model)
- `test_can_create_booking()` (Controller)
- `test_can_scan_qr_masuk_with_valid_booking()` (QR)

### 3. Hasil Eksekusi
```bash
php artisan test
```
Screenshot output terminal

### 4. File yang Diuji
- `app/Services/SlotAutoAssignmentService.php`
- `app/Models/Booking.php`
- `app/Http/Controllers/Api/BookingController.php`

---

## 📝 Template Penjelasan untuk Laporan

```
### Test: [Nama Test]

**Lokasi File Test**: tests/[Unit|Feature]/[NamaFile].php
**File yang Diuji**: app/[path]/[NamaFile].php
**Method yang Diuji**: [namaMethod()]
**Jenis Pengujian**: [Unit Test | Feature Test]

**Assertion yang Digunakan**: 
- [assertion1]: [tujuan]
- [assertion2]: [tujuan]

**Tujuan**: 
[Penjelasan tujuan test]

**Skenario**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**: 
[Hasil yang diharapkan]

**Hasil Pengujian**: ✅ PASS / ❌ FAIL
```

---

## ⚠️ Troubleshooting

### Error: Class not found
```bash
composer dump-autoload
```

### Error: Database
Test menggunakan SQLite in-memory, tidak perlu setup database

### Error: Unauthenticated
Pastikan test menggunakan `Sanctum::actingAs($user)`

---

## 📚 Dokumentasi Lengkap

Lihat file berikut untuk dokumentasi lengkap:
- `LAPORAN_PENGUJIAN_OTOMATIS.md` - Laporan lengkap untuk praktikum
- `tests/README.md` - Panduan detail menjalankan test

---

**Total Test**: 30 test cases  
**Result**: 26 PASS (86.7%) | 2 FAIL (6.7%) | 2 Expected Failures  
**Coverage**: F002 (Booking) ✅ 100% | F003 (QR) ⚠️ 71%

---

## ⚠️ PENJELASAN TEST YANG FAIL

### Test 1: `test_cannot_scan_expired_qr` ❌
- **Expected**: Status 400 (Bad Request)
- **Actual**: Status 201 (Created)
- **Alasan**: `TransaksiController::masuk()` belum implement validasi QR expired
- **Lokasi**: `app/Http/Controllers/Api/TransaksiController.php` line 15-20
- **Status**: Expected Failure (fitur belum diimplementasikan)

### Test 2: `test_cannot_scan_invalid_qr` ❌
- **Expected**: Status 404 (Not Found)
- **Actual**: Status 201 (Created)
- **Alasan**: `TransaksiController::masuk()` belum implement validasi ID transaksi
- **Lokasi**: `app/Http/Controllers/Api/TransaksiController.php` line 15-20
- **Status**: Expected Failure (fitur belum diimplementasikan)

**Kesimpulan**: 2 test FAIL adalah expected failures yang menunjukkan requirement belum terpenuhi. Ini adalah praktik TDD yang baik.
