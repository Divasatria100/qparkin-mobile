# 📊 TEST CASE QPARKIN - VERSI PPT

**Tanggal:** 6 Januari 2025  
**Platform:** Mobile (Flutter) + Backend (Laravel)

---

## 📋 RINGKASAN EKSEKUTIF

**Total Test Case Lengkap:** 66 test case mencakup semua fitur aplikasi  
**Test Case untuk PPT:** 10 test case dari 5 fitur utama yang sudah bisa dijalankan

### 5 Fitur Utama yang Diuji:
1. ✅ **Registrasi & Login dengan OTP** - Autentikasi user baru
2. ✅ **Booking Parkir Sederhana** - Booking tanpa pemilihan slot manual
3. ✅ **Manajemen Kendaraan** - Tambah dan kelola kendaraan
4. ✅ **Generate QR Code** - QR untuk entry parkir
5. ✅ **Activity & History** - Lihat booking aktif dan riwayat

---

## 📝 TEST CASE DETAIL

### FITUR 1: REGISTRASI & LOGIN DENGAN OTP

#### TC-001: Registrasi User dengan Verifikasi OTP

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Buka aplikasi dan klik "Sign Up" | - | Form registrasi tampil | ⬜ |
| 2 | Isi form registrasi | **Nama:** "Test User"<br>**Nomor HP:** "081234567890"<br>**PIN:** "123456" | Form terisi lengkap | ⬜ |
| 3 | Klik tombol "Sign Up" | - | Loading → Dialog OTP muncul dengan 6 input field | ⬜ |
| 4 | Cek email Mailtrap | - | Email OTP diterima dengan kode 6 digit | ⬜ |
| 5 | Input kode OTP | **Kode:** "123456" | Auto-verify setelah 6 digit terisi | ⬜ |
| 6 | Verifikasi hasil | - | Success message → Redirect ke login page | ⬜ |

**Screenshot:**
```
[ ] Form registrasi
[ ] Dialog OTP dengan countdown timer
[ ] Email OTP di Mailtrap
[ ] Success message
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Issues: _________________
```

---

#### TC-002: Login dengan Nomor HP dan PIN

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Buka aplikasi | - | Halaman login tampil | ⬜ |
| 2 | Isi nomor HP dan PIN | **Nomor HP:** "081234567890"<br>**PIN:** "123456" | Field terisi (PIN masked) | ⬜ |
| 3 | Klik "Login" | - | Loading → Redirect ke Home Page | ⬜ |
| 4 | Verifikasi Home Page | - | Tampil nama user, menu navigasi, dan fitur utama | ⬜ |

**Screenshot:**
```
[ ] Form login
[ ] Home page setelah login berhasil
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Issues: _________________
```

---

### FITUR 2: BOOKING PARKIR SEDERHANA

#### TC-003: Booking Parkir di Mall Sederhana (Auto-Assign Slot)

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Buka Map Page dan pilih mall | **Mall:** "SNL Food Bengkong" | Bottom sheet info mall muncul | ⬜ |
| 2 | Klik "Booking Sekarang" | - | Redirect ke Booking Page | ⬜ |
| 3 | Pilih kendaraan | Pilih dari dropdown | Kendaraan terpilih | ⬜ |
| 4 | Pilih waktu dan durasi | **Waktu:** "14:00"<br>**Durasi:** "2 jam" | Estimasi biaya tampil (contoh: Rp 10.000) | ⬜ |
| 5 | Verifikasi TIDAK ada floor selector | - | Floor selector TIDAK muncul (auto-assign) | ⬜ |
| 6 | Klik "Konfirmasi Booking" | - | Konfirmasi dialog muncul | ⬜ |
| 7 | Klik "Ya, Booking" | - | Success dialog dengan QR code muncul | ⬜ |
| 8 | Verifikasi slot auto-assigned | - | Response memiliki slot code (contoh: SLOT-007) | ⬜ |

**Screenshot:**
```
[ ] Map page dengan marker mall
[ ] Booking page tanpa floor selector
[ ] Estimasi biaya
[ ] Success dialog dengan QR code
[ ] Slot code yang ter-assign
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Auto-assigned Slot: _________________
Total Biaya: _________________
Issues: _________________
```

---

#### TC-004: Validasi Booking dengan Slot Penuh

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Pilih mall dengan slot penuh | - | Mall terpilih | ⬜ |
| 2 | Pilih waktu yang slot-nya penuh | **Waktu:** "14:00" | Waktu terisi | ⬜ |
| 3 | Klik "Cek Ketersediaan" | - | Error message: "Slot tidak tersedia untuk waktu ini" | ⬜ |
| 4 | Verifikasi tombol booking | - | Tombol "Konfirmasi Booking" disabled (tidak bisa diklik) | ⬜ |

**Screenshot:**
```
[ ] Error message slot penuh
[ ] Tombol booking disabled
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Issues: _________________
```

---

