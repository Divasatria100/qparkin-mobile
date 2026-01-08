# Audit Integrasi Mobile - Pendekatan Minimal untuk PBL

## Executive Summary

**Pendekatan:** Minimal & Pragmatis untuk konteks PBL
- ✅ Peta internal hanya untuk display marker mall
- ✅ Navigasi rute delegasi ke Google Maps eksternal
- ❌ TIDAK implementasi routing/polyline internal
- ⏭️ Routing internal = future enhancement (out of scope)

**Status Integrasi: ⚠️ PERLU PERBAIKAN**

---

## 1. Alur Data: Backend → Mobile App

### 1.1 Alur yang Diharapkan (Simplified)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. ADMIN MALL REGISTRATION                                  │
│    User submit form → Data tersimpan dengan status pending  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. SUPER ADMIN APPROVAL                                     │
│    Super admin approve → Mall created with:                 │
│    - name, address, latitude, longitude                     │
│    - google_maps_url (for external navigation)              │
│    - status = 'active'                                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. API ENDPOINT                                             │
│    GET /api/mall → Return active malls only                 │
│    Response includes: id, name, address, lat, lng, url      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. MOBILE APP                                               │
│    MapProvider.loadMalls() → Fetch from API                 │
│    map_page.dart → Display markers on map                   │
│    User tap "Rute" → Open google_maps_url                   │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Field yang Diperlukan

**Tabel `mall`:**
```sql
- id_mall (primary key)
- nama_mall (string)
- lokasi (string) -- address
- latitude (decimal 10,8)
- longitude (decimal 11,8)
- google_maps_url (string) -- for external navigation
- status (enum: 'active', 'inactive')
- kapasitas (integer)
- has_slot_reservation_enabled (boolean)
- created_at, updated_at (timestamps)
```

**API Response `/api/mall`:**
```json
{
  "success": true,
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Mega Mall Batam Centre",
      "lokasi": "Jl. Engku Putri no.1, Batam Centre",
      "latitude": 1.1191,
      "longitude": 104.0538,
      "google_maps_url": "https://www.google.com/maps/dir/?api=1&destination=1.1191,104.0538",
      "status": "active",
      "available_slots": 45
    }
  ]
}
```

---

## 2. Backend: Yang Perlu Diperbaiki

### MASALAH #1: Database Tidak Punya Field yang Diperlukan

**Lokasi:** `qparkin_backend/database/migrations/2025_09_24_151026_mall.php`

**Struktur Saat Ini:**
```php
Schema::create('mall', function (Blueprint $table) {
    $table->id('id_mall');
    $table->string('nama_mall', 100)->nullable();
    $table->string('lokasi', 255)->nullable();
    $table->integer('kapasitas')->nullable();
    $table->string('alamat_gmaps', 255)->nullable();
    // ❌ TIDAK ADA: latitude, longitude, google_maps_url, status
});
```

**Yang Perlu Ditambah:**
```php
$table->decimal('latitude', 10, 8)->nullable();
$table->decimal('longitude', 11, 8)->nullable();
$table->string('google_maps_url', 500)->nullable();
$table->enum('status', ['active', 'inactive'])->default('active');
```



### MASALAH #2: API Mall Controller Kosong

**Lokasi:** `qparkin_backend/app/Http/Controllers/Api/MallController.php`

**Kode Saat Ini:**
```php
public function index()
{
    return response()->json([
        'success' => true,
        'data' => []  // ❌ SELALU KOSONG!
    ]);
}
```

**Yang Perlu Diimplementasi:**
- Query mall dengan status 'active'
- Hitung available_slots dari tabel parkiran
- Return data dengan format yang sesuai

### MASALAH #3: Approve Flow Tidak Lengkap

**Lokasi:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

**Yang Perlu Diperbaiki:**
- Saat approve, mall dibuat TANPA koordinat
- Tidak ada field `google_maps_url`
- Tidak ada field `status`
- Tidak link admin_mall dengan mall

---

## 3. Solusi: Implementasi Minimal untuk PBL

### FASE 1: Update Database Schema (15 menit)

#### Step 1.1: Buat Migration Baru

