# Vehicle API Integration Summary

## 🎯 Tujuan
Mengintegrasikan modul kendaraan Flutter dengan backend Laravel yang sudah ada, tanpa membuat backend baru.

## ✅ Yang Sudah Dikerjakan

### 1. Database (Backend)

#### Migration Baru
**File:** `qparkin_backend/database/migrations/2025_01_01_000000_update_kendaraan_table.php`

**Field Ditambahkan:**
- `warna` (VARCHAR 50, nullable) - Warna kendaraan
- `foto_path` (VARCHAR 255, nullable) - Path foto di storage
- `is_active` (BOOLEAN, default: false) - Status kendaraan aktif
- `created_at` (TIMESTAMP) - Waktu ditambahkan
- `updated_at` (TIMESTAMP) - Waktu terakhir diupdate
- `last_used_at` (TIMESTAMP, nullable) - Waktu terakhir digunakan parkir

**Cara Menjalankan:**
```bash
cd qparkin_backend
php artisan migrate
php artisan storage:link
```

#### Schema SQL Lengkap
**File:** `qparkin_backend/database/migrations/VEHICLE_SCHEMA.sql`

Berisi:
- CREATE TABLE statement lengkap
- Indexes untuk performa
- Triggers untuk ensure only one active vehicle
- Views untuk statistics
- Stored procedures
- Sample data

---

### 2. Backend API (Laravel)

#### Model Update
**File:** `qparkin_backend/app/Models/Kendaraan.php`

**Perubahan:**
- Enable timestamps
- Tambah fillable fields baru
- Tambah casts untuk boolean dan datetime
- Tambah `foto_url` computed attribute
- Tambah method `getStatistics()` untuk statistik parkir
- Tambah scopes: `active()`, `forUser()`

#### Controller Implementation
**File:** `qparkin_backend/app/Http/Controllers/Api/KendaraanController.php`

**Endpoints Implemented:**
1. `GET /api/kendaraan` - Get all vehicles
2. `POST /api/kendaraan` - Add new vehicle
3. `GET /api/kendaraan/{id}` - Get vehicle details
4. `PUT /api/kendaraan/{id}` - Update vehicle
5. `DELETE /api/kendaraan/{id}` - Delete vehicle
6. `PUT /api/kendaraan/{id}/set-active` - Set active vehicle

**Features:**
- ✅ Authentication required (Sanctum)
- ✅ User isolation (hanya bisa akses kendaraan sendiri)
- ✅ Photo upload support
- ✅ Validation lengkap
- ✅ Error handling
- ✅ Statistics integration
- ✅ Transaction safety (DB::beginTransaction)
- ✅ Auto-deactivate other vehicles when setting active
- ✅ Delete protection (tidak bisa hapus jika ada transaksi aktif)

#### Routes Update
**File:** `qparkin_backend/routes/api.php`

Ditambahkan route baru:
```php
Route::put('/{id}/set-active', [KendaraanController::class, 'setActive']);
```

---

### 3. Flutter Integration

#### VehicleApiService
**File:** `qparkin_app/lib/data/services/vehicle_api_service.dart`

**Methods:**
- `getVehicles()` - Fetch all vehicles
- `addVehicle()` - Add new vehicle with photo
- `getVehicle(id)` - Get vehicle details
- `updateVehicle()` - Update vehicle with photo
- `deleteVehicle(id)` - Delete vehicle
- `setActiveVehicle(id)` - Set as active

**Features:**
- ✅ HTTP multipart untuk upload foto
- ✅ Token authentication dari secure storage
- ✅ Error handling lengkap
- ✅ Validation error parsing
- ✅ JSON serialization/deserialization

#### ProfileProvider Update (Planned)
**File:** `qparkin_app/lib/logic/providers/profile_provider.dart`

**Changes Needed:**
```dart
// Constructor
ProfileProvider({required VehicleApiService vehicleApiService})

// Methods to update
- fetchVehicles() → call API
- addVehicle() → call API with photo
- deleteVehicle() → call API
- setActiveVehicle() → call API
```

---

### 4. Documentation

