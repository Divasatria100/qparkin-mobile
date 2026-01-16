# Vehicle Integration Quick Start Guide

## 🚀 Quick Setup (5 Minutes)

### Step 1: Backend Setup (2 minutes)

```bash
# Navigate to backend
cd qparkin_backend

# Run migration
php artisan migrate

# Create storage link
php artisan storage:link

# Start server
php artisan serve
```

**Expected Output:**
```
Migration table created successfully.
Migrating: 2025_01_01_000000_update_kendaraan_table
Migrated:  2025_01_01_000000_update_kendaraan_table

The [public/storage] link has been connected to [storage/app/public].

Laravel development server started: http://127.0.0.1:8000
```

### Step 2: Test API (1 minute)

```bash
# Test health check
curl http://localhost:8000/api/health

# Expected: {"status":"ok","message":"QParkin API is running",...}
```

### Step 3: Flutter Setup (2 minutes)

```bash
# Navigate to app
cd qparkin_app

# Get dependencies (if not already done)
flutter pub get

# Run app
flutter run
```

---

## 📋 Checklist

### Backend
- [ ] Migration berhasil dijalankan
- [ ] Storage link dibuat
- [ ] Server berjalan di http://localhost:8000
- [ ] Health check endpoint response OK

### Flutter
- [ ] Dependencies terinstall
- [ ] App berjalan tanpa error
- [ ] Bisa login ke aplikasi

---

## 🧪 Quick Test

### 1. Test Backend API

```bash
# Get token (ganti dengan credentials yang valid)
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}' \
  | jq -r '.token')

# Get vehicles
curl -X GET http://localhost:8000/api/kendaraan \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"

# Add vehicle
curl -X POST http://localhost:8000/api/kendaraan \
  -H "Authorization: Bearer $TOKEN" \
  -F "plat_nomor=B 1234 TEST" \
  -F "jenis_kendaraan=Roda Empat" \
  -F "merk=Toyota" \
  -F "tipe=Avanza" \
  -F "warna=Hitam" \
  -F "is_active=true"
```

### 2. Test Flutter App

1. **Login** ke aplikasi
2. **Navigate** ke Profile → List Kendaraan
3. **Tap** tombol "+" (floating action button)
4. **Fill form:**
   - Pilih jenis: Roda Empat
   - Merek: Toyota
   - Tipe: Avanza
   - Plat: B 1234 XYZ
   - Warna: Hitam (optional)
   - Status: Kendaraan Utama
5. **Submit** dan verify success message
6. **Check** list kendaraan terupdate

---

## 📊 Database Check

```sql
-- Check if migration ran
SELECT * FROM migrations WHERE migration LIKE '%kendaraan%';

-- Check table structure
DESCRIBE kendaraan;

-- Check sample data
SELECT * FROM kendaraan;

-- Check active vehicles
SELECT id_kendaraan, plat, merk, tipe, is_active 
FROM kendaraan 
WHERE is_active = TRUE;
```

---

## 🔧 Common Issues & Quick Fixes

### Issue: Migration fails
```bash
# Solution: Reset and re-run
php artisan migrate:fresh
```

### Issue: Storage link fails
```bash
# Solution: Remove and recreate
rm public/storage
php artisan storage:link
```