**File:** `qparkin_backend/database/migrations/2026_01_XX_add_minimal_fields_to_mall_table.php`

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
            // Koordinat untuk marker di peta
            $table->decimal('latitude', 10, 8)->nullable()->after('lokasi');
            $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
            
            // URL untuk navigasi eksternal ke Google Maps
            $table->string('google_maps_url', 500)->nullable()->after('longitude');
            
            // Status mall (active/inactive)
            $table->enum('status', ['active', 'inactive'])->default('active')->after('google_maps_url');
        });
    }

    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude', 'google_maps_url', 'status']);
        });
    }
};
```

**Jalankan:**
```bash
php artisan make:migration add_minimal_fields_to_mall_table
# Copy kode di atas
php artisan migrate
```

#### Step 1.2: Update Model Mall

**File:** `qparkin_backend/app/Models/Mall.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mall extends Model
{
    use HasFactory;

    protected $table = 'mall';
    protected $primaryKey = 'id_mall';
    public $timestamps = true;

    protected $fillable = [
        'nama_mall',
        'lokasi',
        'latitude',           // ← TAMBAH
        'longitude',          // ← TAMBAH
        'google_maps_url',    // ← TAMBAH
        'status',             // ← TAMBAH
        'kapasitas',
        'alamat_gmaps',
        'has_slot_reservation_enabled'
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'has_slot_reservation_enabled' => 'boolean',
    ];

    // Helper: Generate Google Maps navigation URL
    public static function generateGoogleMapsUrl($latitude, $longitude)
    {
        if ($latitude && $longitude) {
            return "https://www.google.com/maps/dir/?api=1&destination={$latitude},{$longitude}";
        }
        return null;
    }

    // Helper: Validasi koordinat
    public function hasValidCoordinates()
    {
        return $this->latitude !== null 
            && $this->longitude !== null
            && $this->latitude >= -90 
            && $this->latitude <= 90
            && $this->longitude >= -180 
            && $this->longitude <= 180;
    }

    // Relationships
    public function adminMall()
    {
        return $this->hasMany(AdminMall::class, 'id_mall', 'id_mall');
    }

    public function parkiran()
    {
        return $this->hasMany(Parkiran::class, 'id_mall', 'id_mall');
    }

    public function tarifParkir()
    {
        return $this->hasMany(TarifParkir::class, 'id_mall', 'id_mall');
    }

    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_mall', 'id_mall');
    }
}
```

### FASE 2: Implementasi API Mall Controller (20 menit)

**File:** `qparkin_backend/app/Http/Controllers/Api/MallController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mall;
use Illuminate\Http\Request;

