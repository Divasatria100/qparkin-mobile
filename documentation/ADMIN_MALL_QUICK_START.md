# Quick Start: Implementasi Admin Mall Registration → Mobile App

**Estimasi Total: 3 jam**

---

## 🚀 Quick Commands

### Backend Setup (90 menit)

```bash
cd qparkin_backend

# 1. Database Migration (15 menit)
php artisan make:migration add_coordinates_to_mall_table
# Edit file migration yang dibuat, copy dari implementation guide
php artisan migrate

# 2. Test Database (5 menit)
php artisan tinker
>>> Schema::getColumnListing('mall')
>>> Schema::getColumnListing('user')
>>> exit

# 3. Test API (5 menit)
curl http://localhost:8000/api/mall

# 4. Clear Cache (2 menit)
php artisan config:clear
php artisan cache:clear
```

### Mobile App Setup (60 menit)

```bash
cd qparkin_app

# 1. Tambah Dependency (5 menit)
# Edit pubspec.yaml, tambah: url_launcher: ^6.2.0
flutter pub get

# 2. Run App (5 menit)
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# 3. Test (5 menit)
flutter analyze
flutter test
```

---

## 📝 Checklist Cepat

### Backend (10 tasks)

#### Database (4 tasks - 35 menit)
- [ ] Edit migration user - tambah `requested_mall_latitude`, `requested_mall_longitude`
- [ ] Buat migration mall - tambah `latitude`, `longitude`, `google_maps_url`, `status`
- [ ] Update Model User - tambah field ke $fillable
- [ ] Update Model Mall - tambah field & helper methods

#### Controllers (4 tasks - 35 menit)
- [ ] Fix route: `routes/web.php` - ganti RegisteredUserController
- [ ] Update `AdminMallRegistrationController::store()`
- [ ] Update `SuperAdminController::pengajuan()` & `approvePengajuan()`
- [ ] Implementasi `MallController::index()` & `show()`

#### Views (2 tasks - 20 menit)
- [ ] Fix `pengajuan.blade.php` - field names
- [ ] Update `super-pengajuan-akun.js` - AJAX real

### Mobile App (5 tasks - 60 menit)

#### Services (2 tasks - 25 menit)
- [ ] Buat `mall_service.dart` (NEW)
- [ ] Update `mall_model.dart` - tambah googleMapsUrl

#### Integration (3 tasks - 35 menit)
- [ ] Update `map_provider.dart` - konsumsi API
- [ ] Update `map_page.dart` - Google Maps navigation
- [ ] Update `pubspec.yaml` - tambah url_launcher

---

## 🔥 Critical Changes (Must Do)

### Backend - 3 Critical Fixes

#### 1. Route Fix (2 menit)
**File:** `qparkin_backend/routes/web.php`

```php
// GANTI ini:
Route::post('/register', [RegisteredUserController::class, 'store']);

// DENGAN ini:
use App\Http\Controllers\Auth\AdminMallRegistrationController;
Route::post('/register', [AdminMallRegistrationController::class, 'store']);
```

#### 2. Approve Flow Fix (15 menit)
**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

Method `approvePengajuan()` harus:
- ✅ Create mall dengan koordinat
- ✅ Set status='active'
- ✅ Generate google_maps_url
- ✅ Create admin_mall entry
- ✅ Update user role & status

**Copy implementasi lengkap dari:** `ADMIN_MALL_END_TO_END_IMPLEMENTATION_GUIDE.md` Section 5.2

#### 3. API Implementation (10 menit)
**File:** `qparkin_backend/app/Http/Controllers/Api/MallController.php`

```php
public function index()
{
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
        ])
        ->get();

    return response()->json([
        'success' => true,
        'data' => $malls
    ]);
}
```

### Mobile App - 2 Critical Changes

#### 1. MapProvider API Integration (10 menit)
**File:** `qparkin_app/lib/logic/providers/map_provider.dart`

```dart
// GANTI method loadMalls():
Future<void> loadMalls() async {
  try {
    _isLoading = true;
    notifyListeners();

    // Fetch from API (bukan dummy data)
    _malls = await _mallService.fetchMalls();

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    // Fallback to dummy
    _malls = getDummyMalls();
    _errorMessage = 'Menggunakan data demo';
    notifyListeners();
  }
}
```

#### 2. Google Maps Navigation (10 menit)
**File:** `qparkin_app/lib/presentation/screens/map_page.dart`

