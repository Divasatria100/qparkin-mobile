# Admin Tarif - Panduan Implementasi Lengkap

## Status Saat Ini

### ✅ Yang Sudah Ada (Backend)

1. **Database Schema** - Lengkap
   - Tabel `tarif_parkir` dengan 4 jenis kendaraan
   - Tabel `riwayat_tarif` untuk tracking perubahan
   - Trigger validasi tarif negatif

2. **Backend Routes** - Lengkap
   - `GET /admin/tarif` - Halaman daftar tarif
   - `GET /admin/tarif/{id}/edit` - Halaman edit tarif
   - `POST /admin/tarif/{id}` - Update tarif
   - `GET /api/mall/{id}/tarif` - API get tarif

3. **Controller Methods** - Lengkap
   - `AdminController::tarif()` - Menampilkan daftar tarif
   - `AdminController::editTarif()` - Menampilkan form edit
   - `AdminController::updateTarif()` - Proses update tarif
   - `MallController::getTarif()` - API endpoint

4. **Views** - Lengkap
   - `admin/tarif.blade.php` - Halaman daftar tarif dengan kartu
   - `admin/edit-tarif.blade.php` - Form edit tarif

### ❌ Yang Belum Ada

1. **Mobile App Integration** - Tarif tidak diambil dari API
2. **Tarif Per Jenis Kendaraan** - Mobile app tidak membedakan tarif per jenis kendaraan
3. **Real-time Update** - Perubahan tarif di admin tidak langsung terlihat di mobile

---

## Implementasi Step-by-Step

### Step 1: Verifikasi Backend Edit Tarif

#### Test Manual

1. **Login sebagai Admin Mall**
   ```
   URL: http://localhost:8000/admin/login
   ```

2. **Buka Halaman Tarif**
   ```
   URL: http://localhost:8000/admin/tarif
   ```

3. **Klik Edit pada salah satu kartu tarif**
   ```
   URL: http://localhost:8000/admin/tarif/{id}/edit
   ```

4. **Ubah nilai tarif dan submit**
   - Ubah "Tarif 1 Jam Pertama" dari 5000 → 6000
   - Ubah "Tarif Per Jam Berikutnya" dari 3000 → 4000
   - Klik "Simpan Perubahan"

5. **Verifikasi di Database**
   ```sql
   -- Cek tarif updated
   SELECT * FROM tarif_parkir WHERE id_tarif = {id};
   
   -- Cek riwayat tercatat
   SELECT * FROM riwayat_tarif ORDER BY waktu_perubahan DESC LIMIT 1;
   ```

#### Expected Result

- ✅ Redirect ke `/admin/tarif` dengan success message
- ✅ Tarif di database ter-update
- ✅ Riwayat perubahan tercatat di `riwayat_tarif`
- ✅ Tabel riwayat di halaman tarif menampilkan perubahan terbaru

---

### Step 2: Implementasi Backend - Tambah Tarif ke Mall API

**File**: `qparkin_backend/app/Http/Controllers/Api/MallController.php`

#### Modifikasi Method `index()`

```php
public function index()
{
    try {
        $malls = Mall::where('mall.status', 'active')
            ->select([
                'mall.id_mall',
                'mall.nama_mall',
                'mall.alamat_lengkap',
                'mall.latitude',
                'mall.longitude',
                'mall.google_maps_url',
                'mall.status',
                'mall.kapasitas',
                'mall.has_slot_reservation_enabled'
            ])
            ->leftJoin('parkiran', 'mall.id_mall', '=', 'parkiran.id_mall')
            ->leftJoin('parking_floors', 'parkiran.id_parkiran', '=', 'parking_floors.id_parkiran')
            ->selectRaw('COALESCE(SUM(parking_floors.available_slots), 0) as available_slots')
            ->where('parkiran.status', '=', 'Tersedia')
            ->groupBy(
                'mall.id_mall',
                'mall.nama_mall',
                'mall.alamat_lengkap',
                'mall.latitude',
                'mall.longitude',
                'mall.google_maps_url',
                'mall.status',
                'mall.kapasitas',
                'mall.has_slot_reservation_enabled'
            )
            ->get()
            ->map(function ($mall) {
                // ✅ TAMBAHAN: Get tarif for this mall
                $tarifs = \App\Models\TarifParkir::where('id_mall', $mall->id_mall)
                    ->select(['jenis_kendaraan', 'satu_jam_pertama', 'tarif_parkir_per_jam'])
                    ->get()
                    ->map(function($tarif) {
                        return [
                            'jenis_kendaraan' => $tarif->jenis_kendaraan,
                            'satu_jam_pertama' => (float) $tarif->satu_jam_pertama,
                            'tarif_parkir_per_jam' => (float) $tarif->tarif_parkir_per_jam,
                        ];
                    });

                return [
                    'id_mall' => $mall->id_mall,
                    'nama_mall' => $mall->nama_mall,
                    'alamat_lengkap' => $mall->alamat_lengkap,
                    'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                    'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                    'google_maps_url' => $mall->google_maps_url,
                    'status' => $mall->status,
                    'kapasitas' => $mall->kapasitas,
                    'available_slots' => (int) $mall->available_slots,
                    'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                    'tarif' => $tarifs, // ✅ TAMBAHAN
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Malls retrieved successfully',
            'data' => $malls
        ]);
    } catch (\Exception $e) {
        \Log::error('Error fetching malls: ' . $e->getMessage());
        \Log::error('Stack trace: ' . $e->getTraceAsString());
        
        return response()->json([
            'success' => false,
            'message' => 'Failed to fetch malls',
            'error' => $e->getMessage()
        ], 500);
    }
}
```

