# Quick Start - Fitur Lokasi Mall

## 🚀 Akses Cepat

### URL
```
http://localhost:8000/admin/lokasi-mall
```

### Login Credentials
```
Email: admin@qparkin.com
Password: password
```

## ⚡ Quick Test

### 1. Akses Halaman
```bash
# Start Laravel server
cd qparkin_backend
php artisan serve
```

Buka browser: `http://localhost:8000/admin/lokasi-mall`

### 2. Set Lokasi (3 Cara)

**Cara 1: Klik Peta**
- Klik pada peta di lokasi yang diinginkan
- Marker akan muncul
- Koordinat otomatis terisi

**Cara 2: Geolocation**
- Klik tombol "Gunakan Lokasi Saat Ini"
- Izinkan akses lokasi
- Peta akan berpindah ke lokasi Anda

**Cara 3: Drag Marker**
- Drag marker yang sudah ada
- Koordinat akan update otomatis

### 3. Simpan
- Klik tombol "Simpan Lokasi"
- Tunggu notifikasi sukses

## 🔍 Verifikasi Database

```sql
-- Cek struktur tabel
DESCRIBE mall;

-- Cek data lokasi
SELECT id_mall, nama_mall, latitude, longitude 
FROM mall 
WHERE latitude IS NOT NULL;

-- Update manual (jika perlu)
UPDATE mall 
SET latitude = -6.2088, longitude = 106.8456 
WHERE id_mall = 1;
```

## 📋 Checklist Testing

- [ ] Menu "Lokasi Mall" muncul di sidebar
- [ ] Halaman terbuka tanpa error
- [ ] Peta OpenStreetMap ter-load
- [ ] Klik peta menambahkan marker
- [ ] Koordinat terisi otomatis
- [ ] Geolocation bekerja (jika di HTTPS/localhost)
- [ ] Drag marker mengupdate koordinat
- [ ] Tombol "Simpan Lokasi" bekerja
- [ ] Notifikasi sukses muncul
- [ ] Data tersimpan di database
- [ ] Reload halaman menampilkan marker di posisi yang benar

## 🐛 Common Issues

### Peta tidak muncul
```
Solusi: Cek koneksi internet, Leaflet.js harus ter-load
```

### Geolocation tidak bekerja
```
Solusi: Gunakan HTTPS atau localhost, izinkan akses lokasi di browser
```

### Error 403 Unauthorized
```
Solusi: Login sebagai Admin Mall, bukan Super Admin atau Customer
```

### Koordinat tidak tersimpan
```
Solusi: Cek console browser untuk error, verifikasi CSRF token
```

## 📱 Mobile Testing

1. Akses dari mobile browser
2. Layout harus responsif (1 kolom)
3. Peta harus bisa di-zoom dengan pinch
4. Tombol harus mudah diklik

## 🎯 Expected Result

Setelah implementasi berhasil:
- ✅ Menu baru "Lokasi Mall" muncul di sidebar
- ✅ Halaman dengan peta interaktif terbuka
- ✅ Admin Mall dapat set koordinat dengan mudah
- ✅ Data tersimpan ke database
- ✅ Koordinat dapat digunakan untuk integrasi lain (API, mobile app)

## 📞 Need Help?

Jika ada masalah, cek:
1. Laravel log: `qparkin_backend/storage/logs/laravel.log`
2. Browser console (F12)
3. Network tab untuk AJAX errors
4. Database connection

---

**Ready to use!** 🎉
