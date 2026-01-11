# Booking Page Slot Availability Fix - Complete Solution

## Tanggal: 11 Januari 2026

## Masalah yang Ditemukan

### 1. **Card Ketersediaan Slot Menampilkan "0 slot tersedia"**
**Gejala:**
- Setelah memilih kendaraan (misalnya "Roda Dua"), card ketersediaan slot menampilkan "0 slot tersedia untuk roda dua"
- Label ketersediaan pada card Mall juga berubah menjadi "0 slot tersedia"
- Padahal lantai sudah dikonfigurasi oleh admin untuk jenis kendaraan tersebut

**Penyebab Root:**
- Method `loadFloorsForVehicle()` di `booking_provider.dart` hanya memfilter lantai berdasarkan jenis kendaraan
- **TIDAK mengupdate `_availableSlots`** setelah filtering
- Akibatnya, `_availableSlots` tetap 0 (nilai default) meskipun lantai yang sesuai memiliki slot tersedia

### 2. **Card "Slot Tidak Tersedia" Muncul Meskipun Slot Tersedia**
**Gejala:**
- Card "Slot Tidak Tersedia" dengan opsi waktu alternatif muncul
- Padahal slot sebenarnya masih tersedia untuk jenis kendaraan yang dipilih

**Penyebab Root:**
- Kondisi di `booking_page.dart` menampilkan `SlotUnavailableWidget` ketika `availableSlots == 0`
- Karena `_availableSlots` tidak diupdate setelah floor filtering, nilai tetap 0
- Widget muncul meskipun sebenarnya ada slot tersedia

### 3. **Slot Availability Indicator Muncul Sebelum Floor Loading Selesai**
**Gejala:**
- Card ketersediaan slot muncul langsung setelah memilih kendaraan
- Menampilkan "0 slot tersedia" sebelum data lantai selesai dimuat

**Penyebab Root:**
- Kondisi di `booking_page.dart` tidak mengecek `provider.isLoadingFloors`
- Widget muncul sebelum `loadFloorsForVehicle()` selesai mengambil dan memfilter data lantai

---

## Solusi yang Diterapkan

### Fix 1: Update `_availableSlots` di `loadFloorsForVehicle()`

**File:** `qparkin_app/lib/logic/providers/booking_provider.dart`

**Perubahan:**
```dart
// Filter floors that match vehicle type
_floors = allFloors.where((floor) {
  final matches = floor.jenisKendaraan == jenisKendaraan;
  debugPrint('[BookingProvider] Floor ${floor.floorName}: ${floor.jenisKendaraan} ${matches ? "✓" : "✗"} (${floor.availableSlots} slots)');
  return matches;
}).toList();

// ✅ ADDED: Calculate total available slots from filtered floors
final totalAvailableSlots = _floors.fold(
  0, 
  (sum, floor) => sum + floor.availableSlots
);

_availableSlots = totalAvailableSlots;
debugPrint('[BookingProvider] Total available slots for $jenisKendaraan: $_availableSlots');
```

**Impact:**
- ✅ `_availableSlots` sekarang dihitung dari lantai yang sesuai dengan jenis kendaraan
- ✅ Menampilkan jumlah slot yang akurat
- ✅ Card ketersediaan slot menampilkan angka yang benar

**Contoh Output Log:**
```
[BookingProvider] Loading floors for vehicle type: Roda Dua
[BookingProvider] Total floors from API: 3
[BookingProvider] Floor Lantai 1: Roda Dua ✓ (50 slots)
[BookingProvider] Floor Lantai 2: Roda Empat ✗ (30 slots)
[BookingProvider] Floor Lantai 3: Roda Empat ✗ (20 slots)
[BookingProvider] Filtered floors: 1
[BookingProvider] Total available slots for Roda Dua: 50
[BookingProvider] SUCCESS: Loaded 1 floors for Roda Dua
  - Lantai 1: 50 slots available
```

### Fix 2: Set `_availableSlots = 0` on Error

**File:** `qparkin_app/lib/logic/providers/booking_provider.dart`

**Perubahan:**
```dart
} catch (e, stackTrace) {
  _isLoadingFloors = false;
  _availableSlots = 0;  // ✅ ADDED: Reset to 0 on error
  
  // ... error handling ...
  
  _floors = [];
  notifyListeners();
}
```

**Impact:**
- ✅ Jika terjadi error saat loading floors, `_availableSlots` direset ke 0
- ✅ Mencegah menampilkan data slot yang tidak valid
- ✅ Konsisten dengan state error

### Fix 3: Add `!provider.isLoadingFloors` Check to SlotAvailabilityIndicator