#### Modifikasi Method `show()`

```php
public function show($id)
{
    try {
        $mall = Mall::where('status', 'active')->findOrFail($id);

        $availableSlots = $mall->parkiran()
            ->where('status', 'Tersedia')
            ->count();

        // ✅ TAMBAHAN: Get tarif
        $tarifs = \App\Models\TarifParkir::where('id_mall', $id)
            ->select(['jenis_kendaraan', 'satu_jam_pertama', 'tarif_parkir_per_jam'])
            ->get()
            ->map(function($tarif) {
                return [
                    'jenis_kendaraan' => $tarif->jenis_kendaraan,
                    'satu_jam_pertama' => (float) $tarif->satu_jam_pertama,
                    'tarif_parkir_per_jam' => (float) $tarif->tarif_parkir_per_jam,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Mall details retrieved successfully',
            'data' => [
                'id_mall' => $mall->id_mall,
                'nama_mall' => $mall->nama_mall,
                'alamat_lengkap' => $mall->alamat_lengkap,
                'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                'google_maps_url' => $mall->google_maps_url,
                'status' => $mall->status,
                'kapasitas' => $mall->kapasitas,
                'available_slots' => $availableSlots,
                'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                'parkiran' => $mall->parkiran,
                'tarif' => $tarifs, // ✅ TAMBAHAN
            ]
        ]);
    } catch (\Exception $e) {
        \Log::error('Error fetching mall details: ' . $e->getMessage());
        
        return response()->json([
            'success' => false,
            'message' => 'Mall not found',
            'error' => $e->getMessage()
        ], 404);
    }
}
```

#### Test API Response

```bash
curl -X GET "http://localhost:8000/api/mall" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Mall A",
      "tarif": [
        {
          "jenis_kendaraan": "Roda Dua",
          "satu_jam_pertama": 2000,
          "tarif_parkir_per_jam": 1000
        },
        {
          "jenis_kendaraan": "Roda Empat",
          "satu_jam_pertama": 5000,
          "tarif_parkir_per_jam": 3000
        }
      ]
    }
  ]
}
```

---

### Step 3: Implementasi Mobile App - Tarif Per Jenis Kendaraan

#### File 1: `qparkin_app/lib/logic/providers/booking_provider.dart`

**Tambahkan field untuk menyimpan tarif**:

```dart
// Tariff data (fetched from mall data or API)
double _firstHourRate = 5000.0; // Default values
double _additionalHourRate = 3000.0;

// ✅ TAMBAHAN: Store all tarifs for vehicle type selection
List<Map<String, dynamic>> _tarifs = [];
```

**Modifikasi method `initialize()`**:

