# 🔐 FIX: HTTP 401 - AUTHENTICATION FLOW YANG BENAR

## 🎯 KLARIFIKASI ARSITEKTUR

### **Konteks Aplikasi**

QParkin adalah **aplikasi authenticated**, bukan aplikasi publik:
- ✅ Semua halaman (termasuk MapPage) hanya bisa diakses setelah login
- ✅ Sistem memiliki role-based access (user, admin mall, superadmin)
- ✅ Seluruh data berada dalam boundary autentikasi
- ✅ Tidak ada konten publik yang bisa diakses tanpa login

**Analogi:** Seperti mobile banking, bukan seperti Google Maps.

---

## 🔍 AKAR PENYEBAB 401 (YANG BENAR)

### **Root Cause: Authentication Flow Tidak Lengkap**

**Masalah BUKAN pada endpoint public/protected**, tetapi pada:

1. ❌ **MallService tidak mengirim token**
   ```dart
   // SEBELUM - Tidak ada Authorization header
   final response = await http.get(
     Uri.parse('$baseUrl/api/mall'),
     headers: {
       'Accept': 'application/json',
       'Content-Type': 'application/json',
       // ❌ TIDAK ADA: 'Authorization': 'Bearer $token'
     },
   );
   ```

2. ❌ **Token tidak diambil dari storage**
   - Service lain (BookingService, ProfileService) sudah mengambil token
   - MallService belum implement token retrieval

3. ✅ **Endpoint sudah benar** - Harus protected dengan `auth:sanctum`
   - Mall data adalah bagian dari aplikasi authenticated
   - Konsisten dengan arsitektur aplikasi

---

## ✅ SOLUSI YANG BENAR

### **1. Kembalikan Endpoint ke Protected**

**File:** `qparkin_backend/routes/api.php`

```php
// REVISI - Mall endpoint kembali ke dalam middleware auth:sanctum
Route::middleware('auth:sanctum')->group(function () {
    
    // ... auth routes
    
    // Mall Information - PROTECTED (butuh login)
    Route::prefix('mall')->group(function () {
        Route::get('/', [MallController::class, 'index']);
        Route::get('/{id}', [MallController::class, 'show']);
        Route::get('/{id}/parkiran', [MallController::class, 'getParkiran']);
        Route::get('/{id}/tarif', [MallController::class, 'getTarif']);
    });
    
    // ... other protected routes
});
```

**Alasan:**
- ✅ Konsisten dengan arsitektur authenticated app
- ✅ Semua data dalam boundary autentikasi
- ✅ Sesuai dengan business flow (login → akses fitur)
- ✅ Best practice untuk security

### **2. Tambahkan Token Authentication di MallService**

**File:** `qparkin_app/lib/data/services/mall_service.dart`

**SEBELUM:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mall_model.dart';

class MallService {
  final String baseUrl;
  
  MallService({required this.baseUrl});
  
  Future<List<MallModel>> fetchMalls() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mall'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // ❌ TIDAK ADA TOKEN
        },
      ).timeout(const Duration(seconds: 10));
      
      // ... parsing response
    }
  }
}
```

**SESUDAH:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/mall_model.dart';

class MallService {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  MallService({required this.baseUrl});
  
  Future<List<MallModel>> fetchMalls() async {
    try {
      // ✅ 1. Ambil token dari secure storage
      final token = await _storage.read(key: 'auth_token');
      
      // ✅ 2. Validasi token tersedia
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login first.');
      }
      
      // ✅ 3. Kirim request dengan Authorization header
      final response = await http.get(
        Uri.parse('$baseUrl/api/mall'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // ✅ KIRIM TOKEN
        },
      ).timeout(const Duration(seconds: 10));
      
      // ✅ 4. Handle 401 Unauthorized
      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Token expired or invalid.');
      }
      
      // ... parsing response
    }
  }
}
```

**Perubahan Kunci:**
1. ✅ Import `flutter_secure_storage`
2. ✅ Tambah instance `_storage`
3. ✅ Ambil token dari storage sebelum request
4. ✅ Validasi token tidak null/empty
5. ✅ Kirim token di header `Authorization: Bearer $token`
6. ✅ Handle 401 dengan error message yang jelas

---

## 📊 AUTHENTICATION FLOW

### **Flow yang Benar:**

