# Troubleshooting: Error "Gagal Memuat Kendaraan" di Booking Page

## Deskripsi Masalah

Setelah integrasi vehicle selector di booking page, muncul error "Gagal Memuat Kendaraan" saat membuka halaman booking.

## Kemungkinan Penyebab

### 1. **Token Autentikasi Tidak Tersedia** ⚠️ PALING UMUM

**Penyebab:**
- User belum login
- Token sudah expired
- Token tidak tersimpan di secure storage

**Cara Cek:**
```bash
# Lihat log di console saat membuka booking page
# Cari baris:
[BookingPage] Auth token available: false
```

**Solusi:**
- Pastikan user sudah login terlebih dahulu
- Login ulang jika token expired
- Cek implementasi login untuk memastikan token tersimpan dengan benar

### 2. **Base URL Salah atau Backend Tidak Berjalan**

**Penyebab:**
- Environment variable `API_URL` tidak diset
- Backend server tidak berjalan
- IP address salah

**Cara Cek:**
```bash
# Lihat log di console:
[BookingPage] Initializing with baseUrl: http://localhost:8000

# Jika muncul localhost:8000, berarti environment variable tidak diset
```

**Solusi:**
```bash
# Jalankan aplikasi dengan environment variable yang benar:
flutter run --dart-define=API_URL=http://192.168.x.xx:8000

# Ganti 192.168.x.xx dengan IP address backend server Anda
```

### 3. **Backend API Endpoint Tidak Tersedia**

**Penyebab:**
- Endpoint `/api/vehicles` tidak ada di backend
- Backend mengembalikan error 404 atau 500

**Cara Cek:**
```bash
# Test endpoint langsung dengan curl:
curl -H "Authorization: Bearer YOUR_TOKEN" http://192.168.x.xx:8000/api/vehicles

# Atau gunakan Postman/Insomnia
```

**Solusi:**
- Pastikan backend sudah berjalan
- Cek routing di backend untuk endpoint `/api/vehicles`
- Pastikan endpoint memerlukan autentikasi

### 4. **Data Mall Dummy (BUKAN PENYEBAB UTAMA)**

**Catatan:** Data mall yang dummy **TIDAK** menyebabkan error ini karena:
- Vehicle selector tidak bergantung pada data mall
- API call untuk vehicles terpisah dari data mall
- Error terjadi saat fetch vehicles, bukan saat load mall data

## Langkah Debugging

### 1. Cek Log Console

Buka console dan cari log berikut:

```
[BookingPage] Initializing with baseUrl: ...
[BookingPage] Auth token available: ...
[BookingPage] Error initializing auth data: ...
```

### 2. Cek VehicleSelector Widget

Lihat log dari VehicleSelector:

```
[VehicleSelector] Fetching vehicles...
[VehicleSelector] Error: ...
```

### 3. Test API Endpoint Langsung

```bash
# Test dengan curl
curl -X GET \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  http://192.168.x.xx:8000/api/vehicles

# Response yang diharapkan:
{
  "data": [
    {
      "id_kendaraan": "1",
      "plat": "B1234XYZ",
      "jenis": "Roda Empat",
      "merk": "Toyota",
      "tipe": "Avanza",
      ...
    }
  ]
}
```

### 4. Cek Secure Storage

```dart
// Tambahkan debug code di booking_page.dart:
final token = await _storage.read(key: 'auth_token');
debugPrint('Token from storage: $token');
```

## Solusi Cepat

### Solusi 1: Pastikan User Sudah Login

```dart
// Di booking_page.dart, tambahkan pengecekan:
if (_authToken == null) {
  // Redirect ke login page
  Navigator.pushReplacementNamed(context, '/login');
  return;
}
```

### Solusi 2: Set Environment Variable dengan Benar

```bash
# Stop aplikasi
# Jalankan ulang dengan environment variable:
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# Ganti dengan IP address backend Anda
```

### Solusi 3: Cek Backend Server

```bash
# Di terminal backend:
cd qparkin_backend
php artisan serve

# Pastikan server berjalan di port 8000
```

### Solusi 4: Test dengan Data Dummy (Temporary)

Jika ingin test UI tanpa backend, modifikasi `VehicleService`:

```dart
// Di vehicle_service.dart, tambahkan mode dummy:
Future<List<VehicleModel>> fetchVehicles() async {
  // TEMPORARY: Return dummy data for testing
  if (authToken == null) {
    return [
      VehicleModel(
        idKendaraan: '1',
        platNomor: 'B1234XYZ',
        jenisKendaraan: 'Roda Empat',
        merk: 'Toyota',
        tipe: 'Avanza',
      ),
    ];
  }
  
  // Normal API call
  try {
    final response = await http.get(...);
    ...
  }
}
```

## Checklist Verifikasi

Sebelum melaporkan bug, pastikan:

- [ ] User sudah login
- [ ] Token tersimpan di secure storage
- [ ] Backend server berjalan
- [ ] Environment variable `API_URL` sudah diset dengan benar
- [ ] Endpoint `/api/vehicles` bisa diakses
- [ ] IP address backend benar (bukan localhost jika test di device)
- [ ] Network permission sudah diset di AndroidManifest.xml

## Informasi Tambahan

### Network Permission (Android)

Pastikan `AndroidManifest.xml` memiliki permission:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS Configuration

Pastikan `Info.plist` memiliki:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Kontak Support

Jika masalah masih berlanjut setelah mengikuti langkah di atas:

1. Capture screenshot error
2. Copy log dari console
3. Catat langkah-langkah yang dilakukan
4. Laporkan ke tim development

## Update Terakhir

- **Tanggal:** 2025-01-02
- **Versi:** 1.0.0
- **Status:** Active troubleshooting guide