#### Backend Documentation
**File:** `qparkin_backend/docs/VEHICLE_API_DOCUMENTATION.md`

Berisi:
- API endpoints lengkap
- Request/response examples
- Error codes
- Business rules
- Testing dengan cURL
- Database schema

#### Integration Guide
**File:** `qparkin_app/docs/VEHICLE_API_INTEGRATION_GUIDE.md`

Berisi:
- Architecture diagram
- Setup instructions (backend & Flutter)
- Data flow diagrams
- Implementation steps
- Testing guide
- Troubleshooting
- Security considerations

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter)                      │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 1. User adds vehicle
                           │    (plat, jenis, merk, tipe, warna, foto)
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              tambah_kendaraan.dart (UI)                      │
│  - Collect form data                                         │
│  - Validate input                                            │
│  - Pick photo (optional)                                     │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 2. Call provider
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              ProfileProvider (State)                         │
│  - addVehicle(vehicle, foto)                                 │
│  - Set loading state                                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 3. Call API service
                           ↓
┌─────────────────────────────────────────────────────────────┐
│           VehicleApiService (HTTP Client)                    │
│  - Build multipart request                                   │
│  - Add auth token                                            │
│  - Send POST /api/kendaraan                                  │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 4. HTTPS Request
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                  BACKEND (Laravel)                           │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 5. Route to controller
                           ↓