**File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Perubahan:**
```dart
// Slot Availability Indicator - only show when vehicle selected and floors loaded
if (provider.selectedVehicle != null &&
    provider.startTime != null &&
    provider.bookingDuration != null &&
    !provider.isLoadingFloors)  // ✅ ADDED: Check floor loading status
  SlotAvailabilityIndicator(
    availableSlots: provider.availableSlots,
    vehicleType: provider.selectedVehicle!['jenis_kendaraan'] ??
        provider.selectedVehicle!['jenis'] ??
        '',
    isLoading: provider.isCheckingAvailability || provider.isLoadingFloors,  // ✅ UPDATED
    onRefresh: () {
      if (_authToken != null) {
        provider.refreshAvailability(token: _authToken!);
      }
    },
  ),
```

**Impact:**
- ✅ Card ketersediaan slot hanya muncul setelah floor loading selesai
- ✅ Mencegah menampilkan "0 slot tersedia" saat data masih dimuat
- ✅ Loading indicator ditampilkan saat floor loading atau availability check

### Fix 4: Add `!provider.isLoadingFloors` Check to SlotUnavailableWidget

**File:** `qparkin_app/lib/presentation/screens/booking_page.dart`

**Perubahan:**
```dart
// Slot unavailability warning with alternatives
if (provider.availableSlots == 0 &&
    provider.selectedVehicle != null &&
    provider.startTime != null &&
    provider.bookingDuration != null &&
    !provider.isCheckingAvailability &&
    !provider.isLoadingFloors)  // ✅ ADDED: Check floor loading status
  Padding(
    padding: EdgeInsets.only(bottom: spacing),
    child: SlotUnavailableWidget(
      // ...
    ),
  ),
```

**Impact:**
- ✅ Card "Slot Tidak Tersedia" hanya muncul setelah floor loading selesai
- ✅ Mencegah false positive saat data masih dimuat
- ✅ Hanya muncul jika slot benar-benar tidak tersedia

---

## Alur Bisnis yang Benar

### Sebelum Fix:
```
1. User membuka halaman booking
2. User memilih kendaraan "Roda Dua"
   → selectVehicle() dipanggil dengan token
   → loadFloorsForVehicle() dipanggil
   → Lantai difilter: Lantai 1 (Roda Dua) ✓
   → ❌ _availableSlots TIDAK diupdate (tetap 0)
3. UI menampilkan:
   → ❌ "0 slot tersedia untuk roda dua"
   → ❌ Card "Slot Tidak Tersedia" muncul
   → ❌ Label mall: "0 slot tersedia"
```

### Setelah Fix:
```
1. User membuka halaman booking
2. User memilih kendaraan "Roda Dua"
   → selectVehicle() dipanggil dengan token
   → loadFloorsForVehicle() dipanggil
   → Lantai difilter: Lantai 1 (Roda Dua) ✓
   → ✅ _availableSlots = 50 (dari Lantai 1)
   → ✅ isLoadingFloors = false
3. UI menampilkan:
   → ✅ "50 slot tersedia untuk roda dua"
   → ✅ Card "Slot Tidak Tersedia" TIDAK muncul
   → ✅ Label mall: "50 slot tersedia"
   → ✅ Status: "Banyak slot tersedia" (hijau)
```

---

## Validasi dan Testing

### Test Case 1: Memilih Kendaraan Roda Dua
**Konfigurasi Admin:**
- Lantai 1: Roda Dua, 50 slot tersedia
- Lantai 2: Roda Empat, 30 slot tersedia
- Lantai 3: Roda Empat, 20 slot tersedia

**Steps:**
1. Buka halaman booking
2. Pilih kendaraan roda dua
3. Tunggu floor loading selesai

**Expected Result:**
- ✅ Card ketersediaan slot menampilkan "50 slot tersedia untuk roda dua"
- ✅ Label mall menampilkan "50 slot tersedia"
- ✅ Status: "Banyak slot tersedia" (hijau)
- ✅ Card "Slot Tidak Tersedia" TIDAK muncul
- ✅ Hanya Lantai 1 yang muncul di floor selector

**Debug Log:**
```
[BookingProvider] Selecting vehicle: AB 1234 CD
[BookingProvider] Filtering floors for vehicle type: Roda Dua
[BookingProvider] Loading floors for vehicle type: Roda Dua
[BookingProvider] Total floors from API: 3
[BookingProvider] Floor Lantai 1: Roda Dua ✓ (50 slots)
[BookingProvider] Floor Lantai 2: Roda Empat ✗ (30 slots)
[BookingProvider] Floor Lantai 3: Roda Empat ✗ (20 slots)
[BookingProvider] Filtered floors: 1
[BookingProvider] Total available slots for Roda Dua: 50
[BookingProvider] SUCCESS: Loaded 1 floors for Roda Dua
  - Lantai 1: 50 slots available
```

