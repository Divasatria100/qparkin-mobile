# Audit Tambahan: Integrasi Data Mall dengan Mobile App

## Executive Summary

**Status Integrasi: ⚠️ TIDAK SIAP UNTUK PRODUKSI**

Setelah admin mall disetujui oleh super admin, data mall **TIDAK OTOMATIS TERSEDIA** untuk aplikasi mobile karena:

1. **API Mall Controller kosong** - Tidak mengembalikan data real dari database
2. **Field koordinat tidak ada** - Database hanya punya `alamat_gmaps` (URL), bukan latitude/longitude
3. **Mobile app menggunakan dummy data** - MapProvider tidak memanggil API
4. **Google Maps URL tidak mencukupi** - Perlu parsing dan validasi tambahan
5. **Approve flow tidak lengkap** - Tidak menyimpan koordinat saat membuat mall

---

## 1. Analisis Alur Data: Backend → Mobile App

### 1.1 Alur yang Diharapkan

```
Admin Mall Registration
    ↓
Super Admin Approve
    ↓
Mall Created in Database (with coordinates)
    ↓
Mobile App calls GET /api/mall
    ↓
MapProvider loads mall data
    ↓
map_page.dart displays malls on map
```

### 1.2 Alur yang Sebenarnya Terjadi

```
Admin Mall Registration
    ↓
Super Admin Approve
    ↓
Mall Created (WITHOUT coordinates) ❌
    ↓
Mobile App calls GET /api/mall
    ↓
API returns empty array [] ❌
    ↓
MapProvider uses dummy data ❌
    ↓
map_page.dart shows dummy malls (not real data)
```

---

## 2. Masalah Kritis yang Ditemukan

### MASALAH #13: API Mall Controller Tidak Implementasi

**Lokasi:** `qparkin_backend/app/Http/Controllers/Api/MallController.php`

**Deskripsi:**
```php
public function index()
{
    return response()->json([
        'success' => true,
        'data' => []  // ← SELALU KOSONG!
    ]);
}
```

**Dampak:** Mobile app tidak pernah mendapat data mall real dari database

**Prioritas:** CRITICAL



### MASALAH #14: Database Mall Tidak Punya Field Koordinat

**Lokasi:** `qparkin_backend/database/migrations/2025_09_24_151026_mall.php`

**Struktur Tabel Saat Ini:**
```php
Schema::create('mall', function (Blueprint $table) {
    $table->id('id_mall');
    $table->string('nama_mall', 100)->nullable();
    $table->string('lokasi', 255)->nullable();
    $table->integer('kapasitas')->nullable();
    $table->string('alamat_gmaps', 255)->nullable();  // ← Hanya URL!
    $table->boolean('has_slot_reservation_enabled')->default(false);
    $table->timestamps();
});
```

**Yang Kurang:**
- `latitude` (decimal 10,8) - Koordinat lintang
- `longitude` (decimal 11,8) - Koordinat bujur

**Dampak:** 
- Mobile app tidak bisa menampilkan marker di peta
- Tidak bisa menghitung rute
- Harus parsing URL Google Maps (tidak reliable)

**Prioritas:** CRITICAL

---

### MASALAH #15: Mobile App Menggunakan Dummy Data

**Lokasi:** `qparkin_app/lib/logic/providers/map_provider.dart` line 200-220

**Kode Saat Ini:**
```dart
Future<void> loadMalls() async {
  try {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // TODO: Replace with API call when backend is ready
    _malls = getDummyMalls();  // ← DUMMY DATA!

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    // error handling
  }
}
```

**Dampak:** 
- Mall yang baru diapprove tidak muncul di app
- User melihat data palsu, bukan data real
- Testing tidak akurat

**Prioritas:** CRITICAL

---

### MASALAH #16: Google Maps URL Tidak Mencukupi untuk PBL

**Lokasi:** Database field `alamat_gmaps`

**Format Saat Ini:**
```
https://maps.google.com/?q=1.1191,104.0538
```

**Masalah:**
1. **Parsing Tidak Reliable:**
   - Format URL bisa berubah (Google Maps punya banyak format)
   - Regex parsing bisa gagal jika format berbeda
   - Tidak ada validasi koordinat

2. **Tidak Efisien:**
   - Harus parsing setiap kali load data
   - Overhead processing di mobile app
   - Potensi error jika URL malformed

3. **Tidak Sesuai Best Practice:**
   - Database seharusnya simpan data terstruktur (lat/lng), bukan URL
   - URL adalah representasi, bukan data mentah
   - Sulit untuk query berdasarkan lokasi (nearby search, radius)

4. **Tidak Mendukung Fitur Lanjutan:**
   - Tidak bisa sort by distance
   - Tidak bisa filter by radius
   - Tidak bisa geospatial indexing

**Rekomendasi:** Simpan latitude dan longitude sebagai field terpisah

**Prioritas:** HIGH

---

### MASALAH #17: Approve Flow Tidak Menyimpan Koordinat