```dart
Future<void> initialize(Map<String, dynamic> mallData, {String? token}) async {
  debugPrint('[BookingProvider] Initializing with mall: ${mallData['name']}');

  // Cache mall data
  final mallId = mallData['id_mall']?.toString() ?? mallData['id']?.toString() ?? '';
  if (mallId.isNotEmpty) {
    _cacheMallData(mallId, mallData);
  }

  _selectedMall = mallData;

  // Fetch parkiran ID for this mall (required for booking)
  if (token != null && mallId.isNotEmpty) {
    await _fetchParkiranForMall(mallId, token);
  }

  // Set default start time to current time + 15 minutes
  _startTime = DateTime.now().add(const Duration(minutes: 15));

  // ✅ TAMBAHAN: Extract tarif data from mall
  if (mallData['tarif'] != null && mallData['tarif'] is List) {
    _tarifs = List<Map<String, dynamic>>.from(mallData['tarif']);
    debugPrint('[BookingProvider] Loaded ${_tarifs.length} tarifs from mall data');
  }

  // Extract tariff data from mall if available (backward compatibility)
  if (mallData['firstHourRate'] != null) {
    _firstHourRate = _parseDouble(mallData['firstHourRate']);
  }
  if (mallData['additionalHourRate'] != null) {
    _additionalHourRate = _parseDouble(mallData['additionalHourRate']);
  }

  // Set initial available slots from mall data if available
  if (mallData['available'] != null) {
    _availableSlots = _parseInt(mallData['available']);
  }

  // Clear any previous state
  _selectedVehicle = null;
  _bookingDuration = null;
  _estimatedCost = 0.0;
  _costBreakdown = null;
  _errorMessage = null;
  _validationErrors = {};
  _createdBooking = null;

  debugPrint('[BookingProvider] Initialized - Start time: $_startTime');
  notifyListeners();
}
```

**Modifikasi method `selectVehicle()`**:

```dart
void selectVehicle(Map<String, dynamic> vehicle, {String? token}) {
  debugPrint('[BookingProvider] Selecting vehicle: ${vehicle['plat_nomor']}');

  _selectedVehicle = vehicle;

  // Validate vehicle selection
  final vehicleId = vehicle['id_kendaraan']?.toString();
  final error = BookingValidator.validateVehicle(vehicleId);

  if (error != null) {
    _validationErrors['vehicleId'] = error;
  } else {
    _validationErrors.remove('vehicleId');
  }

  // ✅ TAMBAHAN: Update tarif based on vehicle type
  final jenisKendaraan = vehicle['jenis_kendaraan']?.toString() ?? 
                         vehicle['jenis']?.toString();
  
  if (jenisKendaraan != null && jenisKendaraan.isNotEmpty && _tarifs.isNotEmpty) {
    // Find matching tarif for this vehicle type
    final matchingTarif = _tarifs.firstWhere(
      (tarif) => tarif['jenis_kendaraan'] == jenisKendaraan,
      orElse: () => <String, dynamic>{},
    );
    
    if (matchingTarif.isNotEmpty) {
      _firstHourRate = _parseDouble(matchingTarif['satu_jam_pertama']);
      _additionalHourRate = _parseDouble(matchingTarif['tarif_parkir_per_jam']);
      
      debugPrint('[BookingProvider] Updated tarif for $jenisKendaraan:');
      debugPrint('[BookingProvider]   First hour: Rp $_firstHourRate');
      debugPrint('[BookingProvider]   Additional: Rp $_additionalHourRate');
    } else {
      debugPrint('[BookingProvider] No tarif found for $jenisKendaraan, using default');
    }
  }

  // Reset floor and slot selection when vehicle changes
  _selectedFloor = null;
  _reservedSlot = null;
  _slotsVisualization = [];

  // Filter floors by vehicle type if slot reservation is enabled
  if (isSlotReservationEnabled && token != null) {
    if (jenisKendaraan != null && jenisKendaraan.isNotEmpty) {
      debugPrint('[BookingProvider] Filtering floors for vehicle type: $jenisKendaraan');
      loadFloorsForVehicle(jenisKendaraan: jenisKendaraan, token: token);
    }
  }

  // Recalculate cost if duration is already set
  if (_bookingDuration != null) {
    calculateCost();
  }

  notifyListeners();
}
```

**Tambahkan getter untuk tarifs**:

```dart
// Getters
Map<String, dynamic>? get selectedMall => _selectedMall;
Map<String, dynamic>? get selectedVehicle => _selectedVehicle;
// ... existing getters ...

// ✅ TAMBAHAN: Getter for tarifs
List<Map<String, dynamic>> get tarifs => _tarifs;

// ✅ TAMBAHAN: Get tarif for specific vehicle type
Map<String, dynamic>? getTarifForVehicleType(String jenisKendaraan) {
  if (_tarifs.isEmpty) return null;
  
  try {
    return _tarifs.firstWhere(
      (tarif) => tarif['jenis_kendaraan'] == jenisKendaraan,
    );
  } catch (e) {
    return null;
  }
}
```

---

### Step 4: Testing End-to-End

#### Test Scenario 1: Edit Tarif di Admin

1. **Login sebagai Admin Mall**
2. **Buka halaman Tarif** (`/admin/tarif`)
3. **Edit tarif Roda Empat**:
   - Jam Pertama: 5000 → 7000
   - Per Jam: 3000 → 4000
