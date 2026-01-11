# 🔐 FIX: HTTP 401 UNAUTHORIZED - ENDPOINT /API/MALL

## 🔍 AKAR PENYEBAB

### **Error yang Terjadi**

```
Failed to load malls: 401 (Unauthorized)
Context: MapProvider.loadMalls
Source: MallService.fetchMalls
```

### **Root Cause Analysis**

**Masalah:** Endpoint `/api/mall` dilindungi oleh middleware `auth:sanctum` di `routes/api.php`, tetapi `MallService.fetchMalls()` tidak mengirim token autentikasi.

**Lokasi Masalah:**

1. **Backend Route** (`qparkin_backend/routes/api.php`)
   ```php
   // SEBELUM - Mall endpoint di dalam middleware auth:sanctum
   Route::middleware('auth:sanctum')->group(function () {
       // ...
       Route::prefix('mall')->group(function () {
           Route::get('/', [MallController::class, 'index']);  // ❌ Butuh auth
           Route::get('/{id}', [MallController::class, 'show']);
           Route::get('/{id}/parkiran', [MallController::class, 'getParkiran']);
           Route::get('/{id}/tarif', [MallController::class, 'getTarif']);
       });
   });
   ```

2. **Flutter Service** (`qparkin_app/lib/data/services/mall_service.dart`)
   ```dart
   // SEBELUM - Tidak mengirim Authorization header
   final response = await http.get(
     Uri.parse('$baseUrl/api/mall'),
     headers: {
       'Accept': 'application/json',
       'Content-Type': 'application/json',
       // ❌ TIDAK ADA: 'Authorization': 'Bearer $token'
     },
   );
   ```

**Mengapa Ini Masalah:**

- User **belum login** saat membuka MapPage
- Daftar mall **harus terlihat sebelum login** (untuk menarik user)
- Endpoint membutuhkan autentikasi, tetapi tidak ada token yang dikirim
- Result: HTTP 401 Unauthorized

---

## ✅ SOLUSI YANG DITERAPKAN

### **Pendekatan: Jadikan Endpoint Mall PUBLIC**

**Alasan:**
1. ✅ Daftar mall adalah informasi publik (seperti Google Maps)
2. ✅ User perlu melihat mall sebelum memutuskan untuk register/login
3. ✅ Tidak ada data sensitif dalam daftar mall
4. ✅ Lebih sederhana daripada menambah token handling di MallService

### **Perubahan Backend Route**

**File:** `qparkin_backend/routes/api.php`

```php
// SEBELUM
Route::middleware('auth:sanctum')->group(function () {
    // ...
    Route::prefix('mall')->group(function () {
        Route::get('/', [MallController::class, 'index']);
        Route::get('/{id}', [MallController::class, 'show']);
        Route::get('/{id}/parkiran', [MallController::class, 'getParkiran']);
        Route::get('/{id}/tarif', [MallController::class, 'getTarif']);
    });
    // ...
});

// SESUDAH
// Public Routes - Mall Information (accessible without authentication)
Route::prefix('mall')->group(function () {
    Route::get('/', [MallController::class, 'index']);
    Route::get('/{id}', [MallController::class, 'show']);
    Route::get('/{id}/parkiran', [MallController::class, 'getParkiran']);
    Route::get('/{id}/tarif', [MallController::class, 'getTarif']);
});

Route::middleware('auth:sanctum')->group(function () {
    // Protected routes tetap di sini
    // ...
});
```

### **Tidak Ada Perubahan di Flutter**

**File:** `qparkin_app/lib/data/services/mall_service.dart`

✅ **TIDAK PERLU DIUBAH** - MallService tetap seperti sekarang:

```dart
Future<List<MallModel>> fetchMalls() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mall'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        // ✅ Tidak perlu token karena endpoint sekarang public
      },
    ).timeout(const Duration(seconds: 10));
    
    // ... parsing response
  }
}
```