```
1. User Login
   ↓
2. AuthService.login() → Simpan token ke SecureStorage
   ↓
3. User navigasi ke MapPage
   ↓
4. MapProvider.loadMalls() dipanggil
   ↓
5. MallService.fetchMalls()
   ├─ Ambil token dari SecureStorage
   ├─ Validasi token tersedia
   ├─ Kirim GET /api/mall dengan Authorization header
   └─ Backend: Verifikasi token dengan auth:sanctum
   ↓
6. Backend: 200 OK + data mall
   ↓
7. Flutter: Parse JSON → List<MallModel>
   ↓
8. UI: Tampilkan daftar mall ✅
```

### **Error Handling:**

```
Skenario 1: Token Tidak Ada (User belum login)
  MallService.fetchMalls()
    → token == null
    → throw Exception('Authentication required')
    → UI: Redirect ke login page

Skenario 2: Token Expired
  MallService.fetchMalls()
    → Backend: 401 Unauthorized
    → throw Exception('Token expired')
    → UI: Redirect ke login page

Skenario 3: Network Error
  MallService.fetchMalls()
    → Timeout / Connection error
    → throw Exception('Network error')
    → UI: Error state dengan retry button
```

---

## 🔒 KONSISTENSI DENGAN SERVICE LAIN

### **Pola yang Sama di Service Lain:**

**BookingService:**
```dart
Future<BookingResponse> createBooking(BookingRequest request) async {
  final token = await _storage.read(key: 'auth_token');
  
  final response = await http.post(
    Uri.parse('$baseUrl/api/booking'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',  // ✅ Kirim token
    },
    body: json.encode(request.toJson()),
  );
  // ...
}
```

**ProfileService:**
```dart
Future<Map<String, dynamic>> getProfile() async {
  final token = await _storage.read(key: 'auth_token');
  
  final response = await http.get(
    Uri.parse('$baseUrl/api/user/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',  // ✅ Kirim token
    },
  );
  // ...
}
```

**VehicleService:**
```dart
Future<List<Vehicle>> getVehicles() async {
  final authToken = await _storage.read(key: 'auth_token');
  
  final response = await http.get(
    Uri.parse('$baseUrl/api/kendaraan'),
    headers: {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',  // ✅ Kirim token
    },
  );
  // ...
}
```

**MallService sekarang konsisten dengan pola yang sama!** ✅

---

## 🧪 TESTING & VERIFIKASI

### **Test 1: Login → MapPage**

```bash
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

**Steps:**
1. Buka app
2. Login dengan nomor HP dan PIN
3. Navigasi ke MapPage
4. Buka tab "Daftar Mall"

**Expected Result:**
- ✅ Loading state muncul
- ✅ Request ke `/api/mall` dengan Authorization header
- ✅ Backend: 200 OK
- ✅ Daftar mall dari database muncul

**Debug Logs:**
```
[MallService] Fetching malls with token: eyJ0eXAiOiJKV1QiLCJhbGc...
[MapProvider] Loaded 3 malls from API
```

### **Test 2: Akses MapPage Tanpa Login**

**Steps:**
1. Buka app (belum login)
2. Coba akses MapPage langsung

**Expected Result:**
- ❌ Token tidak tersedia
- ❌ Exception: "Authentication required. Please login first."
- ✅ Redirect ke login page (jika ada guard)

### **Test 3: Token Expired**

**Steps:**
1. Login
2. Tunggu token expire (atau hapus token dari backend)
3. Refresh MapPage

**Expected Result:**
- ❌ Backend: 401 Unauthorized
- ❌ Exception: "Unauthorized. Token expired or invalid."
- ✅ Redirect ke login page

### **Test 4: Endpoint Protected**

```bash
# Test tanpa token
curl -X GET http://192.168.1.100:8000/api/mall \
  -H "Accept: application/json"
```

**Expected Result:**
```json
{
  "message": "Unauthenticated."
}
```
**Status:** 401 Unauthorized ✅

```bash
# Test dengan token valid
curl -X GET http://192.168.1.100:8000/api/mall \
  -H "Accept: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."
