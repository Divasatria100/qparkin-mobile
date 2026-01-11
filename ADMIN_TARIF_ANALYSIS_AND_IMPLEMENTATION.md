# Admin Tarif - Analisis dan Implementasi

## Analisis Sistem Tarif Saat Ini

### 1. Struktur Database

**Tabel**: `tarif_parkir`

```sql
CREATE TABLE tarif_parkir (
    id_tarif BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_mall BIGINT,
    jenis_kendaraan ENUM('Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'),
    satu_jam_pertama DECIMAL(10,2),
    tarif_parkir_per_jam DECIMAL(10,2),
    FOREIGN KEY (id_mall) REFERENCES mall(id_mall)
);
```

**Tabel Riwayat**: `riwayat_tarif`

```sql
CREATE TABLE riwayat_tarif (
    id_riwayat BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_tarif BIGINT,
    id_mall BIGINT,
    id_user BIGINT,
    jenis_kendaraan VARCHAR(50),
    tarif_lama_jam_pertama DECIMAL(10,2),
    tarif_lama_per_jam DECIMAL(10,2),
    tarif_baru_jam_pertama DECIMAL(10,2),
    tarif_baru_per_jam DECIMAL(10,2),
    waktu_perubahan TIMESTAMP,
    keterangan TEXT,
    FOREIGN KEY (id_tarif) REFERENCES tarif_parkir(id_tarif) ON DELETE CASCADE
);
```

**Business Rules**:
- Setiap mall memiliki 4 tarif (satu untuk setiap jenis kendaraan)
- Tarif terdiri dari: `satu_jam_pertama` dan `tarif_parkir_per_jam`
- Setiap perubahan tarif dicatat di `riwayat_tarif`
- Trigger database mencegah tarif negatif dan duplikasi

---

### 2. Backend - Controller & Routes

#### Routes (Sudah Ada)

**Web Routes** (`routes/web.php`):
```php
Route::get('/tarif', [AdminController::class, 'tarif'])->name('tarif');
Route::get('/tarif/{id}/edit', [AdminController::class, 'editTarif'])->name('tarif.edit');
Route::post('/tarif/{id}', [AdminController::class, 'updateTarif'])->name('tarif.update');
```

**API Routes** (`routes/api.php`):
```php
Route::get('/mall/{id}/tarif', [MallController::class, 'getTarif']);
```

#### Controller Methods (Sudah Ada)

**AdminController.php**:

1. **`tarif()`** - Menampilkan halaman tarif
   - Mengambil semua tarif untuk mall admin
   - Mengambil riwayat perubahan tarif
   - Return view `admin.tarif`

2. **`editTarif($id)`** - Menampilkan form edit tarif
   - Mengambil data tarif berdasarkan `id_tarif`
   - Return view `admin.edit-tarif`

3. **`updateTarif(Request $request, $id)`** - Update tarif
   - Validasi input
   - Simpan riwayat perubahan ke `riwayat_tarif`
   - Update tarif di `tarif_parkir`
   - Redirect dengan success message

**MallController.php** (API):

```php
public function getTarif($id)
{
    try {
        $mall = Mall::where('status', 'active')->findOrFail($id);
        $tarif = $mall->tarifParkir()
            ->select(['id_tarif', 'jenis_kendaraan', 'tarif_per_jam', 'tarif_maksimal'])
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Parking rates retrieved successfully',
            'data' => $tarif
        ]);
    } catch (\Exception $e) {
        \Log::error('Error fetching parking rates: ' . $e->getMessage());
        
        return response()->json([
            'success' => false,
            'message' => 'Failed to fetch parking rates',
            'error' => $e->getMessage()
        ], 500);
    }
}
```

---

### 3. Frontend - Views

#### Halaman Tarif (`admin/tarif.blade.php`)

**Fitur Saat Ini**:
- ✅ Menampilkan 4 kartu tarif (Roda Dua, Tiga, Empat, Lebih dari Enam)
- ✅ Menampilkan tarif jam pertama dan per jam berikutnya
- ✅ Menampilkan total untuk 3 jam (contoh)
- ✅ Tombol "Edit" untuk setiap kartu
- ✅ Tabel riwayat perubahan tarif

**Yang Perlu Diperbaiki**:
- ❌ Tombol Edit mengarah ke route yang sudah ada tapi form edit belum lengkap
- ❌ Tidak ada validasi visual untuk tarif yang tidak wajar

#### Halaman Edit Tarif (`admin/edit-tarif.blade.php`)

**Status**: ✅ **SUDAH ADA DAN LENGKAP**

**Fitur**:
- Form edit dengan 2 field:
  - `satu_jam_pertama` (Tarif Jam Pertama)
  - `tarif_parkir_per_jam` (Tarif Per Jam Berikutnya)
- Validasi client-side (min: 0, required)
- Submit ke `POST /admin/tarif/{id}`
- Tombol Cancel kembali ke halaman tarif

