# Prompt: Audit Backend & Frontend - Registrasi Admin Mall & Pengajuan Akun

## Konteks
Saya memiliki sistem QParkin dengan dua halaman yang saling terkait:
1. **Halaman Registrasi Admin Mall** - Form untuk calon admin mall mendaftar
2. **Halaman Pengajuan Akun (Dashboard Super Admin)** - Menampilkan daftar pengajuan yang masuk

Saya perlu memastikan backend dan alur data antara kedua halaman ini sudah berfungsi dengan baik dan sinkron.

## Tugas yang Harus Dilakukan

### 1. AUDIT HALAMAN REGISTRASI ADMIN MALL

#### A. Periksa File Frontend
- **Lokasi:** `qparkin_backend/resources/views/auth/signup.blade.php` atau file view terkait
- **Yang perlu diperiksa:**
  - Apakah form memiliki semua field yang diperlukan (nama, email, password, nama mall, alamat mall, dll)?
  - Apakah ada validasi client-side (JavaScript)?
  - Ke endpoint mana form ini mengirim data (method POST/GET, URL action)?
  - Apakah ada CSRF token untuk keamanan?
  - Apakah ada feedback UI untuk success/error?

#### B. Periksa JavaScript Handler
- **Lokasi:** `qparkin_backend/public/js/signup-ajax.js` atau file JS terkait
- **Yang perlu diperiksa:**
  - Apakah AJAX request sudah benar (URL, method, headers, data format)?
  - Apakah ada error handling yang memadai?
  - Apakah response dari backend ditangani dengan baik?
  - Apakah ada redirect setelah sukses?