### Issue: Permission denied
```bash
# Solution: Fix permissions
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

### Issue: 401 Unauthorized
```bash
# Solution: Check token
# Make sure you're logged in and token is valid
```

### Issue: 422 Validation Error
```bash
# Solution: Check input
# - Plat nomor must be unique
# - Jenis kendaraan must be valid enum
# - Required fields must be filled
```

---

## 📁 File Locations

### Backend Files
```
qparkin_backend/
├── database/migrations/
│   ├── 2025_01_01_000000_update_kendaraan_table.php ← NEW
│   └── VEHICLE_SCHEMA.sql ← NEW
├── app/
│   ├── Models/Kendaraan.php ← UPDATED
│   └── Http/Controllers/Api/KendaraanController.php ← UPDATED
├── routes/api.php ← UPDATED
└── docs/VEHICLE_API_DOCUMENTATION.md ← NEW
```

### Flutter Files
```
qparkin_app/
├── lib/
│   ├── data/services/vehicle_api_service.dart ← NEW
│   ├── logic/providers/profile_provider.dart ← TO UPDATE
│   └── presentation/screens/
│       ├── tambah_kendaraan.dart ← TO UPDATE
│       ├── list_kendaraan.dart ← READY
│       └── vehicle_detail_page.dart ← READY
└── docs/VEHICLE_API_INTEGRATION_GUIDE.md ← NEW
```

---

## 🎯 What's Working Now

### Backend ✅
- [x] Database schema updated
- [x] Model with relationships
- [x] Full CRUD API endpoints
- [x] Photo upload support
- [x] Authentication & authorization
- [x] Validation & error handling
- [x] Statistics integration

### Flutter ⏳
- [x] VehicleApiService created
- [x] UI pages designed
- [ ] ProfileProvider integration (NEXT STEP)
- [ ] Photo upload from UI (NEXT STEP)
- [ ] End-to-end testing (NEXT STEP)

---

## 📝 Next Implementation Steps

### 1. Update ProfileProvider (15 minutes)

File: `lib/logic/providers/profile_provider.dart`

```dart
// Add to constructor
final VehicleApiService _vehicleApiService;

ProfileProvider({required VehicleApiService vehicleApiService})
    : _vehicleApiService = vehicleApiService;

// Update methods to call API
Future<void> fetchVehicles() async {
  _vehicles = await _vehicleApiService.getVehicles();
  notifyListeners();
}

Future<void> addVehicle(VehicleModel vehicle, {File? foto}) async {
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
  notifyListeners();
}
```

### 2. Update main.dart (5 minutes)

```dart
void main() {
  final vehicleApiService = VehicleApiService(
    baseUrl: 'http://192.168.x.x:8000/api', // Ganti dengan IP server
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            vehicleApiService: vehicleApiService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 3. Update tambah_kendaraan.dart (10 minutes)

```dart
// In _submitForm method
await provider.addVehicle(newVehicle, foto: selectedImage);
```

### 4. Test Everything (10 minutes)

- [ ] Add vehicle with photo
- [ ] Add vehicle without photo
- [ ] View vehicle list
- [ ] View vehicle details
- [ ] Set active vehicle
- [ ] Delete vehicle
- [ ] Test validation errors

---

## 🎓 Learning Resources

### Documentation
1. **Backend API:** `qparkin_backend/docs/VEHICLE_API_DOCUMENTATION.md`
2. **Integration Guide:** `qparkin_app/docs/VEHICLE_API_INTEGRATION_GUIDE.md`
3. **Quick Reference:** `qparkin_app/docs/vehicle_management_quick_reference.md`

### Code Examples
- **Backend Controller:** `app/Http/Controllers/Api/KendaraanController.php`
- **Flutter Service:** `lib/data/services/vehicle_api_service.dart`
- **Model:** `lib/data/models/vehicle_model.dart`

---

## 💡 Tips

1. **Development:** Use `http://192.168.x.x:8000/api` (local network IP)
2. **Production:** Use `https://your-domain.com/api` (HTTPS required)
3. **Testing:** Use Postman or cURL untuk test API dulu sebelum integrate
4. **Debugging:** Check Laravel logs di `storage/logs/laravel.log`
5. **Photos:** Max 2MB, format: jpeg/png/jpg

---

## ✅ Success Criteria

You'll know integration is successful when:
- [ ] Backend API returns vehicle data
- [ ] Flutter app can add vehicle with photo
- [ ] Vehicle list displays correctly
- [ ] Can set active vehicle
- [ ] Can delete vehicle
- [ ] Photos display correctly
- [ ] No console errors

---

## 🆘 Need Help?

1. **Check logs:**
   - Backend: `storage/logs/laravel.log`
   - Flutter: Console output

2. **Common commands:**
   ```bash
   # Backend
   php artisan route:list | grep kendaraan
   php artisan tinker
   
   # Flutter
   flutter clean
   flutter pub get
   flutter run -v
   ```

3. **Documentation:**
   - Read `VEHICLE_API_INTEGRATION_SUMMARY.md`
   - Check API docs
   - Review code comments

---

**Ready to start?** Follow Step 1 above! 🚀
