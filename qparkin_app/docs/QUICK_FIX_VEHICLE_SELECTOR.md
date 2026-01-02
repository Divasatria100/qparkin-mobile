# Quick Fix: "Gagal Memuat Kendaraan"

## 🚀 Solusi Cepat (5 Menit)

### Solusi 1: Login Dulu ⭐ PALING UMUM
```
1. Buka aplikasi
2. Login dengan akun yang valid
3. Buka booking page lagi
```

### Solusi 2: Jalankan Backend
```bash
cd qparkin_backend
php artisan serve
```

### Solusi 3: Set IP Address yang Benar
```bash
# Stop aplikasi
# Jalankan dengan IP yang benar:
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# Ganti 192.168.1.100 dengan IP komputer backend Anda
```

## 🔍 Cara Cek Masalahnya Apa

### Cek 1: Lihat Console Log
Cari baris ini di console:
```
[BookingPage] Auth token available: false  ← MASALAH: User belum login
[BookingPage] Auth token available: true   ← OK: User sudah login
```

### Cek 2: Lihat Base URL
```
[BookingPage] Initializing with baseUrl: http://localhost:8000  ← MASALAH: Pakai localhost
[BookingPage] Initializing with baseUrl: http://192.168.1.100:8000  ← OK: Pakai IP
```

### Cek 3: Test Backend
```bash
# Ganti YOUR_TOKEN dan IP_ADDRESS:
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://IP_ADDRESS:8000/api/vehicles

# Jika berhasil, akan muncul data kendaraan
# Jika error, backend tidak berjalan atau endpoint salah
```

## 📋 Checklist Cepat

Sebelum test, pastikan:
- [ ] Backend berjalan (`php artisan serve`)
- [ ] User sudah login
- [ ] Pakai IP address, bukan localhost
- [ ] Ada data kendaraan di database

## 💡 Tips

**Jika test di emulator:**
- Gunakan IP address komputer (192.168.x.xx)
- JANGAN gunakan localhost atau 127.0.0.1

**Jika test di device fisik:**
- Pastikan device dan komputer di network yang sama
- Gunakan IP address komputer di network tersebut

**Cara cek IP komputer:**
```bash
# Windows:
ipconfig

# Mac/Linux:
ifconfig
```

## 🎯 Hasil yang Diharapkan

Setelah fix, vehicle selector akan:
1. ✅ Menampilkan loading indicator
2. ✅ Menampilkan daftar kendaraan yang sudah ditambahkan
3. ✅ Bisa dipilih dan terintegrasi dengan booking

## 📚 Dokumentasi Lengkap

- `vehicle_selector_status.md` - Status dan penjelasan lengkap
- `vehicle_selector_troubleshooting.md` - Troubleshooting detail
- `vehicle_selector_booking_integration.md` - Dokumentasi teknis

---

**Update:** 2025-01-02  
**Status:** Kode sudah benar, tinggal fix environment