**Lokasi:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php` (dari audit sebelumnya)

**Kode yang Direkomendasikan (belum diimplementasi):**
```php
$mall = Mall::create([
    'nama_mall' => $user->requested_mall_name,
    'lokasi' => $user->requested_mall_location,
    'alamat_gmaps' => $user->requested_mall_latitude && $user->requested_mall_longitude 
        ? "https://maps.google.com/?q={$user->requested_mall_latitude},{$user->requested_mall_longitude}"
        : null,
    // ... other fields
]);
```

**Masalah:**
- Tidak ada field `latitude` dan `longitude` di tabel mall
- Koordinat dari form registrasi hilang
- Mall dibuat tanpa koordinat yang valid

**Prioritas:** CRITICAL



---

## 3. Evaluasi: Apakah Google Maps URL Mencukupi untuk PBL?

### 3.1 Analisis Kebutuhan PBL

**Fitur yang Dibutuhkan:**
1. ✅ Tampilkan mall di peta
2. ✅ Hitung rute dari lokasi user ke mall
3. ✅ Tampilkan jarak dan estimasi waktu
4. ⚠️ Sort mall berdasarkan jarak terdekat
5. ⚠️ Filter mall dalam radius tertentu
6. ❌ Geospatial query (nearby search)
7. ❌ Optimasi performa dengan spatial index

### 3.2 Kesimpulan

**Google Maps URL TIDAK MENCUKUPI untuk kebutuhan PBL yang optimal.**

**Alasan:**
1. **Parsing Overhead:** Setiap kali load data, harus parsing URL
2. **Error Prone:** Regex parsing bisa gagal dengan format URL berbeda
3. **Tidak Scalable:** Sulit untuk query geospatial di database
4. **Tidak Best Practice:** Database seharusnya simpan data terstruktur

**Rekomendasi:** Gunakan field `latitude` dan `longitude` terpisah

---

## 4. Solusi: Penyesuaian Backend untuk Integrasi Mobile

### FASE 1: Update Database Schema

#### Step 1.1: Buat Migration Baru untuk Koordinat

**File:** `qparkin_backend/database/migrations/2026_01_XX_add_coordinates_to_mall_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            // Tambah field koordinat untuk mobile app
            $table->decimal('latitude', 10, 8)->nullable()->after('lokasi');
            $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
            
            // Index untuk geospatial query (optional, untuk performa)
            $table->index(['latitude', 'longitude'], 'idx_mall_coordinates');
        });
    }

    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            $table->dropIndex('idx_mall_coordinates');
            $table->dropColumn(['latitude', 'longitude']);
        });
    }
};
```

**Jalankan:**
```bash
php artisan make:migration add_coordinates_to_mall_table
# Copy kode di atas ke file migration
php artisan migrate
```

#### Step 1.2: Update Model Mall

**File:** `qparkin_backend/app/Models/Mall.php`

```php
protected $fillable = [
    'nama_mall',
    'lokasi',
    'latitude',      // ← TAMBAH
    'longitude',     // ← TAMBAH
    'kapasitas',
    'alamat_gmaps',
    'has_slot_reservation_enabled'
];

protected $casts = [
    'latitude' => 'decimal:8',
    'longitude' => 'decimal:8',
    'has_slot_reservation_enabled' => 'boolean',
];

// Helper method untuk generate Google Maps URL
public function getGoogleMapsUrlAttribute()
{
    if ($this->latitude && $this->longitude) {
        return "https://maps.google.com/?q={$this->latitude},{$this->longitude}";
    }
    return $this->alamat_gmaps;
}