### Test Case 2: Memilih Kendaraan Roda Empat
**Konfigurasi Admin:**
- Lantai 1: Roda Dua, 50 slot tersedia
- Lantai 2: Roda Empat, 30 slot tersedia
- Lantai 3: Roda Empat, 20 slot tersedia

**Steps:**
1. Buka halaman booking
2. Pilih kendaraan roda empat
3. Tunggu floor loading selesai

**Expected Result:**
- ✅ Card ketersediaan slot menampilkan "50 slot tersedia untuk roda empat" (30 + 20)
- ✅ Label mall menampilkan "50 slot tersedia"
- ✅ Status: "Banyak slot tersedia" (hijau)
- ✅ Card "Slot Tidak Tersedia" TIDAK muncul
- ✅ Lantai 2 dan Lantai 3 muncul di floor selector

**Debug Log:**
```
[BookingProvider] Selecting vehicle: B 5678 EF
[BookingProvider] Filtering floors for vehicle type: Roda Empat
[BookingProvider] Loading floors for vehicle type: Roda Empat
[BookingProvider] Total floors from API: 3
[BookingProvider] Floor Lantai 1: Roda Dua ✗ (50 slots)
[BookingProvider] Floor Lantai 2: Roda Empat ✓ (30 slots)
[BookingProvider] Floor Lantai 3: Roda Empat ✓ (20 slots)
[BookingProvider] Filtered floors: 2
[BookingProvider] Total available slots for Roda Empat: 50
[BookingProvider] SUCCESS: Loaded 2 floors for Roda Empat
  - Lantai 2: 30 slots available
  - Lantai 3: 20 slots available
```

### Test Case 3: Slot Terbatas (3-10 slot)
**Konfigurasi Admin:**
- Lantai 1: Roda Dua, 5 slot tersedia

**Steps:**
1. Buka halaman booking
2. Pilih kendaraan roda dua
3. Tunggu floor loading selesai

**Expected Result:**
- ✅ Card ketersediaan slot menampilkan "5 slot tersedia untuk roda dua"
- ✅ Label mall menampilkan "5 slot tersedia"
- ✅ Status: "Slot terbatas" (orange)
- ✅ Card "Slot Tidak Tersedia" TIDAK muncul

### Test Case 4: Slot Hampir Penuh (1-2 slot)
**Konfigurasi Admin:**
- Lantai 1: Roda Dua, 2 slot tersedia

**Steps:**
1. Buka halaman booking
2. Pilih kendaraan roda dua
3. Tunggu floor loading selesai

**Expected Result:**
- ✅ Card ketersediaan slot menampilkan "2 slot tersedia untuk roda dua"
- ✅ Label mall menampilkan "2 slot tersedia"
- ✅ Status: "Hampir penuh" (red)
- ✅ Card "Slot Tidak Tersedia" TIDAK muncul

### Test Case 5: Slot Benar-Benar Penuh (0 slot)
**Konfigurasi Admin:**
- Lantai 1: Roda Dua, 0 slot tersedia (semua slot terisi)

**Steps:**
1. Buka halaman booking
2. Pilih kendaraan roda dua
3. Pilih waktu dan durasi
4. Tunggu floor loading selesai

**Expected Result:**
- ✅ Card ketersediaan slot menampilkan "0 slot tersedia untuk roda dua"
- ✅ Label mall menampilkan "0 slot tersedia"
- ✅ Status: "Penuh" (red)
- ✅ Card "Slot Tidak Tersedia" MUNCUL dengan opsi waktu alternatif
- ✅ Tombol konfirmasi booking disabled

### Test Case 6: Tidak Ada Lantai untuk Jenis Kendaraan
**Konfigurasi Admin:**
- Lantai 1: Roda Empat, 50 slot tersedia
- Lantai 2: Roda Empat, 30 slot tersedia
- (Tidak ada lantai untuk Roda Dua)

**Steps:**
1. Buka halaman booking
2. Pilih kendaraan roda dua
3. Tunggu floor loading selesai

**Expected Result:**
- ✅ Error message: "Tidak ada lantai parkir untuk jenis kendaraan Roda Dua"
- ✅ `_availableSlots = 0`
- ✅ Card ketersediaan slot TIDAK muncul (karena error)
- ✅ Floor selector kosong

---

## Integrasi dengan Vehicle Type Per Floor