```

**Expected Result:**
```json
{
  "success": true,
  "data": [...]
}
```
**Status:** 200 OK ✅

---

## 📝 PERBANDINGAN SOLUSI

### **Solusi SALAH (Sebelumnya):**

| Aspek | Implementasi | Masalah |
|-------|--------------|---------|
| **Endpoint** | Public (tanpa auth) | ❌ Tidak konsisten dengan arsitektur |
| **Security** | Tidak ada autentikasi | ❌ Data bisa diakses tanpa login |
| **Business Logic** | User bisa lihat mall tanpa login | ❌ Tidak sesuai dengan flow aplikasi |
| **Konsistensi** | Berbeda dengan endpoint lain | ❌ Inkonsisten dengan service lain |

### **Solusi BENAR (Sekarang):**

| Aspek | Implementasi | Benefit |
|-------|--------------|---------|
| **Endpoint** | Protected (auth:sanctum) | ✅ Konsisten dengan arsitektur |
| **Security** | Butuh Bearer token | ✅ Data hanya bisa diakses setelah login |
| **Business Logic** | User harus login dulu | ✅ Sesuai dengan flow aplikasi |
| **Konsistensi** | Sama dengan endpoint lain | ✅ Konsisten dengan service lain |

---

## 🎯 CHECKLIST PERBAIKAN

### **Backend**

- ✅ Kembalikan route `/api/mall/*` ke dalam `auth:sanctum` middleware
- ✅ Pastikan endpoint protected dengan benar
- ✅ Test endpoint tanpa token → 401 Unauthorized
- ✅ Test endpoint dengan token valid → 200 OK

### **Flutter**

- ✅ Import `flutter_secure_storage` di MallService
- ✅ Tambah instance `_storage` di MallService
- ✅ Ambil token dari storage sebelum request
- ✅ Validasi token tidak null/empty
- ✅ Kirim token di header `Authorization: Bearer $token`
- ✅ Handle 401 dengan error message yang jelas
- ✅ Test flow: Login → MapPage → Daftar mall muncul

### **Error Handling**

- ✅ Token null → Exception dengan message jelas
- ✅ 401 Unauthorized → Exception dengan message jelas
- ✅ Network error → Exception dengan message jelas
- ✅ UI menampilkan error state yang sesuai

---

## 🔧 TROUBLESHOOTING

### **Masalah: Masih dapat 401 setelah perbaikan**

**Solusi:**
1. Cek token tersimpan di storage:
   ```dart
   final token = await _storage.read(key: 'auth_token');
   debugPrint('Token: $token');
   ```
2. Pastikan user sudah login
3. Cek token tidak expired
4. Restart app setelah login

### **Masalah: Token null meskipun sudah login**

**Solusi:**
1. Cek AuthService menyimpan token dengan benar:
   ```dart
   await _secureStorage.write(key: 'auth_token', value: token);
   ```
2. Cek key storage sama: `'auth_token'`
3. Test dengan SharedPreferences jika SecureStorage bermasalah

### **Masalah: Backend tetap return 401 meskipun token dikirim**

**Solusi:**
1. Cek format header: `Authorization: Bearer <token>`
2. Cek token valid di backend
3. Clear route cache Laravel:
   ```bash
   php artisan route:clear
   php artisan config:clear
   ```
4. Restart Laravel server

---

## 📖 BEST PRACTICES

### **Authentication Flow**

1. ✅ **Simpan token di SecureStorage** (bukan SharedPreferences)
2. ✅ **Ambil token sebelum setiap authenticated request**
3. ✅ **Validasi token tersedia sebelum request**
4. ✅ **Handle 401 dengan redirect ke login**
5. ✅ **Konsisten di semua service**

### **Security**

1. ✅ **Semua endpoint user data harus protected**
2. ✅ **Gunakan `auth:sanctum` middleware**
3. ✅ **Token di header, bukan di URL/body**
4. ✅ **Validate token di setiap request**
5. ✅ **Expire token setelah periode tertentu**

### **Error Handling**

1. ✅ **Error message yang jelas dan actionable**
2. ✅ **Redirect ke login jika token invalid**
3. ✅ **Retry mechanism untuk network error**
4. ✅ **Loading state saat fetch data**
5. ✅ **Empty state jika data kosong**

---

## 🎉 HASIL AKHIR

### **Sebelum Perbaikan:**

```
User login → MapPage
  ↓
MallService.fetchMalls() tanpa token
  ↓
Backend: 401 Unauthorized ❌
  ↓
UI: Error state "Koneksi ke Server Gagal"
```

### **Setelah Perbaikan:**

```
User login → Token tersimpan
  ↓
MapPage → MallService.fetchMalls()
  ↓
Ambil token dari storage
  ↓
Request dengan Authorization header
  ↓
Backend: 200 OK ✅
  ↓
UI: Daftar mall dari database muncul
```

---

**Dokumentasi dibuat:** 2026-01-11
**Status:** ✅ FIXED - Authentication Flow Lengkap
**Arsitektur:** Authenticated App (bukan Public App)