---

## 🔒 KEAMANAN & LOGIKA BISNIS

### **Endpoint yang Seharusnya PUBLIC**

✅ **Mall Information** - Informasi umum tentang mall
- `GET /api/mall` - Daftar mall
- `GET /api/mall/{id}` - Detail mall
- `GET /api/mall/{id}/parkiran` - Info parkiran mall
- `GET /api/mall/{id}/tarif` - Tarif parkir mall

**Alasan:**
- Data publik seperti Google Maps / Waze
- Tidak ada informasi sensitif user
- Diperlukan untuk onboarding / marketing
- User perlu tahu "apa yang ditawarkan" sebelum register

### **Endpoint yang HARUS PROTECTED**

🔐 **User-Specific Data** - Data pribadi user
- `GET /api/user/profile` - Profil user
- `GET /api/kendaraan` - Kendaraan user
- `POST /api/booking` - Booking parkir
- `GET /api/transaksi` - Riwayat transaksi

**Alasan:**
- Data pribadi user
- Operasi yang mengubah data
- Memerlukan identifikasi user
- Risiko keamanan jika public

---

## 📊 PERBANDINGAN SEBELUM & SESUDAH

### **Sebelum Perbaikan**

```
User membuka MapPage
  ↓
MapProvider.loadMalls() dipanggil
  ↓
MallService.fetchMalls() → GET /api/mall
  ↓
Backend: "401 Unauthorized" (butuh token)
  ↓
Flutter: Exception "Failed to load malls: 401"
  ↓
UI: Error state "Koneksi ke Server Gagal" ❌
```

### **Sesudah Perbaikan**

```
User membuka MapPage
  ↓
MapProvider.loadMalls() dipanggil
  ↓
MallService.fetchMalls() → GET /api/mall
  ↓
Backend: "200 OK" (endpoint public) ✅
  ↓
Flutter: Parse JSON → List<MallModel>
  ↓
UI: Tampilkan daftar mall dari database ✅
```

---

## 🧪 TESTING & VERIFIKASI

### **Test 1: Akses Endpoint Tanpa Token**

```bash
# Test endpoint mall tanpa Authorization header
curl -X GET http://192.168.1.100:8000/api/mall \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Expected Result:**
```json
{
  "success": true,
  "message": "Malls retrieved successfully",
  "data": [
    {
      "id_mall": 1,
      "nama_mall": "Mega Mall Batam Centre",
      "alamat_lengkap": "Jl. Engku Putri no.1, Batam Centre",
      "latitude": 1.1191,
      "longitude": 104.0538,
      "google_maps_url": "https://maps.google.com/?q=1.1191,104.0538",
      "status": "active",
      "kapasitas": 45,
      "available_slots": 45,
      "has_slot_reservation_enabled": true
    }
  ]
}
```

**Status Code:** ✅ 200 OK (bukan 401)

### **Test 2: Flutter App Tanpa Login**

```bash
# Jalankan app tanpa login
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

**Steps:**
1. Buka app (belum login)
2. Navigasi ke MapPage
3. Buka tab "Daftar Mall"

**Expected Result:**
- ✅ Loading state muncul
- ✅ Data mall dari database muncul
- ✅ Tidak ada error 401
- ✅ Daftar mall sesuai dengan isi database

### **Test 3: Endpoint Protected Masih Aman**

```bash
# Test endpoint yang harus protected (tanpa token)
curl -X GET http://192.168.1.100:8000/api/user/profile \
  -H "Accept: application/json"
```

**Expected Result:**
```json
{
  "message": "Unauthenticated."
}
```

**Status Code:** ✅ 401 Unauthorized (masih protected)

---

## 🎯 ALTERNATIF SOLUSI (TIDAK DIGUNAKAN)

### **Alternatif 1: Tambah Token ke MallService**