4. **Simpan perubahan**
5. **Verifikasi**:
   - Success message muncul
   - Kartu tarif menampilkan nilai baru
   - Riwayat perubahan tercatat

#### Test Scenario 2: Mobile App Menggunakan Tarif Baru

1. **Restart Flutter app** (atau refresh data)
2. **Pilih mall yang tarifnya diubah**
3. **Pilih kendaraan Roda Empat**
4. **Pilih durasi 3 jam**
5. **Verifikasi perhitungan**:
   - Jam Pertama: Rp 7.000
   - 2 Jam Berikutnya: Rp 8.000 (2 × 4.000)
   - Total: Rp 15.000

#### Test Scenario 3: Tarif Berbeda Per Jenis Kendaraan

1. **Pilih kendaraan Roda Dua**
2. **Pilih durasi 3 jam**
3. **Catat biaya** (misal: Rp 4.000)
4. **Ganti ke kendaraan Roda Empat**
5. **Verifikasi biaya berubah** (misal: Rp 15.000)

---

## API Response Format

### GET /api/mall

```json
{
  "success": true,
  "message": "Malls retrieved successfully",
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Grand Mall",
      "alamat_lengkap": "Jl. Sudirman No. 123",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "available_slots": 50,
      "tarif": [
        {
          "jenis_kendaraan": "Roda Dua",
          "satu_jam_pertama": 2000.0,
          "tarif_parkir_per_jam": 1000.0
        },
        {
          "jenis_kendaraan": "Roda Tiga",
          "satu_jam_pertama": 3000.0,
          "tarif_parkir_per_jam": 2000.0
        },
        {
          "jenis_kendaraan": "Roda Empat",
          "satu_jam_pertama": 5000.0,
          "tarif_parkir_per_jam": 3000.0
        },
        {
          "jenis_kendaraan": "Lebih dari Enam",
          "satu_jam_pertama": 15000.0,
          "tarif_parkir_per_jam": 8000.0
        }
      ]
    }
  ]
}
```

---

## Files Modified

### Backend
1. ✅ `qparkin_backend/app/Http/Controllers/Api/MallController.php`
   - Modified `index()` method
   - Modified `show()` method

### Mobile App
1. ✅ `qparkin_app/lib/logic/providers/booking_provider.dart`
   - Added `_tarifs` field
   - Modified `initialize()` method
   - Modified `selectVehicle()` method
   - Added `getTarifForVehicleType()` method

---

## Testing Checklist

### Backend
- [ ] Edit tarif Roda Dua - database updated
- [ ] Edit tarif Roda Empat - database updated
- [ ] Riwayat tarif tercatat
- [ ] API `/api/mall` returns tarif array
- [ ] API `/api/mall/{id}` returns tarif array

### Mobile App
- [ ] Mall list includes tarif data
- [ ] Booking page loads tarif from mall data
- [ ] Select Roda Dua - shows correct tarif
- [ ] Select Roda Empat - shows correct tarif
- [ ] Cost calculation uses correct tarif
- [ ] Change vehicle type updates cost

### Integration
- [ ] Edit tarif di admin → API returns new tarif
- [ ] Restart app → new tarif loaded
- [ ] Booking uses new tarif for cost calculation

---

## Troubleshooting

### Issue: Tarif tidak muncul di API response

**Check**:
```sql
SELECT * FROM tarif_parkir WHERE id_mall = 1;
```

**Solution**: Pastikan setiap mall memiliki 4 tarif (Roda Dua, Tiga, Empat, Lebih dari Enam)

### Issue: Mobile app masih menggunakan tarif default

**Check**: Log di Flutter console
```
[BookingProvider] Loaded X tarifs from mall data
[BookingProvider] Updated tarif for Roda Empat:
[BookingProvider]   First hour: Rp 5000
[BookingProvider]   Additional: Rp 3000
```

**Solution**: Pastikan mall data dari API sudah include tarif

### Issue: Cost calculation salah

**Check**: 
- Tarif di database
- Log perhitungan di `CostCalculator`
- Jenis kendaraan yang dipilih

---

## Next Steps

1. ✅ Implementasi backend (Step 2)
2. ✅ Implementasi mobile app (Step 3)
3. ✅ Testing end-to-end (Step 4)
4. 📝 Dokumentasi untuk user (cara edit tarif)
5. 📝 Training untuk admin mall

---

**Status**: Ready for Implementation ✅

**Estimated Time**: 2-3 hours