### FITUR 3: MANAJEMEN KENDARAAN

#### TC-005: Tambah Kendaraan Baru

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Buka Profile → "Kendaraan Saya" | - | List kendaraan tampil | ⬜ |
| 2 | Klik tombol "+" (Tambah) | - | Form tambah kendaraan tampil | ⬜ |
| 3 | Isi form kendaraan | **Plat:** "B1234XYZ"<br>**Jenis:** "Roda Empat"<br>**Merk:** "Toyota"<br>**Tipe:** "Avanza"<br>**Warna:** "Hitam" | Form terisi lengkap | ⬜ |
| 4 | Upload foto (opsional) | Pilih foto kendaraan | Preview foto muncul | ⬜ |
| 5 | Klik "Simpan" | - | Loading → Success message muncul | ⬜ |
| 6 | Verifikasi list kendaraan | - | Kendaraan baru muncul di list dengan badge "Aktif" | ⬜ |

**Screenshot:**
```
[ ] Form tambah kendaraan
[ ] Preview foto kendaraan
[ ] List kendaraan setelah ditambah
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Issues: _________________
```

---

#### TC-006: Edit dan Hapus Kendaraan

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Klik salah satu kendaraan di list | - | Detail kendaraan tampil | ⬜ |
| 2 | Klik tombol "Edit" | - | Form edit muncul dengan data lama | ⬜ |
| 3 | Ubah warna kendaraan | **Warna:** "Putih" (dari "Hitam") | Field terupdate | ⬜ |
| 4 | Klik "Simpan" | - | Success message → Data baru tampil di detail | ⬜ |
| 5 | Klik tombol "Hapus" | - | Konfirmasi dialog muncul | ⬜ |
| 6 | Klik "Ya, Hapus" | - | Success message → Kendaraan tidak ada di list | ⬜ |

**Screenshot:**
```
[ ] Form edit kendaraan
[ ] Konfirmasi hapus
[ ] List setelah kendaraan dihapus
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Issues: _________________
```

---

### FITUR 4: GENERATE QR CODE

#### TC-007: Generate QR Code untuk Entry Parkir

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Selesai booking parkir | - | Success dialog dengan QR code muncul | ⬜ |
| 2 | Verifikasi QR code | - | QR code tampil dengan jelas dan dapat di-scan | ⬜ |
| 3 | Verifikasi info booking | - | Tampil:<br>- Booking ID<br>- Nama mall<br>- Slot code<br>- Waktu mulai<br>- Durasi | ⬜ |
| 4 | Klik "Simpan QR" | - | QR code tersimpan ke gallery device | ⬜ |
| 5 | Klik "Bagikan" | - | Share sheet muncul (WhatsApp, Email, dll) | ⬜ |

**Screenshot:**
```
[ ] Success dialog dengan QR code
[ ] Info booking lengkap
[ ] QR code tersimpan di gallery
[ ] Share sheet
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Booking ID: _________________
QR Content: _________________
Issues: _________________
```

---

#### TC-008: Tampilkan QR Code dari Activity Page

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Buka Activity Page | - | Active booking tampil | ⬜ |
| 2 | Klik "Tampilkan QR" | - | QR code dialog muncul | ⬜ |
| 3 | Verifikasi QR code | - | QR code sama dengan saat booking | ⬜ |
| 4 | Verifikasi countdown timer | - | Timer menunjukkan sisa waktu parkir | ⬜ |
| 5 | Tutup dialog | - | Kembali ke Activity Page | ⬜ |

**Screenshot:**
```
[ ] Activity page dengan active booking
[ ] QR code dialog
[ ] Countdown timer
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Issues: _________________
```

---

### FITUR 5: ACTIVITY & HISTORY

#### TC-009: Lihat Active Parking dengan Timer

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Buka Activity Page | - | Tab "Active" terpilih (default) | ⬜ |
| 2 | Verifikasi booking card | - | Card menampilkan:<br>- Nama mall<br>- Slot code<br>- Waktu mulai & selesai<br>- Status "Active" | ⬜ |
| 3 | Verifikasi circular timer | - | Timer circular dengan progress bar<br>Tampil sisa waktu (contoh: "1j 30m") | ⬜ |
| 4 | Tunggu 1 menit | - | Timer update otomatis | ⬜ |
| 5 | Verifikasi warna timer | - | Hijau jika > 30 menit<br>Kuning jika 10-30 menit<br>Merah jika < 10 menit | ⬜ |
| 6 | Klik "Tampilkan QR" | - | QR code dialog muncul untuk exit | ⬜ |

**Screenshot:**
```
[ ] Activity page dengan active booking
[ ] Circular timer dengan progress
[ ] Timer dengan warna berbeda (hijau/kuning/merah)
[ ] QR code button
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Sisa Waktu: _________________
Issues: _________________
```

---

#### TC-010: Lihat History Parking

