# Integrasi Vehicle Selector di Booking Page

## Ringkasan Perubahan

Fitur pemilihan kendaraan di halaman booking (`booking_page.dart`) telah disesuaikan untuk menampilkan daftar kendaraan yang telah ditambahkan melalui halaman tambah kendaraan (`tambah_kendaraan.dart`).

## Perubahan yang Dilakukan

### 1. Inisialisasi Authentication Data
- Menambahkan `FlutterSecureStorage` untuk mengakses token autentikasi
- Mengambil `auth_token` dari secure storage saat halaman dimuat
- Menggunakan `API_URL` dari environment variable (sama seperti di `main.dart`)

### 2. Inisialisasi VehicleService
- `VehicleService` sekarang diinisialisasi dengan:
  - `baseUrl`: Dari environment variable `API_URL`
  - `authToken`: Dari secure storage
- Inisialisasi dilakukan secara asynchronous di `initState()`

### 3. Penanganan Error
- Menambahkan fallback jika secure storage gagal
- Menambahkan debug print untuk troubleshooting
- Memastikan widget tetap berfungsi meskipun token tidak tersedia

### 4. Conditional Rendering
- Widget `VehicleSelector` hanya ditampilkan setelah `_baseUrl` terinisialisasi
- Mencegah error saat `_vehicleService` belum siap

## Cara Kerja

1. **Saat halaman booking dibuka:**
   - System membaca `auth_token` dari secure storage
   - System mengambil `baseUrl` dari environment variable
   - `VehicleService` diinisialisasi dengan credentials yang benar

2. **Saat widget VehicleSelector dimuat:**
   - Widget memanggil `VehicleService.fetchVehicles()`
   - API request dikirim ke backend dengan token autentikasi
   - Daftar kendaraan ditampilkan dalam dropdown

3. **Saat user memilih kendaraan:**
   - Data kendaraan disimpan ke `BookingProvider`
   - Validasi error dibersihkan
   - Availability check dimulai jika semua data sudah lengkap

## File yang Dimodifikasi

- `qparkin_app/lib/presentation/screens/booking_page.dart`
  - Menambahkan import `flutter_secure_storage`
  - Mengubah inisialisasi `VehicleService`
  - Menambahkan method `_initializeAuthData()`
  - Menambahkan conditional rendering untuk `VehicleSelector`

## File yang Tidak Diubah

- `qparkin_app/lib/presentation/widgets/vehicle_selector.dart` - Sudah bekerja dengan baik
- `qparkin_app/lib/data/services/vehicle_service.dart` - Sudah bekerja dengan baik
- `qparkin_app/lib/data/models/vehicle_model.dart` - Sudah bekerja dengan baik
- `qparkin_app/lib/presentation/screens/tambah_kendaraan.dart` - Sudah bekerja dengan baik

## Testing

Untuk menguji fitur ini:

1. **Tambah kendaraan:**
   ```
   - Buka halaman Profile
   - Pilih "Kendaraan Saya"
   - Klik "Tambah Kendaraan"
   - Isi form dan simpan
   ```

2. **Booking dengan kendaraan:**
   ```
   - Buka halaman Home
   - Pilih mall
   - Klik "Booking"
   - Pilih kendaraan dari dropdown
   - Kendaraan yang baru ditambahkan akan muncul di daftar
   ```

## Catatan Penting

- Token autentikasi harus tersedia di secure storage
- Jika token tidak ada, widget akan tetap ditampilkan tapi API call akan gagal
- Error handling sudah ditambahkan di `VehicleSelector` untuk menampilkan pesan error yang user-friendly
- Base URL menggunakan environment variable yang sama dengan konfigurasi di `main.dart`

## Troubleshooting

### Error "Gagal Memuat Kendaraan"

Jika muncul error ini, kemungkinan penyebabnya:

1. **Token autentikasi tidak tersedia** (paling umum)
   - Pastikan user sudah login
   - Cek log: `[BookingPage] Auth token available: false`
   - Solusi: Login ulang

2. **Base URL salah atau backend tidak berjalan**
   - Cek log: `[BookingPage] Initializing with baseUrl: http://localhost:8000`
   - Solusi: Jalankan dengan `flutter run --dart-define=API_URL=http://192.168.x.xx:8000`

3. **Backend API endpoint tidak tersedia**
   - Test endpoint: `curl -H "Authorization: Bearer TOKEN" http://IP:8000/api/vehicles`
   - Pastikan backend berjalan

**Catatan:** Data mall yang dummy **TIDAK** menyebabkan error ini karena vehicle selector tidak bergantung pada data mall.

Untuk troubleshooting lengkap, lihat: `docs/vehicle_selector_troubleshooting.md`

## Environment Variable

Pastikan aplikasi dijalankan dengan environment variable yang benar:

```bash
flutter run --dart-define=API_URL=http://192.168.x.xx:8000
```

Ganti `192.168.x.xx` dengan IP address backend server Anda.
