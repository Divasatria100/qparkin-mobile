# Implementasi Fitur Lokasi Mall - Admin Mall Dashboard

## 📋 Ringkasan

Fitur "Lokasi Mall" telah berhasil ditambahkan ke dashboard Admin Mall. Fitur ini memungkinkan Admin Mall untuk mengatur koordinat lokasi mall menggunakan peta interaktif OpenStreetMap.

## ✅ Komponen yang Ditambahkan

### 1. Database Migration
**File:** `qparkin_backend/database/migrations/2026_01_08_164629_add_location_coordinates_to_mall_table.php`

Menambahkan kolom baru ke tabel `mall`:
- `latitude` (decimal 10,8) - Koordinat lintang
- `longitude` (decimal 11,8) - Koordinat bujur

```sql
ALTER TABLE mall 
ADD COLUMN latitude DECIMAL(10,8) NULL AFTER lokasi,
ADD COLUMN longitude DECIMAL(11,8) NULL AFTER latitude;
```

### 2. Routes
**File:** `qparkin_backend/routes/web.php`

```php
Route::get('/lokasi-mall', [AdminController::class, 'lokasiMall'])->name('lokasi-mall');
Route::post('/lokasi-mall/update', [AdminController::class, 'updateLokasiMall'])->name('lokasi-mall.update');
```

### 3. Controller Methods
**File:** `qparkin_backend/app/Http/Controllers/AdminController.php`

#### `lokasiMall()`
- Menampilkan halaman pengaturan lokasi mall
- Mengambil data mall yang terkait dengan Admin Mall yang login
- Authorization: Hanya Admin Mall yang terkait dengan mall tersebut

#### `updateLokasiMall(Request $request)`
- Menyimpan/memperbarui koordinat mall
- Validasi input:
  - `latitude`: required, numeric, between -90 to 90
  - `longitude`: required, numeric, between -180 to 180
- Authorization: Hanya Admin Mall yang terkait dengan mall tersebut
- Response: JSON dengan status success/error

### 4. View
**File:** `qparkin_backend/resources/views/admin/lokasi-mall.blade.php`

Fitur halaman:
- **Peta Interaktif OpenStreetMap**
  - Klik pada peta untuk menentukan lokasi
  - Marker dapat di-drag untuk menyesuaikan posisi
  - Zoom in/out untuk navigasi peta
  
- **Panel Informasi**
  - Nama mall
  - Alamat mall
  - Input koordinat (latitude/longitude) - readonly, auto-update
  - Status lokasi (sudah diatur/belum)
  
- **Tombol Aksi**
  - "Simpan Lokasi" - Menyimpan koordinat ke database
  - "Gunakan Lokasi Saat Ini" - Menggunakan geolocation browser
  
- **Panduan Penggunaan**
  - Instruksi step-by-step untuk pengguna

### 5. Sidebar Menu
**File:** `qparkin_backend/resources/views/partials/admin/sidebar.blade.php`

Menu baru ditambahkan setelah "Notifikasi":
- Icon: Location pin (map marker)
- Label: "Lokasi Mall"
- Route: `admin.lokasi-mall`

## 🎨 Teknologi yang Digunakan

1. **Leaflet.js v1.9.4** - Library peta interaktif
2. **OpenStreetMap** - Tile provider untuk peta
3. **Geolocation API** - Untuk mendapatkan lokasi saat ini
4. **AJAX/Fetch API** - Untuk menyimpan data tanpa reload halaman

## 🔒 Keamanan & Authorization

1. **Middleware Auth & Role**
   - Route dilindungi dengan middleware `auth` dan `role:admin`
   - Hanya Admin Mall yang dapat mengakses

2. **Data Isolation**
   - Admin Mall hanya dapat mengatur lokasi mall yang terkait dengan akunnya
   - Validasi `id_mall` melalui relasi `admin_mall`

3. **Input Validation**
   - Latitude: -90 hingga 90
   - Longitude: -180 hingga 180
   - CSRF token protection

## 📱 Fitur Responsif

- Layout grid yang adaptif (2 kolom desktop, 1 kolom mobile)
- Peta responsif dengan tinggi tetap
- Tombol dan form yang mobile-friendly

## 🧪 Testing

### Manual Testing Steps:

1. **Login sebagai Admin Mall**
   ```
   Email: admin@qparkin.com
   Password: password
   ```

2. **Akses Menu Lokasi Mall**
   - Klik menu "Lokasi Mall" di sidebar
   - Verifikasi halaman terbuka dengan peta

3. **Set Lokasi dengan Klik Peta**
   - Klik pada peta di lokasi yang diinginkan
   - Verifikasi marker muncul
   - Verifikasi koordinat terisi otomatis

