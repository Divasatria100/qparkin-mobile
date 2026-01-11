# Vehicle Type Per Floor - Complete Implementation Guide

## Executive Summary

Implementasi ini mengubah logika bisnis dari **jenis kendaraan per parkiran** menjadi **jenis kendaraan per lantai**, yang lebih realistis untuk kasus nyata di mana satu mall bisa memiliki lantai khusus motor, mobil, atau jenis kendaraan lain.

## Status Implementasi

### ✅ SELESAI (Backend Core)
1. Migration untuk menambah `jenis_kendaraan` ke `parking_floors`
2. Migration untuk menghapus `jenis_kendaraan` dari `parkiran`
3. Model `ParkingFloor` - ditambah field dan scope
4. Model `Parkiran` - dihapus field `jenis_kendaraan`
5. `AdminController` - `storeParkiran()` dan `updateParkiran()` sudah handle per-lantai
6. `ParkingSlotController` - API `getFloors()` sudah return `jenis_kendaraan`
7. Flutter `ParkingFloorModel` - ditambah field `jenisKendaraan`

### ⏳ PERLU DILAKUKAN
1. **Admin Forms** - Update UI untuk input jenis kendaraan per lantai
2. **BookingProvider** - Tambah filter logic berdasarkan jenis kendaraan
3. **Run Migrations** - Jalankan migration di database
4. **Testing** - Test end-to-end flow

---

## STEP 1: Run Migrations

### 1.1 Jalankan Migration
```bash
cd qparkin_backend
php artisan migrate
```

**Expected Output:**
```
Migrating: 2026_01_11_000001_add_jenis_kendaraan_to_parking_floors_table
Migrated:  2026_01_11_000001_add_jenis_kendaraan_to_parking_floors_table (XX.XXms)
Migrating: 2026_01_11_000002_remove_jenis_kendaraan_from_parkiran_table
Migrated:  2026_01_11_000002_remove_jenis_kendaraan_from_parkiran_table (XX.XXms)
```

### 1.2 Verify Database Schema
```sql
-- Check parking_floors has jenis_kendaraan
DESCRIBE parking_floors;

-- Check parkiran doesn't have jenis_kendaraan
DESCRIBE parkiran;
```

### 1.3 Update Existing Data (If Any)
Jika sudah ada data parkiran, Anda perlu update manual:

```sql
-- Set default vehicle type for existing floors
UPDATE parking_floors 
SET jenis_kendaraan = 'Roda Empat' 
WHERE jenis_kendaraan IS NULL;

-- Update slots to match their floor's vehicle type
UPDATE parking_slots ps
JOIN parking_floors pf ON ps.id_floor = pf.id_floor
SET ps.jenis_kendaraan = pf.jenis_kendaraan;
```

---

## STEP 2: Update Admin Forms (Manual - Karena Perubahan Besar)

Karena perubahan UI cukup kompleks, berikut panduan untuk update manual:

### 2.1 Tambah Parkiran Form

**File:** `qparkin_backend/resources/views/admin/tambah-parkiran.blade.php`

**HAPUS:** Global vehicle type dropdown (sekitar line 80-90)
```html
<!-- HAPUS SECTION INI -->
<div class="form-group">
    <label for="jenisKendaraan">Jenis Kendaraan yang Diizinkan *</label>
    <select id="jenisKendaraan" name="jenis_kendaraan" required>
        ...
    </select>
</div>
```

**File:** `qparkin_backend/public/js/tambah-parkiran.js`

**UBAH:** Function `generateLantaiFields()` - Tambahkan dropdown jenis kendaraan per lantai

Cari bagian ini (sekitar line 60-80):
```javascript
lantaiItem.innerHTML = `
    <div class="lantai-header">
        <h5>Lantai ${i}</h5>
    </div>
    <div class="lantai-fields">
        <div class="lantai-field">
            <label for="namaLantai${i}">Nama Lantai</label>
            <input type="text" id="namaLantai${i}" ...>
        </div>
        <div class="lantai-field">
            <label for="slotLantai${i}">Jumlah Slot *</label>
            <input type="number" id="slotLantai${i}" ...>
        </div>
    </div>
`;
```

