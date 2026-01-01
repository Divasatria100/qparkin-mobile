# Vehicle API Integration Guide

## Overview
Panduan lengkap integrasi modul kendaraan Flutter dengan backend Laravel QParkin.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App (Mobile)                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  UI Layer (Presentation)                                     │
│  ├── tambah_kendaraan.dart                                   │
│  ├── list_kendaraan.dart                                     │
│  └── vehicle_detail_page.dart                                │
│                          ↓                                    │
│  State Management (Logic)                                    │
│  └── ProfileProvider                                         │
│                          ↓                                    │
│  Service Layer (Data)                                        │
│  └── VehicleApiService ← HTTP Client                         │
│                          ↓                                    │
└──────────────────────────┼────────────────────────────────────┘
                           │ HTTPS
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   Laravel Backend (Server)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Routes (api.php)                                            │
│  └── /api/kendaraan/*                                        │
│                          ↓                                    │
│  Controller                                                  │
│  └── KendaraanController                                     │
│                          ↓                                    │
│  Model                                                       │
│  └── Kendaraan                                               │
│                          ↓                                    │
└──────────────────────────┼────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    MySQL Database                            │
├─────────────────────────────────────────────────────────────┤
│  Tables:                                                     │
│  ├── user                                                    │
│  ├── kendaraan                                               │
│  └── transaksi_parkir                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Setup Instructions

### 1. Backend Setup (Laravel)

#### Step 1: Run Migration
```bash
cd qparkin_backend
php artisan migrate
```

Ini akan menjalankan migration `2025_01_01_000000_update_kendaraan_table.php` yang menambahkan:
- `warna` (string, nullable)
- `foto_path` (string, nullable)
- `is_active` (boolean, default: false)
- `created_at` (timestamp)
- `updated_at` (timestamp)
- `last_used_at` (timestamp, nullable)

#### Step 2: Create Storage Link
```bash
php artisan storage:link
```

Ini membuat symbolic link dari `storage/app/public` ke `public/storage` untuk akses foto.

#### Step 3: Set Permissions
```bash
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

#### Step 4: Test API
```bash
# Start server
php artisan serve

# Test health check
curl http://localhost:8000/api/health
```

### 2. Flutter Setup

#### Step 1: Update Dependencies
Pastikan `pubspec.yaml` sudah memiliki:
```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.1.1
  image_picker: ^1.0.7
```

#### Step 2: Configure API Base URL
Update `lib/config/api_config.dart` atau buat jika belum ada:
```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.x.x:8000/api';
  // Ganti dengan IP server Anda
}
```

#### Step 3: Initialize Service
Di `main.dart` atau provider setup:
```dart
final vehicleApiService = VehicleApiService(
  baseUrl: ApiConfig.baseUrl,
);
```

---

## Data Flow

### Adding a Vehicle

```
User Input (UI)
    ↓
tambah_kendaraan.dart
    ↓
ProfileProvider.addVehicle()
    ↓
VehicleApiService.addVehicle()
    ↓
HTTP POST /api/kendaraan
    ↓
KendaraanController@store
    ↓
Validation
    ↓
Save to Database
    ↓
Return VehicleModel
    ↓
Update Provider State
    ↓
UI Rebuilds
```

### Fetching Vehicles

```
Page Load
    ↓
list_kendaraan.dart
    ↓
ProfileProvider.fetchVehicles()
    ↓
VehicleApiService.getVehicles()
    ↓
HTTP GET /api/kendaraan
    ↓
KendaraanController@index
    ↓
Query Database
    ↓
Add Statistics
    ↓
Return List<VehicleModel>
    ↓
Update Provider State
    ↓
UI Displays List
```

---

## Implementation Steps

### Step 1: Update ProfileProvider

Modify `lib/logic/providers/profile_provider.dart`:

```dart
import '../services/vehicle_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final VehicleApiService _vehicleApiService;
  
  ProfileProvider({required VehicleApiService vehicleApiService})
      : _vehicleApiService = vehicleApiService;

  // ... existing code ...

  /// Fetch vehicles from API
  Future<void> fetchVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[ProfileProvider] Fetching vehicles from API...');
      
      _vehicles = await _vehicleApiService.getVehicles();
      _lastSyncTime = DateTime.now();
      _isLoading = false;
      _errorMessage = null;
      
      debugPrint('[ProfileProvider] Vehicles fetched: ${_vehicles.length}');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getUserFriendlyError(e.toString());
      
      debugPrint('[ProfileProvider] Error fetching vehicles: $e');
      notifyListeners();
    }
  }

  /// Add vehicle via API
  Future<void> addVehicle(VehicleModel vehicle, {File? foto}) async {
    try {
      debugPrint('[ProfileProvider] Adding vehicle via API...');
      
      final newVehicle = await _vehicleApiService.addVehicle(
        platNomor: vehicle.platNomor,
        jenisKendaraan: vehicle.jenisKendaraan,
        merk: vehicle.merk,
        tipe: vehicle.tipe,
        warna: vehicle.warna,
        isActive: vehicle.isActive,
        foto: foto,
      );
      
      _vehicles.add(newVehicle);
      _lastSyncTime = DateTime.now();
      
      debugPrint('[ProfileProvider] Vehicle added successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error adding vehicle: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Delete vehicle via API
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      debugPrint('[ProfileProvider] Deleting vehicle via API...');
      
      await _vehicleApiService.deleteVehicle(vehicleId);
      
      _vehicles.removeWhere((v) => v.idKendaraan == vehicleId);
      _lastSyncTime = DateTime.now();
      
      debugPrint('[ProfileProvider] Vehicle deleted successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error deleting vehicle: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Set active vehicle via API
  Future<void> setActiveVehicle(String vehicleId) async {
    try {
      debugPrint('[ProfileProvider] Setting active vehicle via API...');
      
      final updatedVehicle = await _vehicleApiService.setActiveVehicle(vehicleId);
      
      // Update local state
      _vehicles = _vehicles.map((v) {
        if (v.idKendaraan == vehicleId) {
          return updatedVehicle;
        } else {
          return v.copyWith(isActive: false);
        }
      }).toList();
      
      _lastSyncTime = DateTime.now();
      
      debugPrint('[ProfileProvider] Active vehicle set successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e.toString());
      debugPrint('[ProfileProvider] Error setting active vehicle: $e');
      notifyListeners();
      rethrow;
    }
  }
}
```

### Step 2: Update tambah_kendaraan.dart

Modify the submit function:

```dart
Future<void> _submitForm() async {
  // ... validation code ...

  setState(() {
    isLoading = true;
  });

  try {
    final provider = context.read<ProfileProvider>();
    
    // Create vehicle model
    final newVehicle = VehicleModel(
      idKendaraan: '', // Will be assigned by backend
      platNomor: plateController.text.trim().toUpperCase(),
      jenisKendaraan: selectedVehicleType!,
      merk: brandController.text.trim(),
      tipe: typeController.text.trim(),
      warna: colorController.text.trim().isNotEmpty 
          ? colorController.text.trim() 
          : null,
      isActive: selectedVehicleStatus == "Kendaraan Utama",
    );

    // Add vehicle with photo
    await provider.addVehicle(newVehicle, foto: selectedImage);

    if (mounted) {
      _showSnackbar('Kendaraan berhasil ditambahkan!', isError: false);
      Navigator.of(context).pop(true);
    }
  } catch (e) {
    if (mounted) {
      _showSnackbar('Gagal menambahkan kendaraan: $e', isError: true);
    }
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
```

### Step 3: Update main.dart

Initialize provider with service:

```dart
void main() {
  final vehicleApiService = VehicleApiService(
    baseUrl: 'http://192.168.x.x:8000/api',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            vehicleApiService: vehicleApiService,
          ),
        ),
        // ... other providers ...
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Testing

### 1. Test Backend API

```bash
# Get token first
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Save the token, then test vehicle endpoints
TOKEN="your_token_here"

# Get vehicles
curl -X GET http://localhost:8000/api/kendaraan \
  -H "Authorization: Bearer $TOKEN"

# Add vehicle
curl -X POST http://localhost:8000/api/kendaraan \
  -H "Authorization: Bearer $TOKEN" \
  -F "plat_nomor=B 1234 XYZ" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true"
```

### 2. Test Flutter Integration

1. **Login** ke aplikasi
2. **Navigate** ke halaman tambah kendaraan
3. **Fill form** dengan data valid
4. **Upload foto** (optional)
5. **Submit** dan verify success message
6. **Check list** kendaraan terupdate
7. **Test delete** dan **set active**

---

## Troubleshooting

### Issue: "Failed to load vehicles: 401"
**Solution:** Token expired atau invalid. Login ulang.

### Issue: "Failed to add vehicle: 422"
**Solution:** Validation error. Check:
- Plat nomor unique
- Jenis kendaraan valid
- Required fields filled

### Issue: "Cannot delete vehicle with active parking transaction"
**Solution:** Vehicle masih punya transaksi parkir aktif. Selesaikan transaksi dulu.

### Issue: Photo not uploading
**Solution:** Check:
- File size < 2MB
- Format: jpeg/png/jpg
- Storage link created: `php artisan storage:link`
- Permissions: `chmod -R 775 storage`

### Issue: "Connection refused"
**Solution:** Check:
- Backend server running
- Correct IP address in baseUrl
- Firewall not blocking
- Same network (for local testing)

---

## Security Considerations

1. **Token Storage**: Gunakan `flutter_secure_storage` untuk token
2. **HTTPS**: Gunakan HTTPS di production
3. **Validation**: Validate di client DAN server
4. **File Upload**: Limit size dan type
5. **SQL Injection**: Laravel Eloquent sudah protect
6. **XSS**: Laravel auto-escape output

---

## Performance Optimization

1. **Caching**: Cache vehicle list di local storage
2. **Lazy Loading**: Load statistics on demand
3. **Image Compression**: Compress before upload
4. **Pagination**: Implement jika vehicles > 50
5. **Debouncing**: Debounce search/filter

---

## Next Steps

1. ✅ Run migration
2. ✅ Test API endpoints
3. ✅ Integrate VehicleApiService
4. ✅ Update ProfileProvider
5. ✅ Test full flow
6. ⬜ Add error handling
7. ⬜ Add loading states
8. ⬜ Add offline support
9. ⬜ Add unit tests
10. ⬜ Deploy to production

---

## Support

Untuk pertanyaan atau issues:
1. Check dokumentasi API: `qparkin_backend/docs/VEHICLE_API_DOCUMENTATION.md`
2. Check logs: `storage/logs/laravel.log`
3. Enable debug mode: `APP_DEBUG=true` in `.env`