class MallController extends Controller
{
    /**
     * Get all active malls with parking availability
     * 
     * Returns only malls with status = 'active'
     * Includes available parking slots count
     */
    public function index()
    {
        try {
            $malls = Mall::where('status', 'active')
                ->select([
                    'mall.id_mall',
                    'mall.nama_mall',
                    'mall.lokasi',
                    'mall.latitude',
                    'mall.longitude',
                    'mall.google_maps_url',
                    'mall.status',
                    'mall.kapasitas',
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
                    'mall.google_maps_url',
                    'mall.status',
                    'mall.kapasitas',
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
                        'google_maps_url' => $mall->google_maps_url,
                        'status' => $mall->status,
                        'kapasitas' => $mall->kapasitas,
                        'available_slots' => $mall->available_slots ?? 0,
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
            $mall = Mall::where('status', 'active')
                ->with(['parkiran', 'tarifParkir'])
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
                    'google_maps_url' => $mall->google_maps_url,
                    'status' => $mall->status,
                    'kapasitas' => $mall->kapasitas,
                    'available_slots' => $availableSlots,
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
            $mall = Mall::where('status', 'active')->findOrFail($id);
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
            $mall = Mall::where('status', 'active')->findOrFail($id);
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



### FASE 3: Update Approve Flow (25 menit)

**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

Update method `approvePengajuan()`:

```php
public function approvePengajuan(Request $request, $id)
{
    DB::beginTransaction();
    try {
        $user = User::findOrFail($id);
        
        // Validasi status pending
        if ($user->application_status !== 'pending') {
            return back()->withErrors(['error' => 'Pengajuan ini sudah diproses sebelumnya.']);
        }
        
        // Generate Google Maps URL untuk navigasi eksternal
        $googleMapsUrl = null;
        if ($user->requested_mall_latitude && $user->requested_mall_longitude) {
            $googleMapsUrl = Mall::generateGoogleMapsUrl(
                $user->requested_mall_latitude,
                $user->requested_mall_longitude
            );
        }
        
        // 1. Buat Mall baru dengan koordinat dan google_maps_url
        $mall = Mall::create([
            'nama_mall' => $user->requested_mall_name,
            'lokasi' => $user->requested_mall_location,
            'latitude' => $user->requested_mall_latitude,
            'longitude' => $user->requested_mall_longitude,
            'google_maps_url' => $googleMapsUrl,
            'status' => 'active',  // ← PENTING: Set status active
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
        
        // 3. Buat entry di admin_mall (link admin dengan mall)
        AdminMall::create([
            'id_user' => $user->id_user,
            'id_mall' => $mall->id_mall,
            'hak_akses' => 'full',
        ]);
        
        // 4. TODO: Kirim email notifikasi (optional)
        
        DB::commit();
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Pengajuan berhasil disetujui',
                'data' => [
                    'mall_id' => $mall->id_mall,
                    'mall_name' => $mall->nama_mall,
                    'status' => $mall->status,
                    'google_maps_url' => $mall->google_maps_url
                ]
            ]);
        }
        
        return redirect()->route('superadmin.pengajuan')
            ->with('success', 'Pengajuan berhasil disetujui. Mall telah ditambahkan dan siap digunakan.');
            
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

---

## 4. Mobile App: Yang Perlu Diperbaiki

### MASALAH #4: MapProvider Menggunakan Dummy Data

**Lokasi:** `qparkin_app/lib/logic/providers/map_provider.dart` line ~200

**Kode Saat Ini:**
```dart
Future<void> loadMalls() async {
  // TODO: Replace with API call when backend is ready
  _malls = getDummyMalls();  // ❌ DUMMY DATA
}
```

**Yang Perlu:** Konsumsi API real dari backend

### MASALAH #5: map_page.dart Tidak Punya Tombol "Lihat Rute"

**Lokasi:** `qparkin_app/lib/presentation/screens/map_page.dart`

**Yang Ada Saat Ini:**
- Tombol "Rute" yang trigger `_selectMallAndShowMap()` 
- Method ini mencoba calculate route internal (OSRM)

**Yang Perlu:**
- Tombol "Lihat Rute" yang langsung buka `google_maps_url`
- Tidak perlu route calculation internal

---

## 5. Solusi Mobile App: Implementasi Minimal

### FASE 4: Buat Mall Service (15 menit)

**File:** `qparkin_app/lib/data/services/mall_service.dart` (BUAT BARU)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mall_model.dart';

class MallService {
  final String baseUrl;
  
  MallService({required this.baseUrl});
  
  /// Fetch all active malls from API
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
}
```

### FASE 5: Update MapProvider (15 menit)

**File:** `qparkin_app/lib/logic/providers/map_provider.dart`

Update method `loadMalls()`:

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
  Future<void> loadMalls() async {
    debugPrint('[MapProvider] Loading malls from API...');

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Fetch from API
      _malls = await _mallService.fetchMalls();

      debugPrint('[MapProvider] Loaded ${_malls.length} malls from API');

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
    }
  }
}
```

### FASE 6: Update MallModel (10 menit)

**File:** `qparkin_app/lib/data/models/mall_model.dart`

Tambah field `googleMapsUrl`:

```dart
class MallModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availableSlots;
  final String distance;
  final bool hasSlotReservationEnabled;
  final String? googleMapsUrl;  // ← TAMBAH untuk navigasi eksternal

  MallModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availableSlots,
    this.distance = '',
    this.hasSlotReservationEnabled = false,
    this.googleMapsUrl,  // ← TAMBAH
  });

  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      id: json['id']?.toString() ?? json['id_mall']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama_mall']?.toString() ?? '',
      address: json['address']?.toString() ?? json['lokasi']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      availableSlots: _parseInt(json['available_slots'] ?? json['kapasitas']),
      distance: json['distance']?.toString() ?? '',
      hasSlotReservationEnabled: json['has_slot_reservation_enabled'] == true ||
          json['has_slot_reservation_enabled'] == 1,
      googleMapsUrl: json['google_maps_url']?.toString(),  // ← TAMBAH
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'available_slots': availableSlots,
      'distance': distance,
      'has_slot_reservation_enabled': hasSlotReservationEnabled,
      'google_maps_url': googleMapsUrl,  // ← TAMBAH
    };
  }

  // ... existing helper methods ...

  MallModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? availableSlots,
    String? distance,
    bool? hasSlotReservationEnabled,
    String? googleMapsUrl,  // ← TAMBAH
  }) {
    return MallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availableSlots: availableSlots ?? this.availableSlots,
      distance: distance ?? this.distance,
      hasSlotReservationEnabled:
          hasSlotReservationEnabled ?? this.hasSlotReservationEnabled,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,  // ← TAMBAH
    );
  }
}
```



### FASE 7: Update map_page.dart - Tombol "Lihat Rute" (15 menit)

**File:** `qparkin_app/lib/presentation/screens/map_page.dart`

#### Step 1: Tambah import untuk url_launcher

```dart
import 'package:url_launcher/url_launcher.dart';
```

#### Step 2: Ganti method `_selectMallAndShowMap()` 

**HAPUS method ini** (karena tidak perlu route calculation internal):

```dart
// ❌ HAPUS method ini - tidak perlu lagi
Future<void> _selectMallAndShowMap(int index, MapProvider mapProvider) async {
  // ... kode lama yang calculate route ...
}
```

**GANTI dengan method baru** untuk buka Google Maps:

```dart
/// Open Google Maps for navigation to mall
Future<void> _openGoogleMapsNavigation(MallModel mall) async {
  if (mall.googleMapsUrl == null || mall.googleMapsUrl!.isEmpty) {
    // Fallback: generate URL from coordinates
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${mall.latitude},${mall.longitude}';
    await _launchUrl(url);
  } else {
    await _launchUrl(mall.googleMapsUrl!);
  }
}