**TAMBAHKAN:** Dropdown jenis kendaraan di dalam `lantai-fields`:
```javascript
lantaiItem.innerHTML = `
    <div class="lantai-header">
        <h5>Lantai ${i}</h5>
    </div>
    <div class="lantai-fields">
        <div class="lantai-field">
            <label for="namaLantai${i}">Nama Lantai</label>
            <input type="text" id="namaLantai${i}" name="namaLantai${i}" 
                   value="Lantai ${i}" required 
                   onchange="updatePreview()">
            <span class="field-hint">Contoh: Lantai ${i}, Basement ${i}</span>
        </div>
        <div class="lantai-field">
            <label for="slotLantai${i}">Jumlah Slot *</label>
            <input type="number" id="slotLantai${i}" name="slotLantai${i}" 
                   min="1" max="200" value="20" required 
                   onchange="updatePreview()">
            <span class="field-hint">Slot akan ter-generate otomatis</span>
        </div>
        <div class="lantai-field">
            <label for="jenisKendaraanLantai${i}">Jenis Kendaraan *</label>
            <select id="jenisKendaraanLantai${i}" name="jenisKendaraanLantai${i}" 
                    required onchange="updatePreview()">
                <option value="Roda Dua">Roda Dua (Motor)</option>
                <option value="Roda Tiga">Roda Tiga</option>
                <option value="Roda Empat" selected>Roda Empat (Mobil)</option>
                <option value="Lebih dari Enam">Lebih dari Enam (Truk/Bus)</option>
            </select>
            <span class="field-hint">Jenis kendaraan untuk lantai ini</span>
        </div>
    </div>
`;
```

**UBAH:** Function `saveParkiran()` - Collect jenis kendaraan per lantai

Cari bagian collect lantai data (sekitar line 150-170):
```javascript
for (let i = 1; i <= jumlahLantaiValue; i++) {
    const namaInput = document.getElementById(`namaLantai${i}`);
    const slotInput = document.getElementById(`slotLantai${i}`);
    
    // TAMBAHKAN INI:
    const jenisKendaraanInput = document.getElementById(`jenisKendaraanLantai${i}`);
    
    if (namaInput && slotInput && jenisKendaraanInput) {
        const namaLantai = namaInput.value.trim();
        const slotCount = parseInt(slotInput.value) || 0;
        const jenisKendaraan = jenisKendaraanInput.value; // TAMBAHKAN INI
        
        // ... validasi ...
        
        lantaiData.push({
            nama: namaLantai,
            jumlah_slot: slotCount,
            jenis_kendaraan: jenisKendaraan // TAMBAHKAN INI
        });
    }
}
```

**HAPUS:** Validasi dan pengiriman `jenisKendaraanValue` global (sekitar line 130-140):
```javascript
// HAPUS BARIS INI:
const jenisKendaraanValue = jenisKendaraan.value;

// HAPUS DARI VALIDASI:
if (!nama || !kode || !status || !jenisKendaraanValue) { // HAPUS jenisKendaraanValue
    ...
}

// HAPUS DARI formData:
const formData = {
    nama_parkiran: nama,
    kode_parkiran: kode,
    status: status,
    // jenis_kendaraan: jenisKendaraanValue, // HAPUS BARIS INI
    jumlah_lantai: jumlahLantaiValue,
    lantai: lantaiData
};
```

### 2.2 Edit Parkiran Form

**File:** `qparkin_backend/resources/views/admin/edit-parkiran.blade.php`

Lakukan perubahan yang sama seperti tambah parkiran:
1. Hapus global vehicle type dropdown
2. Hapus display vehicle type di "Informasi Saat Ini"

**File:** `qparkin_backend/public/js/edit-parkiran.js`

**UBAH:** Function `generateLantaiFields()` - Tambahkan dropdown dengan value dari database

Cari bagian ini (sekitar line 80-100):
```javascript
for (let i = 0; i < jumlahLantaiValue; i++) {
    const floorData = floorsData[i] || {};
    const floorNumber = i + 1;
    const floorName = floorData.floor_name || `Lantai ${floorNumber}`;
    const totalSlots = floorData.total_slots || 20;
    const floorStatus = floorData.status || 'active';
    const jenisKendaraan = floorData.jenis_kendaraan || 'Roda Empat'; // TAMBAHKAN INI
    
    lantaiItem.innerHTML = `
        ...
        <div class="lantai-field">
            <label for="jenisKendaraanLantai${floorNumber}">Jenis Kendaraan *</label>
            <select id="jenisKendaraanLantai${floorNumber}" name="jenisKendaraanLantai${floorNumber}" 
                    required onchange="updatePreview()">
                <option value="Roda Dua" ${jenisKendaraan === 'Roda Dua' ? 'selected' : ''}>Roda Dua (Motor)</option>
                <option value="Roda Tiga" ${jenisKendaraan === 'Roda Tiga' ? 'selected' : ''}>Roda Tiga</option>
                <option value="Roda Empat" ${jenisKendaraan === 'Roda Empat' ? 'selected' : ''}>Roda Empat (Mobil)</option>
                <option value="Lebih dari Enam" ${jenisKendaraan === 'Lebih dari Enam' ? 'selected' : ''}>Lebih dari Enam (Truk/Bus)</option>
            </select>
        </div>
        ...
    `;
}
```

