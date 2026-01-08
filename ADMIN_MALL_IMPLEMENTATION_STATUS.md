# Status Implementasi: Registrasi Admin Mall → Mobile App

**Tanggal:** 8 Januari 2026  
**Status:** Ready for Implementation

---

## 📋 Ringkasan

Dokumentasi lengkap telah dibuat untuk implementasi end-to-end alur registrasi admin mall hingga mall muncul di aplikasi mobile dengan pendekatan minimal PBL.

### Dokumen yang Tersedia:
1. ✅ **ADMIN_MALL_END_TO_END_IMPLEMENTATION_GUIDE.md** - Panduan implementasi lengkap (1504 baris)
2. ✅ **ADMIN_MALL_MOBILE_INTEGRATION_MINIMAL_PBL.md** - Pendekatan minimal untuk PBL (1206 baris)
3. ✅ **ADMIN_MALL_REGISTRATION_AUDIT_REPORT.md** - Laporan audit masalah
4. ✅ **ADMIN_MALL_MOBILE_INTEGRATION_AUDIT.md** - Audit integrasi mobile

---

## 🎯 Pendekatan Implementasi

### Minimal PBL Approach:
- ✅ Peta internal untuk display marker mall (latitude, longitude)
- ✅ Navigasi rute delegasi ke Google Maps eksternal (google_maps_url)
- ❌ TIDAK ada routing/polyline calculation internal (future enhancement)

### Alur Data:
```
Registrasi Form → Backend (pending) → Super Admin Approve → 
Mall Created (active) → API Endpoint → Mobile App → Google Maps Navigation
```

---

## 📊 Status Implementasi

### Backend (0/10 files implemented)

#### Database & Models
- [ ] **Migration User** - Tambah `requested_mall_latitude`, `requested_mall_longitude`
  - File: `qparkin_backend/database/migrations/*_add_application_fields_to_user_table.php`
  - Status: ⚠️ Perlu edit (field latitude/longitude belum ada)

- [ ] **Migration Mall** - Tambah `latitude`, `longitude`, `google_maps_url`, `status`
  - File: `qparkin_backend/database/migrations/2026_01_XX_add_coordinates_to_mall_table.php`
  - Status: ❌ Belum dibuat

- [ ] **Model User** - Update $fillable
  - File: `qparkin_backend/app/Models/User.php`
  - Status: ⚠️ Perlu update

- [ ] **Model Mall** - Tambah field & helper methods
  - File: `qparkin_backend/app/Models/Mall.php`
  - Status: ⚠️ Perlu update

#### Controllers & Routes
- [ ] **Route Fix** - Ganti RegisteredUserController → AdminMallRegistrationController
  - File: `qparkin_backend/routes/web.php`
  - Status: ❌ Masih salah

- [ ] **AdminMallRegistrationController** - Implementasi store()
  - File: `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`
  - Status: ⚠️ Ada tapi field names salah (mall_name vs requested_mall_name)

- [ ] **SuperAdminController::pengajuan()** - Fix query
  - File: `qparkin_backend/app/Http/Controllers/SuperAdminController.php`
  - Status: ❌ Query salah (where status='pending' vs application_status='pending')

- [ ] **SuperAdminController::approvePengajuan()** - Implementasi lengkap
  - File: `qparkin_backend/app/Http/Controllers/SuperAdminController.php`
  - Status: ❌ Tidak create mall, tidak link admin_mall

- [ ] **MallController (API)** - Implementasi index(), show()
  - File: `qparkin_backend/app/Http/Controllers/Api/MallController.php`
  - Status: ❌ Return empty array

#### Views & JavaScript
- [ ] **pengajuan.blade.php** - Fix field names
  - File: `qparkin_backend/resources/views/superadmin/pengajuan.blade.php`
  - Status: ⚠️ Field names salah

- [ ] **super-pengajuan-akun.js** - Implementasi AJAX real
  - File: `qparkin_backend/public/js/super-pengajuan-akun.js`
  - Status: ⚠️ AJAX belum aktif

### Mobile App (0/5 files implemented)

#### Services & Models
- [ ] **MallService** - Buat service baru
  - File: `qparkin_app/lib/data/services/mall_service.dart`
  - Status: ❌ Belum ada

- [ ] **MallModel** - Tambah googleMapsUrl
  - File: `qparkin_app/lib/data/models/mall_model.dart`
  - Status: ❌ Field belum ada

#### Providers
- [ ] **MapProvider** - Update untuk konsumsi API
  - File: `qparkin_app/lib/logic/providers/map_provider.dart`
  - Status: ⚠️ Masih pakai dummy data (line ~200)

#### UI
- [ ] **map_page.dart** - Update untuk Google Maps navigation
  - File: `qparkin_app/lib/presentation/screens/map_page.dart`
  - Status: ⚠️ Tombol "Rute" masih trigger route calculation internal

- [ ] **pubspec.yaml** - Tambah url_launcher
  - File: `qparkin_app/pubspec.yaml`
  - Status: ❌ Dependency belum ada

---

## 🚀 Langkah Implementasi (Urutan Prioritas)

### FASE 1: Backend Database (35 menit)
1. Edit migration user - tambah latitude & longitude
2. Buat migration mall - tambah koordinat & google_maps_url
3. Run migrations
4. Update Model User & Mall

### FASE 2: Backend Controllers (35 menit)
5. Fix route registration
6. Update AdminMallRegistrationController
7. Update SuperAdminController (pengajuan & approve)
8. Implementasi MallController API