---

### 4. Mobile App - Integrasi Tarif

#### Alur Pengambilan Tarif

```
1. User memilih mall di Map Page
   ↓
2. Navigate ke Booking Page dengan mall data
   ↓
3. BookingProvider.initialize(mallData)
   - Cek apakah mallData sudah punya 'firstHourRate' dan 'additionalHourRate'
   - Jika ada: gunakan langsung
   - Jika tidak: gunakan default (5000, 3000)
   ↓
4. User memilih kendaraan
   ↓
5. BookingProvider bisa memanggil updateTariff() untuk update tarif spesifik
   ↓
6. CostCalculator menghitung biaya berdasarkan tarif
```

#### File Terkait

**BookingProvider** (`lib/logic/providers/booking_provider.dart`):
```dart
// Default tariff
double _firstHourRate = 5000.0;
double _additionalHourRate = 3000.0;

// Initialize with mall data
void initialize(Map<String, dynamic> mallData, {String? token}) {
  // Extract tariff from mall data if available
  if (mallData['firstHourRate'] != null) {
    _firstHourRate = _parseDouble(mallData['firstHourRate']);
  }
  if (mallData['additionalHourRate'] != null) {
    _additionalHourRate = _parseDouble(mallData['additionalHourRate']);
  }
}

// Update tariff (can be called with API data)
void updateTariff({
  required double firstHourRate,
  required double additionalHourRate,
  String? mallId,
  String? vehicleType,
}) {
  _firstHourRate = firstHourRate;
  _additionalHourRate = additionalHourRate;
  calculateCost(); // Recalculate
}
```

**CostCalculator** (`lib/utils/cost_calculator.dart`):
```dart
static double estimateCost({
  required double durationHours,
  required double firstHourRate,
  required double additionalHourRate,
}) {
  if (durationHours <= 1.0) {
    return firstHourRate;
  }
  
  final additionalHours = durationHours - 1.0;
  final totalCost = firstHourRate + (additionalHours * additionalHourRate);
  
  return totalCost;
}
```

**API Endpoint** (Belum Digunakan):
- `GET /api/mall/{id}/tarif` - Mengambil tarif untuk mall tertentu
- Response: Array of tarif per jenis kendaraan

---

## Masalah yang Ditemukan

### 1. ❌ Halaman Edit Tarif Tidak Berfungsi Penuh

**Issue**:
- Route sudah ada: `GET /admin/tarif/{id}/edit`
- Controller method `editTarif()` sudah ada
- View `admin/edit-tarif.blade.php` sudah ada
- **TAPI**: Perlu verifikasi apakah form submit berfungsi dengan benar

**Solusi**: Verifikasi dan perbaiki jika ada bug

### 2. ❌ Mobile App Tidak Mengambil Tarif dari API

**Issue**:
- BookingProvider hanya menggunakan tarif dari `mallData` yang dikirim dari Map Page
- Map Page tidak mengambil tarif dari API `/api/mall/{id}/tarif`
- Jika tarif tidak ada di `mallData`, menggunakan default hardcoded (5000, 3000)

**Solusi**: 
- Option 1: Map Page mengambil tarif saat fetch mall list
- Option 2: Booking Page mengambil tarif saat initialize
- Option 3: Backend menambahkan tarif ke response `/api/mall` (RECOMMENDED)

### 3. ❌ Tarif Tidak Spesifik Per Jenis Kendaraan

**Issue**:
- Database menyimpan tarif per jenis kendaraan (Roda Dua, Tiga, Empat, dll)
- Mobile app hanya menggunakan 1 tarif untuk semua jenis kendaraan
- Tidak ada logika untuk memilih tarif berdasarkan jenis kendaraan user

**Solusi**: Implementasi tarif per jenis kendaraan di mobile app

---

## Rekomendasi Implementasi

### Priority 1: Verifikasi & Fix Edit Tarif (Backend)

**Status**: Perlu dicek apakah sudah berfungsi

**Action Items**:
1. ✅ Verifikasi route `POST /admin/tarif/{id}` berfungsi
2. ✅ Verifikasi `updateTarif()` method menyimpan data dengan benar
3. ✅ Verifikasi riwayat tarif tercatat
4. ✅ Test manual: edit tarif dan cek database

### Priority 2: Integrasi Tarif ke Mobile App

**Option A: Backend Menambahkan Tarif ke Mall API** (RECOMMENDED)

**File**: `qparkin_backend/app/Http/Controllers/Api/MallController.php`