**UBAH:** Function `saveParkiran()` - Sama seperti tambah parkiran, collect jenis kendaraan per lantai

---

## STEP 3: Update BookingProvider (Flutter)

**File:** `qparkin_app/lib/logic/providers/booking_provider.dart`

### 3.1 Tambah Method untuk Filter Floors

Cari method `loadFloors()` atau tambahkan method baru:

```dart
/// Load floors filtered by vehicle type
Future<void> loadFloorsForVehicle(String jenisKendaraan) async {
  print('[BookingProvider] Loading floors for vehicle type: $jenisKendaraan');
  
  _isLoadingFloors = true;
  _floors = [];
  _selectedFloor = null;
  notifyListeners();

  try {
    // Get all floors from API
    final allFloors = await _bookingService.getFloors(_mallId);
    
    print('[BookingProvider] Total floors from API: ${allFloors.length}');
    
    // Filter floors that match vehicle type
    _floors = allFloors.where((floor) {
      final matches = floor.jenisKendaraan == jenisKendaraan;
      print('[BookingProvider] Floor ${floor.floorName}: ${floor.jenisKendaraan} ${matches ? "✓" : "✗"}');
      return matches;
    }).toList();
    
    print('[BookingProvider] Filtered floors: ${_floors.length}');
    
    _isLoadingFloors = false;
    _error = null;
    notifyListeners();
  } catch (e) {
    print('[BookingProvider] Error loading floors: $e');
    _isLoadingFloors = false;
    _error = e.toString();
    _floors = [];
    notifyListeners();
  }
}
```

### 3.2 Update Method selectVehicle

Cari method `selectVehicle()` dan update:

```dart
/// Select vehicle and load matching floors
void selectVehicle(VehicleModel vehicle) {
  print('[BookingProvider] Selecting vehicle: ${vehicle.platNomor} (${vehicle.jenisKendaraan})');
  
  _selectedVehicle = vehicle;
  _selectedFloor = null; // Reset floor selection
  _selectedSlot = null; // Reset slot selection
  _floors = []; // Clear floors
  
  // Load floors for this vehicle type
  if (_mallId.isNotEmpty && isSlotReservationEnabled) {
    loadFloorsForVehicle(vehicle.jenisKendaraan);
  }
  
  notifyListeners();
}
```

### 3.3 Update Method checkAvailability (Optional)

Jika ada logic untuk check availability, pastikan hanya check lantai yang sesuai:

```dart
Future<void> checkAvailability() async {
  if (_selectedVehicle == null || _selectedTime == null || _selectedDuration == null) {
    return;
  }

  _isCheckingAvailability = true;
  notifyListeners();

  try {
    // Only check floors that match vehicle type
    final matchingFloors = _floors.where((floor) {
      return floor.jenisKendaraan == _selectedVehicle!.jenisKendaraan;
    }).toList();
    
    // Calculate total available slots from matching floors
    _availableSlots = matchingFloors.fold(0, (sum, floor) => sum + floor.availableSlots);
    
    _isCheckingAvailability = false;
    notifyListeners();
  } catch (e) {
    _isCheckingAvailability = false;
    _error = e.toString();
    notifyListeners();
  }
}
```

---

## STEP 4: Testing

### 4.1 Test Backend API

**Test 1: Create Parkiran dengan Mixed Vehicle Types**
```bash
# Via Postman atau browser
POST http://192.168.0.101:8000/admin/parkiran/store

Body (JSON):
{
  "nama_parkiran": "Parkiran Test Mixed",
  "kode_parkiran": "TMIX",
  "status": "Tersedia",
  "jumlah_lantai": 3,
  "lantai": [
    {
      "nama": "Lantai 1 Motor",
      "jumlah_slot": 30,
      "jenis_kendaraan": "Roda Dua",
      "status": "active"
    },
    {
      "nama": "Lantai 2 Mobil",
      "jumlah_slot": 20,
      "jenis_kendaraan": "Roda Empat",
      "status": "active"
    },
    {
      "nama": "Lantai 3 Mobil",
      "jumlah_slot": 20,
      "jenis_kendaraan": "Roda Empat",
      "status": "active"
    }
  ]
}
```

