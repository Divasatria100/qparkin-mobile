# Quick Reference - Peta Lokasi Mall Fix

## ✅ Apa yang Sudah Diperbaiki?

Peta OpenStreetMap di halaman Lokasi Mall sekarang sudah berfungsi dengan baik.

## 🚀 Cara Test

### 1. Start Server
```bash
cd qparkin_backend
php artisan serve
```

### 2. Buka Browser
```
URL: http://localhost:8000/admin/lokasi-mall
```

### 3. Login
```
Email: admin@qparkin.com
Password: password
```

### 4. Verifikasi Peta Tampil
- ✅ Peta OpenStreetMap muncul
- ✅ Bisa zoom in/out
- ✅ Bisa klik untuk set marker
- ✅ Koordinat update otomatis

## 🔍 Jika Peta Masih Tidak Tampil

### Quick Fix 1: Hard Refresh
```
Ctrl + Shift + R
```

### Quick Fix 2: Clear Cache
```bash
php artisan cache:clear
php artisan view:clear
```

### Quick Fix 3: Check Console
```
1. Tekan F12
2. Buka tab Console
3. Cari error (warna merah)
4. Screenshot dan report
```

## 📋 Checklist

Pastikan semua ini ✅:

- [ ] File `public/css/lokasi-mall.css` ada
- [ ] Koneksi internet aktif (untuk load tiles)
- [ ] Browser console tidak ada error
- [ ] Login sebagai Admin Mall (bukan Super Admin)
- [ ] Element #map memiliki height 500px

## 🐛 Common Issues

### Issue 1: Peta Abu-abu/Blank
**Solusi:** Cek koneksi internet, tiles butuh download dari OpenStreetMap

### Issue 2: Console Error "L is not defined"
**Solusi:** Leaflet.js tidak ter-load, hard refresh (Ctrl+Shift+R)

### Issue 3: Peta Tidak Bisa Diklik
**Solusi:** Tunggu sampai tiles selesai load (lihat loading indicator)

### Issue 4: Koordinat Tidak Update
**Solusi:** Cek console untuk error JavaScript

## 📞 Debug Commands

### Check Leaflet Loaded
```javascript
// Di browser console (F12):
console.log(typeof L);
// Should return: "object"
```

### Check Map Container
```javascript
// Di browser console:
console.log(document.getElementById('map').offsetHeight);
// Should return: 500
```

### Manual Test
```javascript
// Di browser console:
var testMap = L.map('map').setView([-6.2088, 106.8456], 13);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(testMap);
```

## 🎯 Expected Behavior

### Saat Halaman Load:
1. Loading indicator muncul ("Memuat peta...")
2. Peta mulai dimuat
3. Tiles OpenStreetMap muncul
4. Loading indicator hilang
5. Peta siap digunakan

### Saat Klik Peta:
1. Marker muncul di posisi klik
2. Input latitude & longitude ter-update
3. Marker bisa di-drag

### Saat Simpan:
1. Tombol berubah jadi "Menyimpan..."
2. AJAX request ke server
3. Alert "Lokasi mall berhasil diperbarui!"
4. Status berubah jadi "Lokasi sudah diatur"

## 📁 File Locations

```
qparkin_backend/
├── public/
│   └── css/
│       └── lokasi-mall.css          ← CSS untuk peta
├── resources/
│   └── views/
│       └── admin/
│           └── lokasi-mall.blade.php ← View halaman
└── app/
    └── Http/
        └── Controllers/
            └── AdminController.php   ← Controller methods
```

## 🔧 Manual Fix (Last Resort)

Jika semua cara di atas gagal:

1. **Download Leaflet Locally:**
```bash
# Download dari https://leafletjs.com/download.html
# Extract ke public/vendor/leaflet/
```

2. **Update View:**
```html
<!-- Change CDN to local -->
<link rel="stylesheet" href="{{ asset('vendor/leaflet/leaflet.css') }}">
<script src="{{ asset('vendor/leaflet/leaflet.js') }}"></script>
```

3. **Alternative: Use Google Maps**
See `LOKASI_MALL_TROUBLESHOOTING.md` for Google Maps implementation

## ✨ Success Indicators

Peta berhasil jika:
- ✅ Tiles OpenStreetMap tampil
- ✅ Bisa zoom dengan scroll mouse
- ✅ Bisa pan dengan drag
- ✅ Klik menambahkan marker
- ✅ Koordinat update real-time
- ✅ Simpan bekerja tanpa error
- ✅ Console tidak ada error merah

## 📞 Need Help?

1. Check `LOKASI_MALL_TROUBLESHOOTING.md` untuk detail
2. Check Laravel logs: `storage/logs/laravel.log`
3. Check browser console untuk JavaScript errors
4. Screenshot error dan report

---

**Status:** ✅ Fixed & Ready to Use
**Last Updated:** 8 Januari 2026
