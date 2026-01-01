# Vehicle List - Quick Reference

## 🚀 Quick Start

### Run App dengan API Backend
```bash
# Pastikan backend running
cd qparkin_backend
php artisan serve

# Run Flutter app dengan API URL
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.x.xx:8000/api
```

---

## 📱 User Flow

### 1. Lihat List Kendaraan
```
Home Page → Profile → List Kendaraan
atau
Home Page → Tap "Kendaraan" card
```

### 2. Tambah Kendaraan
```
List Kendaraan → Tap FAB (+) → Isi Form → Submit
→ Kembali ke List → Kendaraan baru muncul
```

### 3. Hapus Kendaraan
```
List Kendaraan → Tap Delete Icon → Konfirmasi
→ Kendaraan hilang dari list
```

---

## 🔄 Data Flow

### Fetch Vehicles
```dart
// Dipanggil otomatis saat buka list_kendaraan.dart
ProfileProvider.fetchVehicles()
  → VehicleApiService.getVehicles()
    → GET /api/kendaraan
      → Backend return List<Vehicle>
        → Update UI
```

### Add Vehicle
```dart
// Dipanggil saat submit form di tambah_kendaraan.dart
ProfileProvider.addVehicle(...)
  → VehicleApiService.addVehicle(...)
    → POST /api/kendaraan
      → Backend save & return new Vehicle
        → Add to local list
          → Navigator.pop(true)
            → list_kendaraan refresh
```

### Delete Vehicle
```dart
// Dipanggil saat konfirmasi delete
ProfileProvider.deleteVehicle(id)
  → VehicleApiService.deleteVehicle(id)
    → DELETE /api/kendaraan/{id}
      → Backend delete from DB
        → Remove from local list
          → Update UI
```

---

## 🎨 UI States

### Loading State
```dart
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    ...
  },
)
```

### Empty State
```dart
if (provider.vehicles.isEmpty) {
  return EmptyStateWidget(
    icon: Icons.directions_car_outlined,
    title: 'Belum Ada Kendaraan',
    message: 'Tambahkan kendaraan pertama Anda...',
  );
}
```

### List State
```dart
ListView(
  children: provider.vehicles
      .map((vehicle) => VehicleCard(vehicle))
      .toList(),
)
```

### Error State
```dart
if (provider.hasError) {
  return ErrorWidget(
    message: provider.errorMessage,
    onRetry: () => provider.fetchVehicles(),
  );
}
```

---

## 🔧 Common Operations

### Refresh List
```dart
// Pull-to-refresh
RefreshIndicator(
  onRefresh: () => context.read<ProfileProvider>().fetchVehicles(),
  child: ListView(...),
)

// Manual refresh
context.read<ProfileProvider>().fetchVehicles();
```

### Navigate to Add Vehicle
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => VehicleSelectionPage(),
  ),
);

// Refresh if vehicle was added
if (result == true) {
  context.read<ProfileProvider>().fetchVehicles();
}
```

### Show Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Kendaraan berhasil ditambahkan!'),
    backgroundColor: Color(0xFF4CAF50),
  ),
);
```

---

## 🐛 Debugging

### Check API Connection
```dart
// Add debug print in ProfileProvider
debugPrint('[ProfileProvider] Fetching vehicles from API...');
debugPrint('[ProfileProvider] API URL: $baseUrl');
```

### Check Token
```dart
// In ProfileProvider or VehicleApiService
final token = await _storage.read(key: 'auth_token');
debugPrint('[Auth] Token: ${token?.substring(0, 20)}...');
```

### Check Response
```dart
// In VehicleApiService
debugPrint('[API] Response status: ${response.statusCode}');
debugPrint('[API] Response body: ${response.body}');
```

---

## ⚠️ Common Issues

### Issue: List Kosong
**Check:**
1. Backend running? `php artisan serve`
2. API URL correct? Check `--dart-define=API_URL`
3. Token valid? Try logout & login
4. Network connection? Check WiFi/mobile data

### Issue: Kendaraan Tidak Muncul Setelah Tambah
**Check:**
1. `Navigator.pop(true)` di tambah_kendaraan.dart?
2. `fetchVehicles()` dipanggil setelah pop?
3. Backend berhasil save? Check backend logs
4. Response dari backend valid? Check API response

### Issue: Error "Failed to load vehicles"
**Check:**
1. Token expired? Logout & login ulang
2. Backend error? Check `storage/logs/laravel.log`
3. Network timeout? Increase timeout duration
4. CORS issue? Check backend CORS config

---

## 📊 API Endpoints Used

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/kendaraan` | Fetch all vehicles |
| POST | `/api/kendaraan` | Add new vehicle |
| GET | `/api/kendaraan/{id}` | Get vehicle details |
| PUT | `/api/kendaraan/{id}` | Update vehicle |
| DELETE | `/api/kendaraan/{id}` | Delete vehicle |
| PUT | `/api/kendaraan/{id}/set-active` | Set active vehicle |

---

## 🧪 Testing Checklist

- [ ] List kendaraan load saat buka page
- [ ] Loading indicator muncul saat fetch
- [ ] Empty state muncul jika belum ada kendaraan
- [ ] Tambah kendaraan berhasil
- [ ] Kendaraan baru muncul di list
- [ ] Pull-to-refresh works
- [ ] Hapus kendaraan berhasil
- [ ] Kendaraan hilang dari list
- [ ] Data persist setelah restart app
- [ ] Error handling works (no internet, etc)

---

## 📝 Code Snippets

### Get Vehicles in Widget
```dart
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    final vehicles = provider.vehicles;
    
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return VehicleCard(vehicle: vehicle);
      },
    );
  },
)
```

### Add Vehicle
```dart
await context.read<ProfileProvider>().addVehicle(
  platNomor: 'B 1234 XYZ',
  jenisKendaraan: 'Roda Empat',
  merk: 'Toyota',
  tipe: 'Avanza',
  warna: 'Hitam',
  isActive: true,
  foto: imageFile,
);
```

### Delete Vehicle
```dart
await context.read<ProfileProvider>().deleteVehicle(vehicleId);
```

---

## 🔗 Related Files

- `lib/presentation/screens/list_kendaraan.dart` - List UI
- `lib/presentation/screens/tambah_kendaraan.dart` - Add form
- `lib/presentation/screens/vehicle_detail_page.dart` - Detail page
- `lib/logic/providers/profile_provider.dart` - State management
- `lib/data/services/vehicle_api_service.dart` - API calls
- `lib/data/models/vehicle_model.dart` - Data model

---

**Quick Reference Version:** 1.0  
**Last Updated:** 2026-01-01  
**Status:** Production Ready