**Test 2: Get Floors API**
```bash
GET http://192.168.0.101:8000/api/parking/floors/4

Expected Response:
{
  "success": true,
  "data": [
    {
      "id_floor": 1,
      "floor_name": "Lantai 1 Motor",
      "jenis_kendaraan": "Roda Dua",  // ✓ Should be present
      "total_slots": 30,
      "available_slots": 30
    },
    {
      "id_floor": 2,
      "floor_name": "Lantai 2 Mobil",
      "jenis_kendaraan": "Roda Empat",  // ✓ Should be present
      "total_slots": 20,
      "available_slots": 20
    }
  ]
}
```

**Test 3: Verify Database**
```sql
-- Check floors have correct vehicle types
SELECT 
    pf.id_floor,
    pf.floor_name,
    pf.jenis_kendaraan,
    pf.total_slots,
    COUNT(ps.id_slot) as slot_count,
    ps.jenis_kendaraan as slot_vehicle_type
FROM parking_floors pf
LEFT JOIN parking_slots ps ON pf.id_floor = ps.id_floor
WHERE pf.id_parkiran = [test_parkiran_id]
GROUP BY pf.id_floor, ps.jenis_kendaraan;

-- Expected: Each floor's slots should match floor's vehicle type
```

### 4.2 Test Flutter App

**Test Scenario 1: Motor User**
1. Login dengan user yang punya kendaraan motor (Roda Dua)
2. Buka booking page
3. Pilih kendaraan motor
4. **Expected:** Hanya muncul "Lantai 1 Motor" di floor selector
5. **Expected:** Tidak muncul lantai mobil

**Test Scenario 2: Car User**
1. Login dengan user yang punya kendaraan mobil (Roda Empat)
2. Buka booking page
3. Pilih kendaraan mobil
4. **Expected:** Hanya muncul "Lantai 2 Mobil" dan "Lantai 3 Mobil"
5. **Expected:** Tidak muncul lantai motor

**Test Scenario 3: User with Multiple Vehicles**
1. User punya motor DAN mobil
2. Pilih motor → Lihat lantai motor
3. Ganti ke mobil → Lihat lantai mobil
4. **Expected:** Floor selector berubah sesuai kendaraan yang dipilih

### 4.3 Debug Logging

Jika ada masalah, check log:

**Backend (Laravel):**
```bash
tail -f qparkin_backend/storage/logs/laravel.log
```

**Flutter:**
```dart
// Di BookingProvider, tambahkan log:
print('[BookingProvider] Selected vehicle type: ${_selectedVehicle?.jenisKendaraan}');
print('[BookingProvider] Available floors: ${_floors.length}');
_floors.forEach((floor) {
  print('  - ${floor.floorName}: ${floor.jenisKendaraan}');
});
```

---

## STEP 5: Rollback Plan (Jika Ada Masalah)

Jika implementasi bermasalah, rollback dengan:

```bash
cd qparkin_backend

# Rollback migrations
php artisan migrate:rollback --step=2

# Restore old code from git
git checkout HEAD -- app/Models/ParkingFloor.php
git checkout HEAD -- app/Models/Parkiran.php
git checkout HEAD -- app/Http/Controllers/AdminController.php
```

---

## Summary Checklist

### Backend
- [x] Migration: Add jenis_kendaraan to parking_floors
- [x] Migration: Remove jenis_kendaraan from parkiran
- [x] Model: ParkingFloor updated
- [x] Model: Parkiran updated
- [x] Controller: AdminController updated
- [x] API: ParkingSlotController updated
- [ ] Run migrations
- [ ] Update admin forms (tambah-parkiran)
- [ ] Update admin forms (edit-parkiran)
- [ ] Test API endpoints

### Frontend (Flutter)
- [x] Model: ParkingFloorModel updated
- [ ] Provider: BookingProvider add filter logic
- [ ] Test: Vehicle selection filters floors
- [ ] Test: End-to-end booking flow

### Documentation
- [x] Implementation guide created
- [x] Migration files documented
- [x] API changes documented
- [x] Testing scenarios documented

---

## Quick Commands

```bash
# Backend
cd qparkin_backend
php artisan migrate
php artisan cache:clear
php artisan config:clear

# Flutter
cd qparkin_app
flutter pub get
flutter run --dart-define=API_URL=http://192.168.0.101:8000

# Test API
curl http://192.168.0.101:8000/api/parking/floors/4
```

---

## Support

Jika ada pertanyaan atau masalah:
1. Check log files (Laravel dan Flutter console)
2. Verify database schema dengan `DESCRIBE` commands
3. Test API endpoints dengan Postman/curl
4. Check dokumentasi di `VEHICLE_TYPE_PER_FLOOR_IMPLEMENTATION.md`