**Implementasi:**
```dart
class MallService {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<List<MallModel>> fetchMalls() async {
    // Ambil token dari storage
    final token = await _storage.read(key: 'auth_token');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/mall'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',  // ✅ Kirim token
      },
    );
    // ...
  }
}
```

**Mengapa TIDAK Dipilih:**
- ❌ User harus login dulu sebelum bisa lihat mall
- ❌ Mengurangi user experience (friction)
- ❌ Tidak sesuai dengan logika bisnis (mall = public info)
- ❌ Lebih kompleks (perlu handle token null, expired, dll)

### **Alternatif 2: Optional Auth (Token Opsional)**

**Implementasi Backend:**
```php
// Middleware custom yang allow both authenticated & guest
Route::prefix('mall')->middleware('optional.auth')->group(function () {
    Route::get('/', [MallController::class, 'index']);
    // ...
});
```

**Mengapa TIDAK Dipilih:**
- ❌ Perlu buat custom middleware
- ❌ Lebih kompleks tanpa benefit jelas
- ❌ Public endpoint sudah cukup untuk use case ini

---

## 📝 CHECKLIST PERBAIKAN

### **Backend Changes**

- ✅ Pindahkan route `/api/mall/*` keluar dari `auth:sanctum` middleware
- ✅ Tambahkan komentar "Public Routes" untuk clarity
- ✅ Pastikan endpoint protected lain tetap di dalam middleware
- ✅ Test endpoint mall bisa diakses tanpa token

### **Flutter Changes**

- ✅ **TIDAK ADA** - MallService tidak perlu diubah
- ✅ Verifikasi MapProvider.loadMalls() berfungsi normal
- ✅ Test UI menampilkan data mall dengan benar

### **Testing**

- ✅ Test endpoint `/api/mall` tanpa token → 200 OK
- ✅ Test endpoint `/api/user/profile` tanpa token → 401 Unauthorized
- ✅ Test Flutter app tanpa login → Daftar mall muncul
- ✅ Test Flutter app dengan login → Semua fitur berfungsi

---

## 🎉 HASIL AKHIR

### **Sebelum:**
```
❌ HTTP 401 Unauthorized
❌ Error state "Koneksi ke Server Gagal"
❌ User tidak bisa lihat mall tanpa login
```

### **Sesudah:**
```
✅ HTTP 200 OK
✅ Daftar mall muncul dari database
✅ User bisa explore mall sebelum login
✅ Endpoint protected lain tetap aman
```

---

## 🔍 TROUBLESHOOTING

### **Masalah: Masih dapat 401 setelah perbaikan**

**Solusi:**
1. Pastikan perubahan route sudah disimpan
2. Clear route cache Laravel:
   ```bash
   cd qparkin_backend
   php artisan route:clear
   php artisan config:clear
   php artisan cache:clear
   ```
3. Restart Laravel server:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```
4. Test dengan curl untuk memastikan endpoint public

### **Masalah: Endpoint protected jadi public**

**Solusi:**
1. Cek route file - pastikan hanya mall yang di luar middleware
2. Test endpoint protected dengan curl (harus 401)
3. Jangan pindahkan route lain keluar dari middleware

### **Masalah: Data mall tidak muncul meskipun 200 OK**

**Solusi:**
1. Cek database ada data mall: `SELECT * FROM mall WHERE status = 'active'`
2. Cek response API: `curl http://192.168.1.100:8000/api/mall | jq`
3. Cek Flutter logs untuk parsing error
4. Verifikasi field mapping di MallModel.fromJson()

---

## 📖 REFERENSI

- **Laravel Route Middleware:** https://laravel.com/docs/middleware
- **Sanctum Authentication:** https://laravel.com/docs/sanctum
- **Public vs Protected API Design:** Best practice untuk REST API

---

**Dokumentasi dibuat:** 2026-01-11
**Status:** ✅ FIXED - Endpoint Mall Sekarang Public
**Impact:** User dapat melihat daftar mall tanpa login