```dart
// TAMBAH method:
Future<void> _openGoogleMapsNavigation(MallModel mall) async {
  final url = mall.googleMapsUrl ?? 
    'https://www.google.com/maps/dir/?api=1&destination=${mall.latitude},${mall.longitude}';
  
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

// GANTI tombol "Rute" dengan:
TextButton.icon(
  onPressed: () => _openGoogleMapsNavigation(mall),
  icon: const Icon(Icons.map),
  label: const Text('Lihat Rute'),
)
```

---

## 🧪 Testing Quick Guide

### Backend Test (10 menit)

```bash
# 1. Test Registrasi
# Buka browser: http://localhost:8000/register
# Submit form dengan koordinat

# 2. Test Pengajuan
# Login superadmin: http://localhost:8000/superadmin/pengajuan
# Verify: Data muncul

# 3. Test Approve
# Klik approve
# Verify: Mall created di database

# 4. Test API
curl http://localhost:8000/api/mall
# Expected: JSON dengan mall yang baru di-approve
```

### Mobile App Test (10 menit)

```bash
# 1. Run App
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# 2. Buka Tab Peta
# Verify: Markers muncul

# 3. Tap Mall Card
# Verify: Info muncul

# 4. Tap "Lihat Rute"
# Verify: Google Maps terbuka
```

### End-to-End Test (10 menit)

```
1. Registrasi admin mall baru (dengan koordinat)
   ↓
2. Login superadmin → Approve pengajuan
   ↓
3. Verify: Mall created di database dengan status='active'
   ↓
4. Test API: curl http://localhost:8000/api/mall
   ↓
5. Restart mobile app
   ↓
6. Verify: Mall baru muncul di peta
   ↓
7. Tap "Lihat Rute"
   ↓
8. Verify: Google Maps terbuka dengan destination benar
```

---

## 🐛 Common Issues & Quick Fixes

### Backend

**Issue:** Migration error "column already exists"
```bash
php artisan migrate:rollback --step=1
php artisan migrate
```

**Issue:** API return empty
```bash
# Check database
php artisan tinker
>>> Mall::where('status', 'active')->count()
```

**Issue:** Approve gagal
```bash
# Check logs
tail -f storage/logs/laravel.log
```

### Mobile App

**Issue:** Mall tidak load
```bash
# Check console
flutter run --verbose

# Check API URL
echo $API_URL
```

**Issue:** Google Maps tidak buka
```bash
# Check dependency
flutter pub get

# Check google_maps_url
# Harus format: https://www.google.com/maps/dir/?api=1&destination=LAT,LNG
```

---

## 📚 Detailed Documentation

Untuk implementasi lengkap dengan kode detail, lihat:

1. **ADMIN_MALL_END_TO_END_IMPLEMENTATION_GUIDE.md**
   - Section 3: Step-by-step implementation (12 steps)
   - Section 4: Checklist lengkap
   - Section 5: Troubleshooting

2. **ADMIN_MALL_MOBILE_INTEGRATION_MINIMAL_PBL.md**
   - Section 3: Solusi minimal untuk PBL
   - Section 6: Checklist dengan estimasi waktu

3. **ADMIN_MALL_IMPLEMENTATION_STATUS.md**
   - Status current implementation
   - File yang perlu dimodifikasi
   - Success criteria

---

## 🎯 Success Indicators

### ✅ Backend Success:
- Form registrasi submit → data tersimpan dengan status pending
- Halaman pengajuan menampilkan data dengan benar
- Approve → mall created dengan status active
- API return mall dengan koordinat & google_maps_url

### ✅ Mobile App Success:
- Malls load dari API (bukan dummy)
- Markers muncul di koordinat yang benar
- Tombol "Lihat Rute" buka Google Maps
- Navigation ke mall berfungsi

### ✅ End-to-End Success:
- Registrasi → Approve → API → Mobile → Navigation
- Tidak ada error di console
- Data konsisten di semua layer

---

**Ready to Start?**

1. Baca dokumen ini untuk overview
2. Buka `ADMIN_MALL_END_TO_END_IMPLEMENTATION_GUIDE.md` untuk detail
3. Ikuti checklist step-by-step
4. Test setiap step sebelum lanjut
5. Verifikasi end-to-end di akhir

**Estimasi Total: 3 jam**  
**Prioritas: High (untuk PBL)**

Good luck! 🚀