**Perubahan**:
```php
public function index()
{
    // ... existing code ...
    
    ->get()
    ->map(function ($mall) {
        // Get tarif for this mall
        $tarifs = TarifParkir::where('id_mall', $mall->id_mall)->get();
        
        return [
            'id_mall' => $mall->id_mall,
            'nama_mall' => $mall->nama_mall,
            // ... existing fields ...
            'tarif' => $tarifs->map(function($t) {
                return [
                    'jenis_kendaraan' => $t->jenis_kendaraan,
                    'satu_jam_pertama' => (float) $t->satu_jam_pertama,
                    'tarif_parkir_per_jam' => (float) $t->tarif_parkir_per_jam,
                ];
            }),
        ];
    });
}
```

**Option B: Booking Page Fetch Tarif Saat Initialize**

**File**: `qparkin_app/lib/logic/providers/booking_provider.dart`

**Perubahan**:
```dart
Future<void> initialize(Map<String, dynamic> mallData, {String? token}) async {
  // ... existing code ...
  
  // Fetch tarif for this mall
  if (token != null && mallId.isNotEmpty) {
    await _fetchTarifForMall(mallId, token);
  }
}

Future<void> _fetchTarifForMall(String mallId, String token) async {
  try {
    final tarifs = await _bookingService.getTarifForMall(
      mallId: mallId,
      token: token,
    );
    
    // Store tarifs for vehicle type selection
    _tarifs = tarifs;
  } catch (e) {
    debugPrint('[BookingProvider] Error fetching tarif: $e');
  }
}
```

### Priority 3: Tarif Per Jenis Kendaraan

**Implementasi**:
1. Simpan array tarif di BookingProvider
2. Saat user pilih kendaraan, ambil tarif sesuai jenis kendaraan
3. Update `_firstHourRate` dan `_additionalHourRate` berdasarkan jenis kendaraan
4. Recalculate cost

**File**: `qparkin_app/lib/logic/providers/booking_provider.dart`

```dart
// Add field
List<Map<String, dynamic>> _tarifs = [];

void selectVehicle(Map<String, dynamic> vehicle, {String? token}) {
  _selectedVehicle = vehicle;
  
  // Get vehicle type
  final jenisKendaraan = vehicle['jenis_kendaraan'] ?? vehicle['jenis'];
  
  // Find matching tarif
  final tarif = _tarifs.firstWhere(
    (t) => t['jenis_kendaraan'] == jenisKendaraan,
    orElse: () => {},
  );
  
  if (tarif.isNotEmpty) {
    _firstHourRate = _parseDouble(tarif['satu_jam_pertama']);
    _additionalHourRate = _parseDouble(tarif['tarif_parkir_per_jam']);
    
    debugPrint('[BookingProvider] Updated tarif for $jenisKendaraan: $_firstHourRate, $_additionalHourRate');
  }
  
  // Recalculate cost
  if (_bookingDuration != null) {
    calculateCost();
  }
  
  notifyListeners();
}
```

---

## Testing Checklist

### Backend Testing

- [ ] Edit tarif Roda Dua - verify database updated
- [ ] Edit tarif Roda Empat - verify database updated
- [ ] Check riwayat_tarif table has new records
- [ ] Verify tarif tidak bisa negatif (trigger validation)
- [ ] Test API `/api/mall/{id}/tarif` returns correct data

### Mobile App Testing

- [ ] Booking page shows correct tarif for Roda Dua
- [ ] Booking page shows correct tarif for Roda Empat
- [ ] Cost calculation matches tarif
- [ ] Change vehicle type updates tarif and cost
- [ ] Edit tarif di admin → refresh app → tarif updated

---

## Files to Check/Modify

### Backend
- ✅ `app/Models/TarifParkir.php` - Model (sudah ada)
- ✅ `app/Http/Controllers/AdminController.php` - Controller (sudah ada)
- ⚠️ `app/Http/Controllers/Api/MallController.php` - Perlu modifikasi `index()` dan `show()`
- ✅ `resources/views/admin/tarif.blade.php` - View (sudah ada)
- ✅ `resources/views/admin/edit-tarif.blade.php` - View (sudah ada)
- ✅ `routes/web.php` - Routes (sudah ada)
- ✅ `routes/api.php` - Routes (sudah ada)

### Mobile App
- ⚠️ `lib/logic/providers/booking_provider.dart` - Perlu tambah fetch tarif
- ⚠️ `lib/data/services/booking_service.dart` - Perlu tambah `getTarifForMall()`
- ✅ `lib/utils/cost_calculator.dart` - Sudah OK
- ✅ `lib/presentation/widgets/cost_breakdown_card.dart` - Sudah OK

---

## Next Steps

1. **Verifikasi Edit Tarif Backend** - Test manual edit tarif
2. **Implementasi Priority 2** - Pilih Option A atau B
3. **Implementasi Priority 3** - Tarif per jenis kendaraan
4. **Testing End-to-End** - Admin edit tarif → Mobile app update

---

**Status**: Analisis Complete ✅

**Rekomendasi**: Implementasi Option A (Backend menambahkan tarif ke Mall API) karena paling efisien dan konsisten.