// Helper method untuk validasi koordinat
public function hasValidCoordinates()
{
    return $this->latitude !== null 
        && $this->longitude !== null
        && $this->latitude >= -90 
        && $this->latitude <= 90
        && $this->longitude >= -180 
        && $this->longitude <= 180;
}
```



### FASE 2: Implementasi API Mall Controller

#### Step 2.1: Implementasi Method index()

**File:** `qparkin_backend/app/Http/Controllers/Api/MallController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mall;
use App\Models\Parkiran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MallController extends Controller
{
    /**
     * Get all malls with parking availability
     * 
     * Returns list of malls with:
     * - Basic info (id, name, address, coordinates)
     * - Available parking slots count
     * - Slot reservation feature flag
     * 
     * Mobile app uses this to display malls on map
     */
    public function index()
    {
        try {
            $malls = Mall::select([
                    'mall.id_mall',
                    'mall.nama_mall',
                    'mall.lokasi',
                    'mall.latitude',
                    'mall.longitude',
                    'mall.kapasitas',
                    'mall.alamat_gmaps',
                    'mall.has_slot_reservation_enabled'
                ])
                ->leftJoin('parkiran', 'mall.id_mall', '=', 'parkiran.id_mall')
                ->selectRaw('COUNT(CASE WHEN parkiran.status = "tersedia" THEN 1 END) as available_slots')
                ->groupBy(
                    'mall.id_mall',
                    'mall.nama_mall',
                    'mall.lokasi',
                    'mall.latitude',
                    'mall.longitude',
                    'mall.kapasitas',
                    'mall.alamat_gmaps',
                    'mall.has_slot_reservation_enabled'
                )
                ->get()
                ->map(function ($mall) {
                    return [
                        'id_mall' => $mall->id_mall,
                        'nama_mall' => $mall->nama_mall,
                        'lokasi' => $mall->lokasi,
                        'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                        'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                        'kapasitas' => $mall->kapasitas,
                        'available_slots' => $mall->available_slots ?? 0,
                        'alamat_gmaps' => $mall->alamat_gmaps,
                        'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                    ];
                });

            return response()->json([
                'success' => true,
                'message' => 'Malls retrieved successfully',
                'data' => $malls
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching malls: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch malls',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get single mall details
     */
    public function show($id)
    {
        try {
            $mall = Mall::with(['parkiran', 'tarifParkir'])
                ->findOrFail($id);

            $availableSlots = $mall->parkiran()
                ->where('status', 'tersedia')
                ->count();

            return response()->json([
                'success' => true,
                'message' => 'Mall details retrieved successfully',
                'data' => [
                    'id_mall' => $mall->id_mall,
                    'nama_mall' => $mall->nama_mall,
                    'lokasi' => $mall->lokasi,
                    'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                    'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                    'kapasitas' => $mall->kapasitas,
                    'available_slots' => $availableSlots,
                    'alamat_gmaps' => $mall->alamat_gmaps,
                    'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                    'parkiran' => $mall->parkiran,
                    'tarif' => $mall->tarifParkir,
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

    /**
     * Get parking areas for a mall
     */
    public function getParkiran($id)
    {
        try {
            $mall = Mall::findOrFail($id);
            $parkiran = $mall->parkiran()
                ->select([
                    'id_parkiran',
                    'nama_parkiran',
                    'lantai',
                    'kapasitas',
                    'status'
                ])
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Parking areas retrieved successfully',
                'data' => $parkiran
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching parking areas: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch parking areas',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get parking rates for a mall
     */
    public function getTarif($id)
    {
        try {
            $mall = Mall::findOrFail($id);
            $tarif = $mall->tarifParkir()
                ->select([
                    'id_tarif',
                    'jenis_kendaraan',
                    'tarif_per_jam',
                    'tarif_maksimal'
                ])
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
}
```



### FASE 3: Update Approve Flow untuk Menyimpan Koordinat

#### Step 3.1: Update SuperAdminController::approvePengajuan()

**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

```php
public function approvePengajuan(Request $request, $id)
{
    DB::beginTransaction();
    try {
        $user = User::findOrFail($id);
        
        if ($user->application_status !== 'pending') {
            return back()->withErrors(['error' => 'Pengajuan ini sudah diproses sebelumnya.']);
        }
        
        // 1. Buat Mall baru DENGAN KOORDINAT
        $mall = Mall::create([
            'nama_mall' => $user->requested_mall_name,
            'lokasi' => $user->requested_mall_location,
            'latitude' => $user->requested_mall_latitude,      // ← PENTING!
            'longitude' => $user->requested_mall_longitude,    // ← PENTING!
            'alamat_gmaps' => $user->requested_mall_latitude && $user->requested_mall_longitude 
                ? "https://maps.google.com/?q={$user->requested_mall_latitude},{$user->requested_mall_longitude}"
                : null,
            'kapasitas' => 100,
            'has_slot_reservation_enabled' => false,
        ]);
        
        // Validasi koordinat
        if (!$mall->hasValidCoordinates()) {
            throw new \Exception('Koordinat mall tidak valid');
        }
        
        // 2. Update user menjadi admin_mall
        $user->update([
            'role' => 'admin_mall',
            'status' => 'active',
            'application_status' => 'approved',
            'reviewed_at' => now(),
            'reviewed_by' => Auth::id(),
        ]);
        
        // 3. Buat entry di admin_mall
        AdminMall::create([
            'id_user' => $user->id_user,
            'id_mall' => $mall->id_mall,
            'hak_akses' => 'full',
        ]);
        
        // 4. TODO: Kirim email notifikasi
        
        DB::commit();
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Pengajuan berhasil disetujui',
                'data' => [
                    'mall_id' => $mall->id_mall,
                    'mall_name' => $mall->nama_mall,
                    'coordinates' => [
                        'latitude' => $mall->latitude,
                        'longitude' => $mall->longitude
                    ]
                ]
            ]);
        }
        
        return redirect()->route('superadmin.pengajuan')
            ->with('success', 'Pengajuan berhasil disetujui. Mall telah ditambahkan dengan koordinat.');
            
    } catch (\Exception $e) {
        DB::rollBack();
        \Log::error('Error approving application: ' . $e->getMessage());
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
        
        return back()->withErrors(['error' => 'Gagal menyetujui pengajuan: ' . $e->getMessage()]);
    }
}
```

### FASE 4: Update Mobile App untuk Konsumsi API Real

#### Step 4.1: Buat Mall Service

**File:** `qparkin_app/lib/data/services/mall_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mall_model.dart';

class MallService {
  final String baseUrl;
  
  MallService({required this.baseUrl});
  
  /// Fetch all malls from API
  /// 
  /// Returns list of malls with coordinates and availability
  Future<List<MallModel>> fetchMalls() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mall'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final mallsData = jsonData['data'] as List<dynamic>;
          
          return mallsData
              .map((json) => MallModel.fromJson(json))
              .where((mall) => mall.validate()) // Filter invalid data
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load malls: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching malls: $e');
    }
  }
  
  /// Fetch single mall details
  Future<MallModel> fetchMallDetails(String mallId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mall/$mallId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return MallModel.fromJson(jsonData['data']);
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load mall details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching mall details: $e');
    }
  }
}
```



#### Step 4.2: Update MapProvider untuk Gunakan API Real

**File:** `qparkin_app/lib/logic/providers/map_provider.dart`

Ganti method `loadMalls()` (line ~200):

```dart
import '../../data/services/mall_service.dart';

class MapProvider extends ChangeNotifier {
  final LocationService _locationService;
  final RouteService _routeService;
  final search.SearchService _searchService;
  final MallService _mallService;  // ← TAMBAH

  // ... existing code ...

  MapProvider({
    LocationService? locationService,
    RouteService? routeService,
    search.SearchService? searchService,
    MallService? mallService,  // ← TAMBAH
  })  : _locationService = locationService ?? LocationService(),
        _routeService = routeService ?? RouteService(),
        _searchService = searchService ?? search.SearchService(),
        _mallService = mallService ?? MallService(
          baseUrl: const String.fromEnvironment('API_URL', 
            defaultValue: 'http://192.168.1.100:8000')
        );

  /// Load mall data from backend API
  ///
  /// Fetches real mall data from Laravel backend.
  /// Falls back to dummy data if API call fails (for development).
  Future<void> loadMalls() async {
    debugPrint('[MapProvider] Loading malls from API...');

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Fetch from API
      _malls = await _mallService.fetchMalls();

      debugPrint('[MapProvider] Loaded ${_malls.length} malls from API');

      // Validate all malls have coordinates
      final invalidMalls = _malls.where((m) => !m.validate()).toList();
      if (invalidMalls.isNotEmpty) {
        debugPrint('[MapProvider] Warning: ${invalidMalls.length} malls have invalid data');
        _malls.removeWhere((m) => !m.validate());
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[MapProvider] Error loading malls from API: $e');
      
      // Fallback to dummy data for development
      debugPrint('[MapProvider] Falling back to dummy data');
      _malls = getDummyMalls();
      
      _isLoading = false;
      _errorMessage = 'Menggunakan data demo. Koneksi ke server gagal.';
      
      _logger.logError(
        'MALL_LOAD_ERROR',
        e.toString(),
        'MapProvider.loadMalls',
      );
      
      notifyListeners();
      // Don't rethrow - allow app to continue with dummy data
    }
  }
}
```

#### Step 4.3: Update MallModel untuk Handle API Response

**File:** `qparkin_app/lib/data/models/mall_model.dart`

Update method `fromJson()` (line ~170):

```dart
factory MallModel.fromJson(Map<String, dynamic> json) {
  return MallModel(
    id: json['id']?.toString() ?? json['id_mall']?.toString() ?? '',
    name: json['name']?.toString() ?? json['nama_mall']?.toString() ?? '',
    address: json['address']?.toString() ?? json['lokasi']?.toString() ?? '',
    
    // Use latitude/longitude from API (preferred)
    // Fallback to parsing alamat_gmaps if coordinates not available
    latitude: _parseDouble(json['latitude']) != 0.0 
        ? _parseDouble(json['latitude'])
        : _parseGoogleMapsUrl(json['alamat_gmaps'] ?? '').$1,
    
    longitude: _parseDouble(json['longitude']) != 0.0
        ? _parseDouble(json['longitude'])
        : _parseGoogleMapsUrl(json['alamat_gmaps'] ?? '').$2,
    
    availableSlots: _parseInt(json['available_slots'] ?? json['kapasitas']),
    distance: json['distance']?.toString() ?? '',
    hasSlotReservationEnabled: json['has_slot_reservation_enabled'] == true ||
        json['has_slot_reservation_enabled'] == 1,
  );
}

/// Parse Google Maps URL to extract coordinates
/// 
/// Supports formats:
/// - https://maps.google.com/?q=1.1191,104.0538
/// - https://www.google.com/maps?q=1.1191,104.0538
/// - https://goo.gl/maps/... (not supported, returns 0,0)
static (double, double) _parseGoogleMapsUrl(String url) {
  if (url.isEmpty) return (0.0, 0.0);
  
  try {
    // Pattern: q=latitude,longitude
    final regex = RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
    final match = regex.firstMatch(url);
    
    if (match != null && match.groupCount >= 2) {
      final lat = double.tryParse(match.group(1) ?? '') ?? 0.0;
      final lng = double.tryParse(match.group(2) ?? '') ?? 0.0;
      
      // Validate coordinates
      if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
        return (lat, lng);
      }
    }
  } catch (e) {
    debugPrint('[MallModel] Error parsing Google Maps URL: $e');
  }
  
  return (0.0, 0.0);
}
```



---

## 5. Checklist Implementasi Integrasi Mobile

### Phase 1: Database & Backend API (60 menit)

**Database Schema:**
- [ ] Buat migration untuk tambah field `latitude` dan `longitude` ke tabel `mall`
- [ ] Jalankan migration: `php artisan migrate`
- [ ] Update Model Mall - tambah field ke `$fillable` dan `$casts`
- [ ] Tambah helper methods: `getGoogleMapsUrlAttribute()` dan `hasValidCoordinates()`
- [ ] Test: `php artisan tinker` → cek struktur tabel mall

**API Implementation:**
- [ ] Update `MallController::index()` - implementasi query dengan available_slots
- [ ] Update `MallController::show()` - implementasi detail mall
- [ ] Update `MallController::getParkiran()` - implementasi list parkiran
- [ ] Update `MallController::getTarif()` - implementasi list tarif
- [ ] Test API: `curl http://localhost:8000/api/mall` → harus return data real
- [ ] Verifikasi response format sesuai dengan MallModel.fromJson()

**Approve Flow:**
- [ ] Update `SuperAdminController::approvePengajuan()` - simpan latitude & longitude
- [ ] Tambah validasi koordinat dengan `hasValidCoordinates()`
- [ ] Test: Approve pengajuan baru
- [ ] Verifikasi: Cek tabel `mall` - latitude & longitude harus terisi
- [ ] Verifikasi: Call API `/api/mall` - mall baru harus muncul dengan koordinat

### Phase 2: Mobile App Integration (45 menit)

**Mall Service:**
- [ ] Buat file `qparkin_app/lib/data/services/mall_service.dart`
- [ ] Implementasi `fetchMalls()` method
- [ ] Implementasi `fetchMallDetails()` method
- [ ] Tambah error handling dan timeout
- [ ] Test: Run service dengan mock data

**MapProvider Update:**
- [ ] Tambah `MallService` dependency ke MapProvider
- [ ] Update `loadMalls()` - ganti dummy data dengan API call
- [ ] Tambah fallback ke dummy data jika API gagal
- [ ] Update constructor untuk inject MallService
- [ ] Test: Run app dan verifikasi mall data dari API

**MallModel Update:**
- [ ] Tambah method `_parseGoogleMapsUrl()` untuk fallback
- [ ] Update `fromJson()` - prioritaskan latitude/longitude dari API
- [ ] Tambah fallback parsing jika koordinat tidak ada
- [ ] Test: Parse berbagai format response

### Phase 3: Testing End-to-End (30 menit)

**Backend Testing:**
- [ ] Test: Registrasi admin mall dengan koordinat valid
- [ ] Test: Approve pengajuan → mall dibuat dengan koordinat
- [ ] Test: API `/api/mall` return mall baru
- [ ] Test: API `/api/mall/{id}` return detail lengkap
- [ ] Test: Available slots count akurat

**Mobile App Testing:**
- [ ] Test: Launch app → mall list ter-load dari API
- [ ] Test: Tap mall card → marker muncul di peta dengan koordinat benar
- [ ] Test: Tap "Rute" → rute terhitung dengan benar
- [ ] Test: Jarak dan estimasi waktu akurat
- [ ] Test: Booking button → navigate ke booking page dengan data mall

**Integration Testing:**
- [ ] Test: Approve mall baru → refresh app → mall muncul
- [ ] Test: Update available slots → refresh app → count ter-update
- [ ] Test: Mall tanpa koordinat → tidak muncul di app (filtered)
- [ ] Test: Network error → fallback ke dummy data
- [ ] Test: Koordinat invalid → mall di-filter

### Phase 4: Data Migration (Optional, 20 menit)

**Jika sudah ada mall tanpa koordinat:**
- [ ] Buat script untuk parse `alamat_gmaps` existing
- [ ] Update koordinat untuk mall yang sudah ada
- [ ] Validasi semua mall punya koordinat valid
- [ ] Backup database sebelum migration

**Script Migration:**
```php
// qparkin_backend/database/seeders/MallCoordinatesMigrationSeeder.php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Mall;

class MallCoordinatesMigrationSeeder extends Seeder
{
    public function run()
    {
        $malls = Mall::whereNull('latitude')
            ->orWhereNull('longitude')
            ->get();
        
        foreach ($malls as $mall) {
            if ($mall->alamat_gmaps) {
                $coords = $this->parseGoogleMapsUrl($mall->alamat_gmaps);
                
                if ($coords['lat'] && $coords['lng']) {
                    $mall->update([
                        'latitude' => $coords['lat'],
                        'longitude' => $coords['lng']
                    ]);
                    
                    $this->command->info("Updated {$mall->nama_mall}");
                }
            }
        }
    }
    
    private function parseGoogleMapsUrl($url)
    {
        preg_match('/q=(-?\d+\.?\d*),(-?\d+\.?\d*)/', $url, $matches);
        
        return [
            'lat' => $matches[1] ?? null,
            'lng' => $matches[2] ?? null
        ];
    }
}
```

**Jalankan:**
```bash
php artisan db:seed --class=MallCoordinatesMigrationSeeder
```

**Total Estimasi Waktu: 2.5 - 3 jam**

---

## 6. Testing Plan

### 6.1 Unit Testing

**Backend - MallController Test:**
```php
// qparkin_backend/tests/Feature/MallControllerTest.php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Mall;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class MallControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_index_returns_malls_with_coordinates()
    {
        $mall = Mall::factory()->create([
            'nama_mall' => 'Test Mall',
            'latitude' => 1.1191,
            'longitude' => 104.0538,
        ]);

        $response = $this->getJson('/api/mall');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id_mall',
                        'nama_mall',
                        'lokasi',
                        'latitude',
                        'longitude',
                        'available_slots',
                    ]
                ]
            ])
            ->assertJsonFragment([
                'nama_mall' => 'Test Mall',
                'latitude' => 1.1191,
                'longitude' => 104.0538,
            ]);
    }

    public function test_show_returns_mall_details()
    {
        $mall = Mall::factory()->create([
            'latitude' => 1.1191,
            'longitude' => 104.0538,
        ]);

        $response = $this->getJson("/api/mall/{$mall->id_mall}");

        $response->assertStatus(200)
            ->assertJsonPath('data.latitude', 1.1191)
            ->assertJsonPath('data.longitude', 104.0538);
    }
}
```

**Mobile - MallService Test:**
```dart
// qparkin_app/test/services/mall_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:qparkin_app/data/services/mall_service.dart';

void main() {
  group('MallService', () {
    test('fetchMalls returns list of malls', () async {
      final service = MallService(baseUrl: 'http://test.com');
      
      // Mock HTTP response
      final mockResponse = '''
      {
        "success": true,
        "data": [
          {
            "id_mall": "1",
            "nama_mall": "Test Mall",
            "lokasi": "Test Location",
            "latitude": 1.1191,
            "longitude": 104.0538,
            "available_slots": 45
          }
        ]
      }
      ''';
      
      // Test parsing
      final malls = await service.fetchMalls();
      
      expect(malls.length, greaterThan(0));
      expect(malls.first.name, 'Test Mall');
      expect(malls.first.latitude, 1.1191);
      expect(malls.first.longitude, 104.0538);
    });
  });
}
```

### 6.2 Integration Testing

**Complete Flow Test:**
1. Backend: Registrasi admin mall dengan koordinat
2. Backend: Super admin approve → mall created
3. Backend: API call `/api/mall` → verify mall exists
4. Mobile: Launch app → verify mall loaded
5. Mobile: Select mall → verify marker positioned correctly
6. Mobile: Calculate route → verify route drawn
7. Mobile: Tap booking → verify navigation works

### 6.3 Manual Testing Checklist

**Backend API:**
- [ ] GET /api/mall returns all malls with coordinates
- [ ] GET /api/mall/{id} returns single mall details
- [ ] Available slots count is accurate
- [ ] Response format matches mobile app expectations
- [ ] Error handling works (404, 500)

**Mobile App:**
- [ ] Malls load from API on app launch
- [ ] Map markers positioned at correct coordinates
- [ ] Tap mall card → map centers on mall
- [ ] Tap "Rute" → route calculated and displayed
- [ ] Distance and duration displayed correctly
- [ ] Booking button navigates with correct data
- [ ] Network error → fallback to dummy data
- [ ] Invalid coordinates → mall filtered out

**End-to-End:**
- [ ] New mall approved → appears in app after refresh
- [ ] Mall coordinates updated → app shows new position
- [ ] Slot availability changes → app reflects update
- [ ] Multiple malls → all displayed correctly
- [ ] No coordinates → mall not shown (graceful handling)



---

## 7. Rekomendasi Arsitektur untuk Navigasi & Rute

### 7.1 Strategi Navigasi Tanpa Perhitungan Rute Internal

**Pendekatan yang Direkomendasikan untuk PBL:**

#### Opsi 1: Delegasi ke Google Maps (RECOMMENDED)

**Kelebihan:**
- ✅ Tidak perlu implementasi routing engine sendiri
- ✅ Rute selalu akurat dan ter-update
- ✅ Mendukung berbagai mode transportasi
- ✅ Informasi traffic real-time
- ✅ Mudah diimplementasi

**Implementasi:**
```dart
// qparkin_app/lib/utils/navigation_helper.dart
import 'package:url_launcher/url_launcher.dart';

class NavigationHelper {
  /// Open Google Maps with directions to mall
  static Future<void> navigateToMall(MallModel mall) async {
    final lat = mall.latitude;
    final lng = mall.longitude;
    
    // Google Maps URL with directions
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Google Maps');
    }
  }
  
  /// Show route preview in app (using OSM)
  static Future<RouteData> previewRoute(
    GeoPoint origin, 
    GeoPoint destination
  ) async {
    // Use OSRM API for route preview
    final routeService = RouteService();
    return await routeService.calculateRoute(origin, destination);
  }
}
```

**UI Flow:**
1. User tap "Rute" → Show route preview di app (OSM)
2. User tap "Mulai Navigasi" → Open Google Maps
3. Google Maps handle turn-by-turn navigation

#### Opsi 2: Hybrid Approach (BEST FOR PBL)

**Kombinasi OSM untuk preview + Google Maps untuk navigasi:**

```dart
// In map_page.dart
Future<void> _showRouteAndNavigate(MallModel mall) async {
  // 1. Show route preview in app
  await mapProvider.selectMall(mall);
  
  // 2. Show dialog with route info
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Rute ke ${mall.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Jarak: ${mapProvider.currentRoute?.distanceInKm} km'),
          Text('Estimasi: ${mapProvider.currentRoute?.durationInMinutes} menit'),
          SizedBox(height: 16),
          Text('Gunakan Google Maps untuk navigasi turn-by-turn?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Lihat di Peta'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            NavigationHelper.navigateToMall(mall);
          },
          child: Text('Buka Google Maps'),
        ),
      ],
    ),
  );
}
```

### 7.2 Backend Support untuk Navigasi

**Yang Perlu Disediakan Backend:**

1. **Koordinat Akurat:**
   - Latitude & longitude dalam decimal degrees
   - Validasi koordinat dalam range valid
   - Precision minimal 6 decimal places

2. **Google Maps URL (Optional):**
   - Generate dari koordinat
   - Format: `https://www.google.com/maps/dir/?api=1&destination=LAT,LNG`
   - Simpan di field `alamat_gmaps` atau generate on-the-fly

3. **Metadata Tambahan (Optional):**
   - Entrance coordinates (jika berbeda dari center)
   - Parking entrance notes
   - Access restrictions

**Update Model Mall:**
```php
// qparkin_backend/app/Models/Mall.php

public function getNavigationUrlAttribute()
{
    if ($this->latitude && $this->longitude) {
        return "https://www.google.com/maps/dir/?api=1&destination={$this->latitude},{$this->longitude}";
    }
    return null;
}

public function getGoogleMapsViewUrlAttribute()
{
    if ($this->latitude && $this->longitude) {
        return "https://maps.google.com/?q={$this->latitude},{$this->longitude}";
    }
    return $this->alamat_gmaps;
}
```

**Update API Response:**
```php
// MallController::index()
return [
    'id_mall' => $mall->id_mall,
    'nama_mall' => $mall->nama_mall,
    'lokasi' => $mall->lokasi,
    'latitude' => (float) $mall->latitude,
    'longitude' => (float) $mall->longitude,
    'available_slots' => $mall->available_slots,
    'navigation_url' => $mall->navigation_url,  // ← TAMBAH
    'google_maps_url' => $mall->google_maps_view_url,  // ← TAMBAH
    'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
];
```

### 7.3 Kesimpulan Strategi Navigasi

**Untuk Kebutuhan PBL, Rekomendasi:**

1. **Simpan koordinat terstruktur** (latitude, longitude) di database ✅
2. **Gunakan OSM/OSRM** untuk route preview di app ✅
3. **Delegasi navigasi turn-by-turn** ke Google Maps ✅
4. **Tidak perlu** implementasi routing engine sendiri ✅

**Alasan:**
- Fokus PBL pada sistem parkir, bukan navigasi
- Google Maps sudah optimal untuk navigasi
- Hemat waktu development
- User experience lebih baik (familiar dengan Google Maps)
- Maintenance lebih mudah

**Yang TIDAK Perlu:**
- ❌ Implementasi A* algorithm
- ❌ Dijkstra pathfinding
- ❌ Turn-by-turn voice guidance
- ❌ Traffic prediction model
- ❌ Road network database

**Yang PERLU:**
- ✅ Koordinat akurat di database
- ✅ API endpoint untuk fetch mall data
- ✅ Route preview menggunakan OSRM (sudah ada di RouteService)
- ✅ Integration dengan Google Maps untuk navigasi

---

## 8. Kesimpulan & Rekomendasi Final

### 8.1 Status Saat Ini

**Backend:**
- ❌ Database tidak punya field koordinat terstruktur
- ❌ API Mall Controller kosong (return [])
- ❌ Approve flow tidak simpan koordinat
- ⚠️ Hanya punya `alamat_gmaps` (URL, tidak reliable)

**Mobile App:**
- ❌ Menggunakan dummy data (tidak konsumsi API)
- ⚠️ MapProvider siap untuk API, tapi API belum ready
- ✅ Route calculation sudah ada (OSRM)
- ✅ Map display sudah berfungsi

**Integrasi:**
- ❌ Data mall tidak flow dari backend ke mobile
- ❌ Mall baru yang diapprove tidak muncul di app
- ❌ Tidak ada sinkronisasi data real-time

### 8.2 Prioritas Perbaikan

**CRITICAL (Harus Diperbaiki):**
1. Tambah field `latitude` dan `longitude` ke tabel mall
2. Implementasi API MallController untuk return data real
3. Update approve flow untuk simpan koordinat
4. Update mobile app untuk konsumsi API real

**HIGH (Sangat Direkomendasikan):**
5. Validasi koordinat di backend
6. Error handling di mobile app
7. Fallback mechanism jika API gagal
8. Testing end-to-end

**MEDIUM (Nice to Have):**
9. Data migration untuk mall existing
10. Geospatial indexing untuk performa
11. Caching di mobile app
12. Analytics tracking

### 8.3 Rekomendasi Implementasi

**Untuk PBL, Fokus Pada:**

1. **Data Integrity:**
   - Simpan koordinat terstruktur (lat/lng)
   - Validasi input koordinat
   - Ensure data consistency

2. **API Reliability:**
   - Implementasi API yang robust
   - Error handling yang baik
   - Response format yang konsisten

3. **User Experience:**
   - Route preview di app (OSM)
   - Delegasi navigasi ke Google Maps
   - Graceful degradation jika API gagal

4. **Testing:**
   - Unit test untuk API
   - Integration test untuk flow
   - Manual testing untuk UX

**Jangan Overthink:**
- Tidak perlu routing engine sendiri
- Tidak perlu real-time traffic prediction
- Tidak perlu complex geospatial queries
- Fokus pada core functionality

### 8.4 Timeline Implementasi

**Week 1: Backend Foundation (3-4 jam)**
- Day 1: Database migration + Model update
- Day 2: API implementation + Testing
- Day 3: Approve flow update + Validation

**Week 2: Mobile Integration (3-4 jam)**
- Day 1: MallService implementation
- Day 2: MapProvider update + Testing
- Day 3: UI polish + Error handling

**Week 3: Testing & Polish (2-3 jam)**
- Day 1: End-to-end testing
- Day 2: Bug fixes
- Day 3: Documentation + Demo preparation

**Total: 8-11 jam development time**

### 8.5 Success Criteria

**Backend:**
- ✅ API `/api/mall` return data dengan koordinat
- ✅ Mall baru yang diapprove punya koordinat valid
- ✅ Available slots count akurat
- ✅ Error handling yang baik

**Mobile App:**
- ✅ Mall list load dari API real
- ✅ Map markers positioned correctly
- ✅ Route calculation works
- ✅ Navigation to Google Maps works
- ✅ Graceful error handling

**Integration:**
- ✅ New mall → appears in app
- ✅ Coordinate changes → reflected in app
- ✅ Slot availability → updated in real-time
- ✅ End-to-end flow seamless

---

## 9. Dokumentasi Tambahan

### 9.1 API Documentation

**Endpoint:** `GET /api/mall`

**Response:**
```json
{
  "success": true,
  "message": "Malls retrieved successfully",
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Mega Mall Batam Centre",
      "lokasi": "Jl. Engku Putri no.1, Batam Centre",
      "latitude": 1.1191,
      "longitude": 104.0538,
      "kapasitas": 100,
      "available_slots": 45,
      "alamat_gmaps": "https://maps.google.com/?q=1.1191,104.0538",
      "navigation_url": "https://www.google.com/maps/dir/?api=1&destination=1.1191,104.0538",
      "has_slot_reservation_enabled": true
    }
  ]
}
```

### 9.2 Mobile App Configuration

**Environment Variables:**
```bash
# Run app with API URL
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# Build APK with production API
flutter build apk --release --dart-define=API_URL=https://api.qparkin.com
```

### 9.3 Troubleshooting Guide

**Problem:** Mall tidak muncul di app
- Check: API endpoint accessible?
- Check: Mall punya koordinat valid?
- Check: Mobile app using correct API_URL?
- Check: Network connectivity?

**Problem:** Route tidak terhitung
- Check: User location permission granted?
- Check: Mall coordinates valid?
- Check: OSRM service accessible?
- Check: Network connectivity?

**Problem:** Koordinat tidak akurat
- Check: Input validation di form registrasi
- Check: Google Maps picker working?
- Check: Coordinate precision (min 6 decimals)
- Check: Coordinate range validation

---

**Laporan Audit Selesai**

Untuk implementasi, mulai dari **ADMIN_MALL_REGISTRATION_AUDIT_REPORT.md** untuk fix backend registration, kemudian lanjut dengan laporan ini untuk integrasi mobile.