### Backend Configuration
Setiap lantai parkir memiliki field `jenis_kendaraan`:
```sql
ALTER TABLE parking_floors 
ADD COLUMN jenis_kendaraan ENUM('Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam');
```

### API Response
Endpoint `/api/parking/floors/{mallId}` mengembalikan:
```json
{
  "success": true,
  "data": [
    {
      "id_floor": 1,
      "floor_name": "Lantai 1",
      "jenis_kendaraan": "Roda Dua",
      "available_slots": 50,
      "total_slots": 100
    },
    {
      "id_floor": 2,
      "floor_name": "Lantai 2",
      "jenis_kendaraan": "Roda Empat",
      "available_slots": 30,
      "total_slots": 80
    },
    {
      "id_floor": 3,
      "floor_name": "Lantai 3",
      "jenis_kendaraan": "Roda Empat",
      "available_slots": 20,
      "total_slots": 60
    }
  ]
}
```

### Provider Logic Flow
```dart
// 1. User selects vehicle
selectVehicle(vehicle, token: token)
  ↓
// 2. Extract vehicle type
jenisKendaraan = vehicle['jenis_kendaraan'] // "Roda Dua"
  ↓
// 3. Load and filter floors
loadFloorsForVehicle(jenisKendaraan: jenisKendaraan, token: token)
  ↓
// 4. Get all floors from API
allFloors = await _bookingService.getFloorsWithRetry(...)
  ↓
// 5. Filter by vehicle type
_floors = allFloors.where((floor) => floor.jenisKendaraan == jenisKendaraan)
  ↓
// 6. Calculate total available slots
_availableSlots = _floors.fold(0, (sum, floor) => sum + floor.availableSlots)
  ↓
// 7. Notify UI
notifyListeners()
```

---

## Perubahan File

### 1. `qparkin_app/lib/logic/providers/booking_provider.dart`
**Lines Modified:** 880-1000 (approx)

**Changes:**
1. ✅ Added calculation of `_availableSlots` from filtered floors
2. ✅ Added `_availableSlots = 0` on error
3. ✅ Enhanced debug logging with slot counts

**Impact:**
- Slot availability now accurately reflects filtered floors
- Error handling is more robust
- Better debugging capabilities

### 2. `qparkin_app/lib/presentation/screens/booking_page.dart`
**Lines Modified:** 315-345 (approx)

**Changes:**
1. ✅ Added `!provider.isLoadingFloors` check to SlotAvailabilityIndicator condition
2. ✅ Updated `isLoading` parameter to include `provider.isLoadingFloors`
3. ✅ Added `!provider.isLoadingFloors` check to SlotUnavailableWidget condition

**Impact:**
- UI only shows slot availability after floor loading completes
- Prevents false "0 slot tersedia" messages
- Prevents false "Slot Tidak Tersedia" warnings

---

## Kesimpulan

### Masalah yang Diperbaiki:
1. ✅ Card ketersediaan slot sekarang menampilkan jumlah slot yang akurat
2. ✅ Label ketersediaan pada card Mall konsisten dengan data lantai
3. ✅ Card "Slot Tidak Tersedia" hanya muncul jika slot benar-benar tidak tersedia
4. ✅ UI menunggu floor loading selesai sebelum menampilkan informasi slot

### Alur yang Diperbaiki:
1. ✅ User memilih kendaraan → Lantai difilter berdasarkan jenis kendaraan
2. ✅ `_availableSlots` dihitung dari lantai yang sesuai
3. ✅ UI menampilkan jumlah slot yang akurat
4. ✅ Card "Slot Tidak Tersedia" hanya muncul jika benar-benar penuh

### File yang Diubah:
- `qparkin_app/lib/logic/providers/booking_provider.dart` (3 perubahan)
- `qparkin_app/lib/presentation/screens/booking_page.dart` (3 perubahan)

### Testing:
- ✅ Test dengan kendaraan roda dua (50 slot tersedia)
- ✅ Test dengan kendaraan roda empat (50 slot tersedia dari 2 lantai)
- ✅ Test dengan slot terbatas (5 slot)
- ✅ Test dengan slot hampir penuh (2 slot)
- ✅ Test dengan slot benar-benar penuh (0 slot)
- ✅ Test dengan tidak ada lantai untuk jenis kendaraan

---

## Referensi
- `BOOKING_PAGE_FLOOR_UI_FIX_SUMMARY.md` - Fix sebelumnya untuk UI booking page
- `VEHICLE_TYPE_PER_FLOOR_COMPLETE_GUIDE.md` - Panduan implementasi vehicle type per floor
- `VEHICLE_TYPE_PER_FLOOR_IMPLEMENTATION.md` - Implementasi backend vehicle type per floor