| No | Langkah Pengujian | Input | Output Expected | Pass/Fail |
|----|-------------------|-------|-----------------|-----------|
| 1 | Buka Activity Page | - | Tampil di tab Active | ⬜ |
| 2 | Klik tab "History" | - | Tab History terpilih | ⬜ |
| 3 | Verifikasi list history | - | Tampil list booking selesai, urutan terbaru ke terlama | ⬜ |
| 4 | Verifikasi booking card | - | Card menampilkan:<br>- Nama mall<br>- Slot code<br>- Tanggal<br>- Durasi<br>- Total biaya<br>- Status "Completed" | ⬜ |
| 5 | Klik salah satu history | - | Redirect ke Detail History dengan info lengkap | ⬜ |
| 6 | Verifikasi detail | - | Tampil semua informasi booking yang sudah selesai | ⬜ |

**Screenshot:**
```
[ ] History tab dengan list booking
[ ] Booking card dengan status completed
[ ] Detail history page
```

**Catatan:**
```
Tested by: _________________
Date: _________________
Status: ⬜ Pass  ⬜ Fail
Total History: _________________
Issues: _________________
```

---

## 📊 SUMMARY HASIL TESTING

### Rekapitulasi Test Case

| No | Fitur | Test Case | Status | Catatan |
|----|-------|-----------|--------|---------|
| 1 | Registrasi & Login | TC-001: Registrasi dengan OTP | ⬜ Pass / ⬜ Fail | |
| 2 | Registrasi & Login | TC-002: Login dengan PIN | ⬜ Pass / ⬜ Fail | |
| 3 | Booking Parkir | TC-003: Booking Sederhana | ⬜ Pass / ⬜ Fail | |
| 4 | Booking Parkir | TC-004: Validasi Slot Penuh | ⬜ Pass / ⬜ Fail | |
| 5 | Manajemen Kendaraan | TC-005: Tambah Kendaraan | ⬜ Pass / ⬜ Fail | |
| 6 | Manajemen Kendaraan | TC-006: Edit & Hapus | ⬜ Pass / ⬜ Fail | |
| 7 | Generate QR | TC-007: Generate QR Entry | ⬜ Pass / ⬜ Fail | |
| 8 | Generate QR | TC-008: Tampilkan QR | ⬜ Pass / ⬜ Fail | |
| 9 | Activity & History | TC-009: Active Parking | ⬜ Pass / ⬜ Fail | |
| 10 | Activity & History | TC-010: History Parking | ⬜ Pass / ⬜ Fail | |

**Total:** 10 Test Case  
**Pass:** ___ / 10  
**Fail:** ___ / 10  
**Pass Rate:** ____%

---

## 🎯 KESIMPULAN

### Fitur yang Sudah Berfungsi:
- ✅ Registrasi user dengan OTP verification via email
- ✅ Login dengan nomor HP dan PIN
- ✅ Booking parkir sederhana dengan auto-assign slot
- ✅ Manajemen kendaraan (tambah, edit, hapus)
- ✅ Generate dan tampilkan QR code untuk entry/exit
- ✅ Activity page dengan countdown timer
- ✅ History parking dengan detail lengkap

### Highlight Implementasi:
- ✅ **OTP System:** Email verification via Mailtrap
- ✅ **Auto-Assign Slot:** Sistem otomatis assign slot untuk mencegah overbooking
- ✅ **Real-time Timer:** Countdown timer dengan warna dinamis
- ✅ **QR Code:** Generate dan simpan QR untuk entry/exit parkir
- ✅ **Responsive UI:** Tampilan menyesuaikan berbagai ukuran layar

### Rekomendasi:
1. Lanjutkan testing untuk fitur lanjutan (Point System, Slot Reservation Manual)
2. Lakukan User Acceptance Testing (UAT) dengan user real
3. Monitor performance dan error rate di production
4. Dokumentasikan bug yang ditemukan untuk perbaikan

---

**Prepared by:** QA Team  
**Date:** 6 Januari 2025  
**Version:** 1.0 (PPT Ready)  
**Status:** ✅ Ready for Presentation

---

## 📸 PANDUAN SCREENSHOT UNTUK PPT

### Slide 1: Registrasi & Login
- Screenshot form registrasi
- Screenshot dialog OTP
- Screenshot email Mailtrap
- Screenshot home page setelah login

### Slide 2: Booking Parkir
- Screenshot map dengan marker mall
- Screenshot booking form
- Screenshot estimasi biaya
- Screenshot success dialog

### Slide 3: Manajemen Kendaraan
- Screenshot list kendaraan
- Screenshot form tambah kendaraan
- Screenshot detail kendaraan

### Slide 4: QR Code
- Screenshot QR code setelah booking
- Screenshot QR code dari activity page
- Screenshot QR tersimpan di gallery

### Slide 5: Activity & History
- Screenshot active booking dengan timer
- Screenshot history list
- Screenshot detail history

---

**END OF DOCUMENT**