┌─────────────────────────────────────────────────────────────┐
│           KendaraanController@store                          │
│  - Validate request                                          │
│  - Check authentication                                      │
│  - Get user from token                                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 6. Process data
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              Business Logic                                  │
│  - Deactivate other vehicles if is_active=true              │
│  - Upload photo to storage/vehicles/                         │
│  - Convert plat to uppercase                                 │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 7. Save to database
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              Kendaraan Model                                 │
│  - Create new record                                         │
│  - Set timestamps                                            │
│  - Return model with foto_url                                │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 8. Query database
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              MySQL Database                                  │
│  INSERT INTO kendaraan (                                     │
│    id_user, plat, jenis, merk, tipe,                        │
│    warna, foto_path, is_active,                             │
│    created_at, updated_at                                    │
│  ) VALUES (...)                                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 9. Return response
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              JSON Response                                   │
│  {                                                           │
│    "success": true,                                          │
│    "message": "Vehicle added successfully",                  │
│    "data": {                                                 │
│      "id_kendaraan": 1,                                      │
│      "plat": "B 1234 XYZ",                                   │
│      "foto_url": "https://.../storage/vehicles/...",        │
│      ...                                                     │
│    }                                                         │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 10. Parse response
                           ↓
┌─────────────────────────────────────────────────────────────┐
│           VehicleApiService                                  │
│  - Parse JSON                                                │
│  - Create VehicleModel                                       │
│  - Return to provider                                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 11. Update state
                           ↓
┌─────────────────────────────────────────────────────────────┐
│           ProfileProvider                                    │
│  - Add to _vehicles list                                     │
│  - notifyListeners()                                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ 12. UI rebuilds
                           ↓
┌─────────────────────────────────────────────────────────────┐
│           list_kendaraan.dart                                │
│  - Consumer rebuilds                                         │
│  - Display new vehicle                                       │
│  - Show success message                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Setup Instructions

### Backend Setup

```bash
# 1. Navigate to backend
cd qparkin_backend

# 2. Run migration
php artisan migrate

# 3. Create storage link
php artisan storage:link

# 4. Set permissions
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# 5. Start server
php artisan serve
```

### Flutter Setup

```bash
# 1. Navigate to app
cd qparkin_app

# 2. Get dependencies
flutter pub get

# 3. Update API base URL in code
# Edit lib/config/api_config.dart or main.dart
# Set baseUrl to your server IP

# 4. Run app
flutter run
```

---

## 🧪 Testing

### Test Backend API

```bash
# 1. Login to get token
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# 2. Get vehicles
curl -X GET http://localhost:8000/api/kendaraan \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Add vehicle
curl -X POST http://localhost:8000/api/kendaraan \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "plat_nomor=B 1234 XYZ" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true"
```

### Test Flutter App

1. Login ke aplikasi
2. Navigate ke "List Kendaraan"
3. Tap tombol "+" untuk tambah kendaraan
4. Fill form dan upload foto
5. Submit dan verify success
6. Check list terupdate
7. Test delete dan set active

---

## 📝 API Endpoints Summary

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/kendaraan` | Get all user vehicles | ✅ |
| POST | `/api/kendaraan` | Add new vehicle | ✅ |
| GET | `/api/kendaraan/{id}` | Get vehicle details | ✅ |
| PUT | `/api/kendaraan/{id}` | Update vehicle | ✅ |
| DELETE | `/api/kendaraan/{id}` | Delete vehicle | ✅ |
| PUT | `/api/kendaraan/{id}/set-active` | Set as active | ✅ |

---

## 🔒 Security Features

1. ✅ **Authentication Required** - Semua endpoint butuh Sanctum token
2. ✅ **User Isolation** - User hanya bisa akses kendaraan sendiri
3. ✅ **Input Validation** - Validasi di backend
4. ✅ **SQL Injection Protection** - Laravel Eloquent
5. ✅ **File Upload Security** - Validasi type dan size
6. ✅ **Token Storage** - Flutter secure storage
7. ✅ **HTTPS Ready** - Production harus pakai HTTPS

---

## 📦 Files Created/Modified

### Backend (Laravel)
- ✅ `database/migrations/2025_01_01_000000_update_kendaraan_table.php` (NEW)
- ✅ `database/migrations/VEHICLE_SCHEMA.sql` (NEW)
- ✅ `app/Models/Kendaraan.php` (MODIFIED)
- ✅ `app/Http/Controllers/Api/KendaraanController.php` (MODIFIED)
- ✅ `routes/api.php` (MODIFIED)
- ✅ `docs/VEHICLE_API_DOCUMENTATION.md` (NEW)

### Flutter
- ✅ `lib/data/services/vehicle_api_service.dart` (NEW)
- ✅ `docs/VEHICLE_API_INTEGRATION_GUIDE.md` (NEW)
- ⬜ `lib/logic/providers/profile_provider.dart` (TO MODIFY)
- ⬜ `lib/presentation/screens/tambah_kendaraan.dart` (TO MODIFY)
- ⬜ `lib/main.dart` (TO MODIFY)

---

## ✅ Next Steps

1. **Run Migration**
   ```bash
   cd qparkin_backend
   php artisan migrate
   php artisan storage:link
   ```

2. **Test Backend API**
   - Test dengan Postman atau cURL
   - Verify semua endpoints working

3. **Update ProfileProvider**
   - Inject VehicleApiService
   - Replace mock methods dengan API calls

4. **Update UI Pages**
   - tambah_kendaraan.dart → pass foto ke provider
   - list_kendaraan.dart → already integrated
   - vehicle_detail_page.dart → already integrated

5. **Test Integration**
   - End-to-end testing
   - Test semua flows

6. **Deploy**
   - Setup production server
   - Configure HTTPS
   - Update base URL

---

## 🐛 Troubleshooting

### "401 Unauthorized"
- Token expired atau invalid
- Login ulang untuk get new token

### "422 Validation Error"
- Check validation rules
- Plat nomor harus unique
- Jenis kendaraan harus valid enum

### "Cannot delete vehicle"
- Vehicle punya transaksi parkir aktif
- Selesaikan transaksi dulu

### Photo not uploading
- Check storage link: `php artisan storage:link`
- Check permissions: `chmod -R 775 storage`
- Check file size < 2MB
- Check format: jpeg/png/jpg

---

## 📞 Support

Dokumentasi lengkap:
- Backend API: `qparkin_backend/docs/VEHICLE_API_DOCUMENTATION.md`
- Integration Guide: `qparkin_app/docs/VEHICLE_API_INTEGRATION_GUIDE.md`
- Quick Reference: `qparkin_app/docs/vehicle_management_quick_reference.md`

---

**Status:** ✅ Backend Complete, ⏳ Flutter Integration Pending
**Last Updated:** 2026-01-01