4. **Set Lokasi dengan Geolocation**
   - Klik tombol "Gunakan Lokasi Saat Ini"
   - Izinkan akses lokasi di browser
   - Verifikasi peta berpindah ke lokasi saat ini
   - Verifikasi marker dan koordinat ter-update

5. **Drag Marker**
   - Drag marker ke posisi lain
   - Verifikasi koordinat ter-update saat drag selesai

6. **Simpan Lokasi**
   - Klik tombol "Simpan Lokasi"
   - Verifikasi notifikasi sukses muncul
   - Verifikasi status berubah menjadi "Lokasi sudah diatur"

7. **Reload Halaman**
   - Refresh halaman
   - Verifikasi marker tetap di posisi yang disimpan
   - Verifikasi koordinat tersimpan

### Database Verification:

```sql
SELECT id_mall, nama_mall, latitude, longitude 
FROM mall 
WHERE id_mall = [your_mall_id];
```

## 🔄 Integrasi dengan Fitur Lain

### Model Mall
Kolom `latitude` dan `longitude` sudah ada di `$fillable` array:

```php
protected $fillable = [
    // ... existing fields
    'latitude',
    'longitude',
    // ... other fields
];
```

### API Endpoint (Future)
Koordinat ini dapat digunakan untuk:
- Mobile app: Menampilkan lokasi mall di peta
- Navigasi: Generate Google Maps URL
- Pencarian: Filter mall berdasarkan jarak dari user

```php
// Contoh penggunaan di API
public function getMallLocation($id)
{
    $mall = Mall::findOrFail($id);
    
    return response()->json([
        'id_mall' => $mall->id_mall,
        'nama_mall' => $mall->nama_mall,
        'latitude' => $mall->latitude,
        'longitude' => $mall->longitude,
        'google_maps_url' => Mall::generateGoogleMapsUrl(
            $mall->latitude, 
            $mall->longitude
        )
    ]);
}
```

## 📝 Catatan Implementasi

1. **Default Location**: Jika mall belum memiliki koordinat, peta akan menampilkan Jakarta sebagai default (-6.2088, 106.8456)

2. **Precision**: Koordinat disimpan dengan presisi 8 digit desimal untuk latitude dan 8 digit untuk longitude (akurasi ~1.1mm)

3. **Browser Compatibility**: Fitur geolocation memerlukan HTTPS atau localhost untuk bekerja

4. **OpenStreetMap**: Menggunakan tile server gratis, untuk production sebaiknya pertimbangkan:
   - Self-hosted tile server
   - Commercial tile provider (Mapbox, Maptiler)
   - Rate limiting consideration

## 🚀 Cara Penggunaan

### Untuk Admin Mall:

1. Login ke dashboard Admin Mall
2. Klik menu "Lokasi Mall" di sidebar
3. Pilih salah satu cara untuk menentukan lokasi:
   - **Opsi 1**: Klik langsung pada peta
   - **Opsi 2**: Klik "Gunakan Lokasi Saat Ini"
   - **Opsi 3**: Drag marker yang sudah ada
4. Koordinat akan otomatis terisi
5. Klik "Simpan Lokasi" untuk menyimpan
6. Selesai! Lokasi mall sudah tersimpan

## 🔧 Troubleshooting

### Peta tidak muncul
- Pastikan koneksi internet aktif
- Cek console browser untuk error
- Verifikasi Leaflet.js dan CSS ter-load

### Geolocation tidak bekerja
- Pastikan menggunakan HTTPS atau localhost
- Izinkan akses lokasi di browser
- Cek permission browser settings

### Koordinat tidak tersimpan
- Cek console untuk error AJAX
- Verifikasi CSRF token
- Cek authorization (apakah user adalah Admin Mall yang benar)

## 📊 Status Implementasi

✅ Database migration - DONE
✅ Model update - DONE (sudah ada di Mall model)
✅ Routes - DONE
✅ Controller methods - DONE
✅ View dengan OpenStreetMap - DONE
✅ Sidebar menu - DONE
✅ Authorization & validation - DONE
✅ Responsive design - DONE
✅ Geolocation support - DONE

## 🎯 Next Steps (Optional Enhancements)

1. **Search Location**: Tambahkan search box untuk mencari alamat
2. **Multiple Markers**: Support untuk multiple entrance/exit points
3. **Radius Circle**: Tampilkan radius coverage area
4. **Nearby Places**: Tampilkan landmark terdekat
5. **API Endpoint**: Expose koordinat via REST API untuk mobile app
6. **History Log**: Track perubahan lokasi dengan timestamp

## 📞 Support

Jika ada pertanyaan atau issue, silakan hubungi tim development.

---

**Implementasi Selesai**: 8 Januari 2026
**Developer**: Kiro AI Assistant
**Status**: ✅ Production Ready