### FASE 3: Backend Views (20 menit)
9. Fix pengajuan.blade.php field names
10. Implementasi AJAX di super-pengajuan-akun.js

### FASE 4: Mobile App Services (25 menit)
11. Buat MallService
12. Update MallModel dengan googleMapsUrl

### FASE 5: Mobile App Integration (35 menit)
13. Update MapProvider untuk konsumsi API
14. Update map_page.dart untuk Google Maps navigation
15. Tambah url_launcher dependency

### FASE 6: Testing (30 menit)
16. Test backend: registrasi → approve → API
17. Test mobile: load malls → display → navigate
18. Test end-to-end flow

**Total Estimasi: 3 jam**

---

## 📝 Masalah yang Ditemukan (dari Audit)

### Backend Issues:
1. ❌ Route menggunakan RegisteredUserController yang salah
2. ❌ Field database tidak sesuai (missing latitude, longitude, photo)
3. ❌ AdminMallRegistrationController field names tidak konsisten
4. ❌ JavaScript AJAX tidak aktif
5. ❌ Query pengajuan menggunakan field yang salah
6. ❌ Approve flow tidak lengkap (tidak create mall & admin_mall)
7. ❌ API MallController return empty array

### Mobile App Issues:
8. ❌ MapProvider menggunakan dummy data
9. ❌ MallModel tidak punya field google_maps_url
10. ❌ map_page.dart tidak punya tombol "Lihat Rute"
11. ❌ Dependency url_launcher belum ada

---

## 🔧 File yang Perlu Dimodifikasi

### Backend (10 files):
```
qparkin_backend/
├── database/migrations/
│   ├── *_add_application_fields_to_user_table.php (EDIT)
│   └── 2026_01_XX_add_coordinates_to_mall_table.php (NEW)
├── app/Models/
│   ├── User.php (EDIT)
│   └── Mall.php (EDIT)
├── routes/
│   └── web.php (EDIT)
├── app/Http/Controllers/
│   ├── Auth/AdminMallRegistrationController.php (EDIT)
│   ├── SuperAdminController.php (EDIT)
│   └── Api/MallController.php (EDIT)
├── resources/views/superadmin/
│   └── pengajuan.blade.php (EDIT)
└── public/js/
    └── super-pengajuan-akun.js (EDIT)
```

### Mobile App (5 files):
```
qparkin_app/
├── lib/data/
│   ├── services/
│   │   └── mall_service.dart (NEW)
│   └── models/
│       └── mall_model.dart (EDIT)
├── lib/logic/providers/
│   └── map_provider.dart (EDIT)
├── lib/presentation/screens/
│   └── map_page.dart (EDIT)
└── pubspec.yaml (EDIT)
```

---

## 📚 Referensi Dokumen

### Panduan Implementasi:
- **ADMIN_MALL_END_TO_END_IMPLEMENTATION_GUIDE.md** - Panduan lengkap step-by-step
  - Section 3: Implementasi Step-by-Step (12 steps)
  - Section 4: Checklist Implementasi
  - Section 5: Troubleshooting
  - Section 6: Testing Commands

### Pendekatan Minimal:
- **ADMIN_MALL_MOBILE_INTEGRATION_MINIMAL_PBL.md** - Fokus PBL
  - Section 3: Solusi Implementasi Minimal
  - Section 6: Checklist (Backend 60 menit, Mobile 60 menit)

### Audit Reports:
- **ADMIN_MALL_REGISTRATION_AUDIT_REPORT.md** - 12 masalah kritis
- **ADMIN_MALL_MOBILE_INTEGRATION_AUDIT.md** - Analisis integrasi lengkap

---

## ✅ Next Steps

### Untuk Memulai Implementasi:

1. **Baca panduan lengkap:**
   ```bash
   # Buka file ini untuk step-by-step guide
   ADMIN_MALL_END_TO_END_IMPLEMENTATION_GUIDE.md
   ```

2. **Mulai dari Backend Database:**
   ```bash
   cd qparkin_backend
   # Edit migration user
   # Buat migration mall
   php artisan migrate
   ```

3. **Ikuti checklist di Section 4** dari implementation guide

4. **Test setiap step** sebelum lanjut ke step berikutnya

5. **Verifikasi end-to-end** setelah semua selesai

---

## 🎯 Success Criteria

### Backend:
- ✅ Form registrasi submit dengan koordinat
- ✅ Data tersimpan dengan application_status='pending'
- ✅ Halaman pengajuan menampilkan data dengan benar
- ✅ Approve membuat mall dengan status='active'
- ✅ API /api/mall return active malls dengan koordinat
- ✅ google_maps_url ter-generate otomatis

### Mobile App:
- ✅ Malls load dari API (bukan dummy data)
- ✅ Markers muncul di peta dengan koordinat yang benar
- ✅ Tombol "Lihat Rute" membuka Google Maps
- ✅ Navigasi ke mall berfungsi dengan benar

### End-to-End:
- ✅ Registrasi → Approve → API → Mobile → Navigation
- ✅ Tidak ada error di console
- ✅ Data konsisten di semua layer

---

**Status:** Ready for Implementation  
**Estimasi:** 3 jam  
**Prioritas:** High (untuk PBL)

Semua dokumentasi sudah lengkap. Tinggal eksekusi implementasi mengikuti panduan yang sudah dibuat.