#### C. Periksa Backend Controller
- **Lokasi:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`
- **Yang perlu diperiksa:**
  - Apakah controller method untuk menerima registrasi sudah ada?
  - Apakah ada validasi server-side untuk semua input?
  - Apakah data disimpan ke database dengan benar?
  - Apakah status pengajuan di-set dengan benar (misalnya: 'pending')?
  - Apakah ada response JSON yang sesuai untuk AJAX?
  - Apakah ada error handling dan logging?

#### D. Periksa Route
- **Lokasi:** `qparkin_backend/routes/web.php`
- **Yang perlu diperiksa:**
  - Apakah route untuk registrasi admin mall sudah terdaftar?
  - Apakah route mengarah ke controller yang benar?
  - Apakah ada middleware yang diperlukan (guest, throttle, dll)?

#### E. Periksa Database Migration & Model
- **Lokasi:** 
  - `qparkin_backend/database/migrations/*_create_admin_mall_registrations_table.php` (atau nama serupa)
  - `qparkin_backend/app/Models/AdminMallRegistration.php` (atau nama serupa)
- **Yang perlu diperiksa:**
  - Apakah tabel untuk menyimpan pengajuan sudah ada?
  - Apakah struktur tabel mencakup semua field yang diperlukan?
  - Apakah ada field `status` untuk tracking (pending/approved/rejected)?
  - Apakah ada timestamps (created_at, updated_at)?
  - Apakah Model sudah di-setup dengan benar (fillable, casts, relationships)?

---

### 2. AUDIT HALAMAN PENGAJUAN AKUN (DASHBOARD SUPER ADMIN)

#### A. Periksa File View
- **Lokasi:** `qparkin_backend/resources/views/superadmin/pengajuan-akun.blade.php` atau file view terkait
- **Yang perlu diperiksa:**
  - Apakah view menampilkan data pengajuan dalam tabel/list?
  - Apakah ada tombol aksi (Approve/Reject)?
  - Apakah ada pagination jika data banyak?
  - Apakah ada filter berdasarkan status (pending/approved/rejected)?
  - Apakah tampilan responsive dan user-friendly?

#### B. Periksa Backend Controller
- **Lokasi:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php` atau controller terkait
- **Yang perlu diperiksa:**
  - Apakah ada method untuk menampilkan daftar pengajuan?
  - Apakah data diambil dari database dengan benar?
  - Apakah ada method untuk approve/reject pengajuan?
  - Apakah saat approve, akun admin mall benar-benar dibuat di tabel `users`?
  - Apakah ada notifikasi email ke pendaftar setelah approve/reject?
  - Apakah ada logging untuk audit trail?

#### C. Periksa Route
- **Lokasi:** `qparkin_backend/routes/web.php`
- **Yang perlu diperiksa:**
  - Apakah route untuk halaman pengajuan akun sudah ada?
  - Apakah route untuk approve/reject sudah ada?
  - Apakah ada middleware untuk memastikan hanya super admin yang bisa akses?

#### D. Periksa JavaScript (jika ada AJAX)
- **Lokasi:** `qparkin_backend/public/js/pengajuan-akun.js` atau file JS terkait
- **Yang perlu diperiksa:**
  - Apakah tombol approve/reject menggunakan AJAX?
  - Apakah ada konfirmasi sebelum approve/reject?
  - Apakah UI ter-update setelah aksi berhasil?

---

### 3. AUDIT ALUR DATA END-TO-END

#### A. Periksa Sinkronisasi Data
- **Yang perlu diperiksa:**
  - Apakah data yang di-submit dari form registrasi benar-benar masuk ke database?
  - Apakah data yang ditampilkan di halaman pengajuan akun sesuai dengan data yang di-submit?
  - Apakah tidak ada data yang hilang atau ter-transform salah?

#### B. Periksa Status Management
- **Yang perlu diperiksa:**
  - Apakah status pengajuan ter-update dengan benar saat approve/reject?
  - Apakah pengajuan yang sudah di-approve tidak muncul lagi di list pending?
  - Apakah ada history/log perubahan status?

#### C. Periksa User Creation Flow
- **Yang perlu diperiksa:**
  - Saat super admin approve pengajuan, apakah:
    - User baru dibuat di tabel `users`?
    - Role di-set sebagai 'admin_mall'?
    - Password di-hash dengan benar?
    - Email verifikasi dikirim (jika ada)?
    - Data mall terkait di-link dengan user?

---

### 4. IDENTIFIKASI MASALAH & REKOMENDASI

Setelah audit, berikan laporan dengan struktur:

#### A. Status Saat Ini
- ✅ **Sudah Berfungsi:** [list fitur yang sudah OK]
- ⚠️ **Perlu Perbaikan:** [list fitur yang ada tapi perlu improvement]
- ❌ **Belum Ada:** [list fitur yang missing]

#### B. Masalah yang Ditemukan
Untuk setiap masalah, jelaskan:
1. **Lokasi:** File dan baris kode
2. **Deskripsi:** Apa yang salah/kurang
3. **Dampak:** Apa efeknya ke sistem
4. **Prioritas:** Critical/High/Medium/Low

#### C. Rekomendasi Perbaikan
Untuk setiap masalah, berikan:
1. **Solusi:** Apa yang harus dilakukan
2. **Kode:** Contoh implementasi (jika perlu)
3. **Testing:** Cara memverifikasi perbaikan berhasil

#### D. Checklist Implementasi
Buat checklist step-by-step untuk implementasi perbaikan:
- [ ] Step 1: ...
- [ ] Step 2: ...
- [ ] Step 3: ...

---

## Output yang Diharapkan

Berikan laporan dalam format Markdown dengan struktur:

```markdown
# Laporan Audit: Registrasi Admin Mall & Pengajuan Akun

## 1. Executive Summary
[Ringkasan singkat kondisi sistem]

## 2. Audit Halaman Registrasi Admin Mall
### 2.1 Frontend (View & JavaScript)
[Temuan dan analisis]

### 2.2 Backend (Controller & Route)
[Temuan dan analisis]

### 2.3 Database (Migration & Model)
[Temuan dan analisis]

## 3. Audit Halaman Pengajuan Akun (Super Admin)
### 3.1 Frontend (View & JavaScript)
[Temuan dan analisis]

### 3.2 Backend (Controller & Route)
[Temuan dan analisis]

## 4. Audit Alur Data End-to-End
[Analisis sinkronisasi dan flow]

## 5. Masalah yang Ditemukan
[List masalah dengan detail]

## 6. Rekomendasi Perbaikan
[Solusi dan implementasi]

## 7. Checklist Implementasi
[Step-by-step action items]

## 8. Testing Plan
[Cara test setelah perbaikan]
```

---

## Catatan Penting

1. **Jangan asumsikan** - Periksa file yang sebenarnya ada di codebase
2. **Berikan contoh kode** - Untuk setiap rekomendasi, sertakan snippet kode
3. **Prioritaskan keamanan** - Pastikan validasi, sanitasi, dan authorization sudah benar
4. **Pertimbangkan UX** - Feedback ke user harus jelas dan helpful
5. **Think end-to-end** - Pastikan alur dari form submit sampai data muncul di dashboard benar-benar seamless

---

## Mulai Audit Sekarang

Silakan mulai audit dengan:
1. Membaca file-file yang disebutkan di atas
2. Menganalisis kode yang ada
3. Mengidentifikasi gap dan masalah
4. Memberikan rekomendasi perbaikan yang actionable

Terima kasih!