/// Launch URL helper
Future<void> _launchUrl(String urlString) async {
  try {
    final url = Uri.parse(urlString);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Open in Google Maps app
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint('[MapPage] Error launching URL: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

#### Step 3: Update Mall Card - Ganti Tombol "Rute"

Dalam method `_buildMallCard()`, ganti bagian tombol "Rute":

**HAPUS kode lama:**
```dart
// ❌ HAPUS ini
TextButton.icon(
  onPressed: () => _selectMallAndShowMap(index, mapProvider),
  icon: const Icon(Icons.navigation, size: 16),
  label: const Text('Rute'),
  // ...
),
```

**GANTI dengan:**
```dart
// ✅ GANTI dengan ini
TextButton.icon(
  onPressed: () => _openGoogleMapsNavigation(mapProvider.malls[index]),
  icon: const Icon(Icons.map, size: 16),
  label: const Text('Lihat Rute'),
  style: TextButton.styleFrom(
    foregroundColor: const Color(0xFF573ED1),
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
  ),
),
```

#### Step 4: Tambah dependency url_launcher

**File:** `qparkin_app/pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... existing dependencies ...
  url_launcher: ^6.2.0  # ← TAMBAH ini
```

**Jalankan:**
```bash
cd qparkin_app
flutter pub get
```

#### Step 5: HAPUS/COMMENT Kode Route Calculation (Optional)

Karena tidak perlu route calculation internal, Anda bisa:

**Opsi A: Comment method yang tidak terpakai**
```dart
// FUTURE ENHANCEMENT: Internal routing
// Future<void> _showRouteOnMap(...) async { ... }
// Future<void> calculateRoute(...) async { ... }
```

**Opsi B: Biarkan saja** (untuk future enhancement)

---

## 6. Checklist Implementasi (Total: ~2 jam)

### Backend (60 menit)

- [ ] **Database Migration (15 menit)**
  - [ ] Buat migration untuk tambah field: latitude, longitude, google_maps_url, status
  - [ ] Jalankan: `php artisan migrate`
  - [ ] Verifikasi: `php artisan tinker` → cek struktur tabel mall

- [ ] **Model Update (10 menit)**
  - [ ] Update `Mall.php` - tambah field ke $fillable
  - [ ] Tambah helper methods: `generateGoogleMapsUrl()`, `hasValidCoordinates()`
  - [ ] Test: `php artisan tinker` → test helper methods

- [ ] **API Implementation (20 menit)**
  - [ ] Update `MallController::index()` - query active malls dengan available_slots
  - [ ] Update `MallController::show()` - detail mall
  - [ ] Test: `curl http://localhost:8000/api/mall` → verify response

- [ ] **Approve Flow (15 menit)**
  - [ ] Update `SuperAdminController::approvePengajuan()`
  - [ ] Simpan: latitude, longitude, google_maps_url, status='active'
  - [ ] Link admin_mall dengan mall
  - [ ] Test: Approve pengajuan → verify mall created

### Mobile App (60 menit)

- [ ] **MallService (15 menit)**
  - [ ] Buat file `mall_service.dart`
  - [ ] Implementasi `fetchMalls()` method
  - [ ] Test: Run dengan mock data

- [ ] **MapProvider Update (15 menit)**
  - [ ] Tambah `MallService` dependency
  - [ ] Update `loadMalls()` - fetch dari API
  - [ ] Tambah fallback ke dummy data
  - [ ] Test: Run app → verify mall load dari API

- [ ] **MallModel Update (10 menit)**
  - [ ] Tambah field `googleMapsUrl`
  - [ ] Update `fromJson()` dan `toJson()`
  - [ ] Update `copyWith()`

- [ ] **map_page.dart Update (20 menit)**
  - [ ] Tambah dependency `url_launcher`
  - [ ] Buat method `_openGoogleMapsNavigation()`
  - [ ] Buat helper `_launchUrl()`
  - [ ] Update tombol "Rute" → "Lihat Rute"
  - [ ] Hapus/comment kode route calculation internal
  - [ ] Test: Tap "Lihat Rute" → Google Maps terbuka

### Testing End-to-End (30 menit)

- [ ] **Backend Testing**
  - [ ] Registrasi admin mall dengan koordinat
  - [ ] Approve pengajuan
  - [ ] Verify mall created dengan status='active'
  - [ ] API `/api/mall` return mall baru
  - [ ] Verify google_maps_url ter-generate

- [ ] **Mobile App Testing**
  - [ ] Launch app → mall list load dari API
  - [ ] Verify marker muncul di peta dengan koordinat benar
  - [ ] Tap mall card → mall selected
  - [ ] Tap "Lihat Rute" → Google Maps terbuka
  - [ ] Verify navigasi ke koordinat yang benar

- [ ] **Integration Testing**
  - [ ] Approve mall baru → refresh app → mall muncul
  - [ ] Mall inactive → tidak muncul di app
  - [ ] Network error → fallback ke dummy data
  - [ ] Invalid coordinates → mall di-filter

---

## 7. Testing Plan

### 7.1 Backend Testing

**Test API Endpoint:**
```bash
# Test GET /api/mall
curl -X GET http://localhost:8000/api/mall \
  -H "Accept: application/json"

# Expected response:
{
  "success": true,
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Test Mall",
      "lokasi": "Test Address",
      "latitude": 1.1191,
      "longitude": 104.0538,
      "google_maps_url": "https://www.google.com/maps/dir/?api=1&destination=1.1191,104.0538",
      "status": "active",
      "available_slots": 45
    }
  ]
}
```

**Test Approve Flow:**
```php
// php artisan tinker
$user = User::where('application_status', 'pending')->first();
// Manually call approve or test via UI
```

### 7.2 Mobile App Testing

**Test Mall Loading:**
```bash
# Run app with API URL
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

**Manual Test Checklist:**
- [ ] App launch → malls load from API
- [ ] Map displays markers at correct coordinates
- [ ] Tap mall card → mall selected (highlighted)
- [ ] Tap "Lihat Rute" → Google Maps opens
- [ ] Google Maps shows correct destination
- [ ] Navigation works in Google Maps

### 7.3 Error Scenarios

**Test Network Error:**
- [ ] Turn off backend → app shows dummy data
- [ ] Error message displayed
- [ ] App doesn't crash

**Test Invalid Data:**
- [ ] Mall without coordinates → filtered out
- [ ] Mall with status='inactive' → not shown
- [ ] Empty google_maps_url → fallback URL generated

---

## 8. Kesimpulan & Rekomendasi

### 8.1 Pendekatan Minimal untuk PBL

**✅ Yang Diimplementasi:**
1. Database field: latitude, longitude, google_maps_url, status
2. API endpoint: GET /api/mall (return active malls only)
3. Approve flow: Create mall dengan koordinat dan google_maps_url
4. Mobile app: Display markers, tombol "Lihat Rute" ke Google Maps

**❌ Yang TIDAK Diimplementasi (Out of Scope):**
1. Route calculation internal (OSRM/polyline)
2. Turn-by-turn navigation
3. Traffic information
4. Route optimization
5. Offline routing

**⏭️ Future Enhancement:**
- Internal routing dengan OSRM (sudah ada RouteService)
- Route preview sebelum buka Google Maps
- Multiple route options
- Estimated time calculation

### 8.2 Alur Data Final

```
1. Admin Mall Registration
   ↓ (submit form dengan koordinat)
   
2. Super Admin Approval
   ↓ (approve → create mall)
   
3. Mall Created in Database
   - status = 'active'
   - latitude, longitude tersimpan
   - google_maps_url ter-generate
   ↓
   
4. Mobile App Fetch API
   GET /api/mall → return active malls
   ↓
   
5. MapProvider Load Malls
   Parse response → create MallModel list
   ↓
   
6. map_page.dart Display
   - Show markers on map (latitude, longitude)
   - Show mall list with "Lihat Rute" button
   ↓
   
7. User Tap "Lihat Rute"
   Launch google_maps_url → Google Maps opens
   ↓
   
8. Google Maps Navigation
   User gets turn-by-turn directions
```

### 8.3 Keuntungan Pendekatan Minimal

**Untuk PBL:**
- ✅ Fokus pada core functionality (parking system)
- ✅ Implementasi cepat (~2 jam)
- ✅ Maintenance mudah
- ✅ User experience familiar (Google Maps)
- ✅ Tidak perlu routing engine complex

**Untuk Development:**
- ✅ Less code to maintain
- ✅ Fewer bugs potential
- ✅ Easier testing
- ✅ Clear separation of concerns

**Untuk User:**
- ✅ Reliable navigation (Google Maps)
- ✅ Real-time traffic info
- ✅ Familiar interface
- ✅ Works offline (Google Maps cache)

### 8.4 Success Criteria

**Backend:**
- ✅ Mall created dengan koordinat valid
- ✅ google_maps_url ter-generate otomatis
- ✅ API return active malls only
- ✅ Available slots count akurat

**Mobile App:**
- ✅ Markers displayed at correct coordinates
- ✅ Tombol "Lihat Rute" berfungsi
- ✅ Google Maps opens dengan destination benar
- ✅ Graceful error handling

**Integration:**
- ✅ New approved mall → appears in app
- ✅ Inactive mall → not shown
- ✅ Network error → fallback to dummy data
- ✅ End-to-end flow seamless

---

## 9. Troubleshooting

**Problem:** Mall tidak muncul di app
- ✅ Check: Mall status = 'active'?
- ✅ Check: Mall punya koordinat valid?
- ✅ Check: API endpoint accessible?
- ✅ Check: Mobile app using correct API_URL?

**Problem:** "Lihat Rute" tidak buka Google Maps
- ✅ Check: google_maps_url tidak null?
- ✅ Check: url_launcher dependency installed?
- ✅ Check: Google Maps app installed di device?
- ✅ Check: URL format benar?

**Problem:** Koordinat tidak akurat
- ✅ Check: Form registrasi validation
- ✅ Check: Google Maps picker working?
- ✅ Check: Coordinate precision (min 6 decimals)
- ✅ Check: Approve flow simpan koordinat dengan benar?

---

**Laporan Audit Selesai - Pendekatan Minimal untuk PBL**

Implementasi fokus pada:
1. Display markers di peta internal
2. Delegasi navigasi ke Google Maps eksternal
3. Tidak ada routing internal (future enhancement)
4. Total waktu: ~2 jam development
