# 📋 TEST CASE QPARKIN - COMPREHENSIVE TESTING DOCUMENT

**Tanggal Pembuatan:** 6 Januari 2025  
**Versi:** 1.0  
**Status:** Ready for Testing  
**Platform:** Mobile (Flutter) + Backend (Laravel)

---

## 📊 DAFTAR ISI

1. [Fitur Autentikasi](#1-fitur-autentikasi)
2. [Fitur Manajemen Kendaraan](#2-fitur-manajemen-kendaraan)
3. [Fitur Booking Parkir](#3-fitur-booking-parkir)
4. [Fitur Slot Reservation](#4-fitur-slot-reservation)
5. [Fitur Activity & History](#5-fitur-activity--history)
6. [Fitur Admin Parkiran](#6-fitur-admin-parkiran)
7. [Fitur Point System](#7-fitur-point-system)
8. [Fitur Notifikasi](#8-fitur-notifikasi)

---

## 1. FITUR AUTENTIKASI

### TC-AUTH-001: Registrasi User dengan OTP

**Deskripsi:** User baru melakukan registrasi dan verifikasi OTP via email

**Prasyarat:**
- Backend server running
- Mailtrap configured
- Nomor HP belum terdaftar

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka aplikasi | - | Tampil halaman login |
| 2 | Klik "Sign Up" | - | Tampil form registrasi |
| 3 | Isi form registrasi | Nama: "Test User"<br>Nomor HP: "081234567890"<br>PIN: "123456" | Form terisi |
| 4 | Klik tombol "Sign Up" | - | Loading indicator muncul |
| 5 | Tunggu response | - | Dialog OTP muncul dengan 6 input field |
| 6 | Cek email Mailtrap | - | Email OTP diterima dengan kode 6 digit |
| 7 | Input OTP | Kode: "123456" | Auto-verify setelah 6 digit terisi |
| 8 | Tunggu verifikasi | - | Success message muncul |
| 9 | Redirect ke login | - | Halaman login tampil |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Form registrasi
- [ ] Dialog OTP
- [ ] Email Mailtrap
- [ ] Success message

**Catatan:**
```
Status: _________________
Tested by: _________________
Date: _________________
Issues: _________________
```

---

### TC-AUTH-002: Login dengan Nomor HP dan PIN

**Deskripsi:** User login menggunakan nomor HP dan PIN 6 digit

**Prasyarat:**
- User sudah terdaftar
- Backend server running

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka aplikasi | - | Tampil halaman login |
| 2 | Isi nomor HP | "081234567890" | Field terisi |
| 3 | Isi PIN | "123456" | Field terisi (masked) |
| 4 | Klik "Login" | - | Loading indicator muncul |
| 5 | Tunggu response | - | Redirect ke Home Page |
| 6 | Verifikasi token | - | Token tersimpan di secure storage |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Form login
- [ ] Home page setelah login

**Catatan:**
```
Status: _________________
```

---


### TC-AUTH-003: Login dengan Google Sign-In

**Deskripsi:** User login menggunakan akun Google

**Prasyarat:**
- Google Sign-In configured
- User memiliki akun Google

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka aplikasi | - | Tampil halaman login |
| 2 | Klik tombol "Sign in with Google" | - | Google account picker muncul |
| 3 | Pilih akun Google | Email Google | Loading indicator muncul |
| 4 | Tunggu response | - | Redirect ke Home Page |
| 5 | Verifikasi profil | - | Nama dan email dari Google tersimpan |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-AUTH-004: Resend OTP

**Deskripsi:** User meminta pengiriman ulang kode OTP

**Prasyarat:**
- Dialog OTP terbuka
- Countdown timer habis (5 menit)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Tunggu countdown habis | - | Timer menunjukkan 00:00 |
| 2 | Klik "Kirim Ulang" | - | Loading indicator muncul |
| 3 | Tunggu response | - | Success message "OTP telah dikirim ulang" |
| 4 | Cek email Mailtrap | - | Email baru dengan OTP baru diterima |
| 5 | Input OTP baru | Kode baru | Verifikasi berhasil |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

## 2. FITUR MANAJEMEN KENDARAAN

### TC-VEH-001: Tambah Kendaraan Baru

**Deskripsi:** User menambahkan kendaraan baru ke akun

**Prasyarat:**
- User sudah login
- Backend server running

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Profile Page | - | Tampil menu profil |
| 2 | Klik "Kendaraan Saya" | - | Tampil list kendaraan |
| 3 | Klik tombol "+" (Tambah) | - | Tampil form tambah kendaraan |
| 4 | Isi form | Plat: "B1234XYZ"<br>Jenis: "Roda Empat"<br>Merk: "Toyota"<br>Tipe: "Avanza"<br>Warna: "Hitam" | Form terisi |
| 5 | Upload foto (opsional) | Foto kendaraan | Preview foto muncul |
| 6 | Klik "Simpan" | - | Loading indicator muncul |
| 7 | Tunggu response | - | Success message muncul |
| 8 | Kembali ke list | - | Kendaraan baru muncul di list |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Form tambah kendaraan
- [ ] List kendaraan setelah ditambah

**Catatan:**
```
Status: _________________
```

---

### TC-VEH-002: Edit Kendaraan

**Deskripsi:** User mengubah data kendaraan yang sudah ada

**Prasyarat:**
- User sudah login
- Minimal 1 kendaraan sudah terdaftar

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka "Kendaraan Saya" | - | Tampil list kendaraan |
| 2 | Klik salah satu kendaraan | - | Tampil detail kendaraan |
| 3 | Klik tombol "Edit" | - | Form edit muncul dengan data lama |
| 4 | Ubah data | Warna: "Putih" (dari "Hitam") | Field terupdate |
| 5 | Klik "Simpan" | - | Loading indicator muncul |
| 6 | Tunggu response | - | Success message muncul |
| 7 | Verifikasi perubahan | - | Data baru tampil di detail |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-VEH-003: Hapus Kendaraan

**Deskripsi:** User menghapus kendaraan dari akun

**Prasyarat:**
- User sudah login
- Minimal 1 kendaraan sudah terdaftar

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka "Kendaraan Saya" | - | Tampil list kendaraan |
| 2 | Klik salah satu kendaraan | - | Tampil detail kendaraan |
| 3 | Klik tombol "Hapus" | - | Konfirmasi dialog muncul |
| 4 | Klik "Ya, Hapus" | - | Loading indicator muncul |
| 5 | Tunggu response | - | Success message muncul |
| 6 | Kembali ke list | - | Kendaraan tidak ada di list |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-VEH-004: Set Kendaraan Aktif

**Deskripsi:** User mengatur kendaraan default untuk booking

**Prasyarat:**
- User sudah login
- Minimal 2 kendaraan terdaftar

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka "Kendaraan Saya" | - | Tampil list kendaraan |
| 2 | Pilih kendaraan non-aktif | - | Tampil detail kendaraan |
| 3 | Klik "Set sebagai Aktif" | - | Loading indicator muncul |
| 4 | Tunggu response | - | Badge "Aktif" muncul di kendaraan |
| 5 | Buka booking page | - | Kendaraan aktif otomatis terpilih |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

## 3. FITUR BOOKING PARKIR

### TC-BOOK-001: Booking Parkir di Mall Bertingkat (dengan Slot Selection)

**Deskripsi:** User melakukan booking di mall yang memiliki fitur pemilihan slot

**Prasyarat:**
- User sudah login
- Minimal 1 kendaraan terdaftar
- Mall bertingkat tersedia (Mega Mall / One Batam)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Map Page | - | Tampil peta dengan marker mall |
| 2 | Klik marker "Mega Mall" | - | Bottom sheet info mall muncul |
| 3 | Klik "Booking Sekarang" | - | Redirect ke Booking Page |
| 4 | Verifikasi mall info | - | Nama mall, alamat, tarif tampil |
| 5 | Pilih kendaraan | Pilih dari dropdown | Kendaraan terpilih |
| 6 | Pilih waktu mulai | "14:00" | Waktu terisi |
| 7 | Pilih durasi | "2 jam" | Durasi terisi |
| 8 | Verifikasi estimasi biaya | - | Biaya tampil: Rp 10.000 (2 jam × Rp 5.000) |
| 9 | Klik "Pilih Slot" | - | Floor selector muncul |
| 10 | Pilih lantai | "Lantai 2 Mobil" | Slot visualization tampil |
| 11 | Pilih slot | Klik slot "B-015" | Slot terpilih (warna berubah) |
| 12 | Klik "Reserve Slot" | - | Loading indicator muncul |
| 13 | Tunggu response | - | Slot ter-reserve, summary update |
| 14 | Review booking summary | - | Semua data benar (mall, kendaraan, waktu, slot, biaya) |
| 15 | Klik "Konfirmasi Booking" | - | Konfirmasi dialog muncul |
| 16 | Klik "Ya, Booking" | - | Loading indicator muncul |
| 17 | Tunggu response | - | Success dialog muncul dengan QR code |
| 18 | Klik "Lihat Detail" | - | Redirect ke Activity Page |
| 19 | Verifikasi booking | - | Booking muncul di Activity dengan status "Active" |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Map page dengan marker
- [ ] Booking page dengan form
- [ ] Floor selector
- [ ] Slot visualization
- [ ] Booking summary
- [ ] Success dialog dengan QR
- [ ] Activity page dengan booking

**Catatan:**
```
Status: _________________
Slot Code: _________________
QR Code: _________________
```

---


### TC-BOOK-002: Booking Parkir di Mall Sederhana (Auto-Assign Slot)

**Deskripsi:** User melakukan booking di mall tanpa fitur pemilihan slot (auto-assign)

**Prasyarat:**
- User sudah login
- Minimal 1 kendaraan terdaftar
- Mall sederhana tersedia (SNL Food Bengkong)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Map Page | - | Tampil peta dengan marker mall |
| 2 | Klik marker "SNL Food Bengkong" | - | Bottom sheet info mall muncul |
| 3 | Klik "Booking Sekarang" | - | Redirect ke Booking Page |
| 4 | Verifikasi mall info | - | Nama mall, alamat, tarif tampil |
| 5 | Pilih kendaraan | Pilih dari dropdown | Kendaraan terpilih |
| 6 | Pilih waktu mulai | "10:00" | Waktu terisi |
| 7 | Pilih durasi | "3 jam" | Durasi terisi |
| 8 | Verifikasi estimasi biaya | - | Biaya tampil sesuai tarif mall |
| 9 | Verifikasi TIDAK ada floor selector | - | Floor selector TIDAK muncul |
| 10 | Verifikasi slot availability | - | Tampil "X slot tersedia" |
| 11 | Review booking summary | - | Semua data benar (tanpa slot code) |
| 12 | Klik "Konfirmasi Booking" | - | Konfirmasi dialog muncul |
| 13 | Klik "Ya, Booking" | - | Loading indicator muncul |
| 14 | Tunggu response | - | Success dialog muncul dengan QR code |
| 15 | Verifikasi slot auto-assigned | - | Response API memiliki `id_slot` |
| 16 | Klik "Lihat Detail" | - | Redirect ke Activity Page |
| 17 | Verifikasi booking | - | Booking muncul dengan slot code (SLOT-XXX) |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Booking page tanpa floor selector
- [ ] Slot availability indicator
- [ ] Success dialog
- [ ] Activity page dengan auto-assigned slot

**Catatan:**
```
Status: _________________
Auto-assigned Slot: _________________
```

---

### TC-BOOK-003: Booking dengan Slot Penuh

**Deskripsi:** User mencoba booking ketika semua slot sudah terisi

**Prasyarat:**
- User sudah login
- Semua slot di mall sudah di-booking untuk waktu yang sama

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Booking Page | - | Form booking tampil |
| 2 | Pilih mall dengan slot penuh | - | Mall terpilih |
| 3 | Pilih waktu yang slot-nya penuh | "14:00" | Waktu terisi |
| 4 | Pilih durasi | "2 jam" | Durasi terisi |
| 5 | Klik "Cek Ketersediaan" | - | Loading indicator muncul |
| 6 | Tunggu response | - | Error message: "Slot tidak tersedia untuk waktu ini" |
| 7 | Verifikasi tombol booking | - | Tombol "Konfirmasi Booking" disabled |
| 8 | Ubah waktu | "16:00" | Waktu terupdate |
| 9 | Klik "Cek Ketersediaan" lagi | - | Slot tersedia muncul |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Error message slot penuh
- [ ] Tombol booking disabled

**Catatan:**
```
Status: _________________
```

---

### TC-BOOK-004: Booking Tanpa Kendaraan

**Deskripsi:** User mencoba booking tanpa memiliki kendaraan terdaftar

**Prasyarat:**
- User sudah login
- User TIDAK memiliki kendaraan terdaftar

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Booking Page | - | Form booking tampil |
| 2 | Verifikasi vehicle selector | - | Tampil "Belum ada kendaraan" |
| 3 | Klik "Tambah Kendaraan" | - | Redirect ke form tambah kendaraan |
| 4 | Tambah kendaraan | Data kendaraan | Kendaraan tersimpan |
| 5 | Kembali ke booking page | - | Kendaraan baru muncul di selector |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-BOOK-005: Validasi Input Booking

**Deskripsi:** Sistem memvalidasi input user sebelum booking

**Prasyarat:**
- User sudah login
- User di Booking Page

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Klik "Konfirmasi Booking" tanpa isi form | - | Error: "Pilih kendaraan terlebih dahulu" |
| 2 | Pilih kendaraan | - | Error hilang |
| 3 | Klik "Konfirmasi Booking" | - | Error: "Pilih waktu mulai" |
| 4 | Pilih waktu di masa lalu | "Kemarin 10:00" | Error: "Waktu harus di masa depan" |
| 5 | Pilih waktu valid | "Besok 10:00" | Error hilang |
| 6 | Pilih durasi 0 jam | "0 jam" | Error: "Durasi minimal 1 jam" |
| 7 | Pilih durasi valid | "2 jam" | Error hilang |
| 8 | Klik "Konfirmasi Booking" | - | Validasi berhasil, konfirmasi dialog muncul |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Error messages untuk setiap validasi

**Catatan:**
```
Status: _________________
```

---

## 4. FITUR SLOT RESERVATION

### TC-SLOT-001: Visualisasi Slot Parkir

**Deskripsi:** User melihat visualisasi slot parkir di lantai yang dipilih

**Prasyarat:**
- User di Booking Page
- Mall bertingkat dipilih

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Pilih lantai | "Lantai 1 Mobil" | Loading indicator muncul |
| 2 | Tunggu response | - | Grid slot parkir tampil |
| 3 | Verifikasi warna slot | - | Hijau = available, Merah = occupied, Kuning = reserved |
| 4 | Verifikasi slot code | - | Setiap slot memiliki kode (A-001, A-002, dst) |
| 5 | Hitung jumlah slot | - | Jumlah sesuai dengan `total_slots` lantai |
| 6 | Klik slot available | "A-015" | Slot terpilih (border highlight) |
| 7 | Klik slot occupied | "A-020" | Tidak bisa dipilih, tooltip "Slot sudah terisi" |
| 8 | Klik slot reserved | "A-025" | Tidak bisa dipilih, tooltip "Slot direserve" |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Grid slot dengan berbagai status
- [ ] Slot terpilih dengan highlight
- [ ] Tooltip untuk slot tidak tersedia

**Catatan:**
```
Status: _________________
```

---

### TC-SLOT-002: Reserve Slot Spesifik

**Deskripsi:** User mereserve slot yang dipilih

**Prasyarat:**
- User di Booking Page
- Slot visualization tampil
- Slot available dipilih

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Pilih slot available | "B-032" | Slot terpilih |
| 2 | Klik "Reserve Slot" | - | Loading indicator muncul |
| 3 | Tunggu response | - | Success message "Slot B-032 berhasil direserve" |
| 4 | Verifikasi status slot | - | Slot berubah warna jadi kuning (reserved) |
| 5 | Verifikasi countdown timer | - | Timer 5 menit muncul |
| 6 | Verifikasi booking summary | - | Slot code "B-032" tampil di summary |
| 7 | Coba pilih slot lain | "B-033" | Error: "Anda sudah mereserve slot B-032" |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Slot reserved dengan timer
- [ ] Booking summary dengan slot code

**Catatan:**
```
Status: _________________
Reservation ID: _________________
```

---

### TC-SLOT-003: Reservation Timeout

**Deskripsi:** Reservation otomatis expire setelah 5 menit jika tidak di-booking

**Prasyarat:**
- User sudah reserve slot
- Timer countdown berjalan

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Reserve slot | "A-010" | Slot reserved, timer 5:00 |
| 2 | Tunggu 5 menit | - | Timer countdown: 4:59, 4:58, ... 0:00 |
| 3 | Verifikasi setelah timeout | - | Alert: "Reservation expired, silakan pilih slot lagi" |
| 4 | Verifikasi status slot | - | Slot kembali available (hijau) |
| 5 | Verifikasi booking summary | - | Slot code dihapus dari summary |
| 6 | Refresh slot visualization | - | Slot A-010 available lagi |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Timer countdown
- [ ] Alert timeout
- [ ] Slot kembali available

**Catatan:**
```
Status: _________________
```

---

### TC-SLOT-004: Floor Selector Interaction

**Deskripsi:** User berpindah antar lantai untuk melihat slot

**Prasyarat:**
- User di Booking Page
- Mall bertingkat dengan multiple floors

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Verifikasi floor selector | - | Tampil list lantai (Lantai 1, Lantai 2) |
| 2 | Verifikasi available slots | - | Setiap lantai menampilkan "X/Y slots available" |
| 3 | Klik "Lantai 1 Mobil" | - | Slot visualization Lantai 1 tampil |
| 4 | Klik "Lantai 2 Mobil" | - | Slot visualization Lantai 2 tampil |
| 5 | Verifikasi slot codes | - | Lantai 1: A-XXX, Lantai 2: B-XXX |
| 6 | Pilih slot di Lantai 2 | "B-015" | Slot terpilih |
| 7 | Kembali ke Lantai 1 | - | Slot Lantai 2 tetap reserved |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Floor selector dengan available count
- [ ] Slot visualization per lantai

**Catatan:**
```
Status: _________________
```

---


## 5. FITUR ACTIVITY & HISTORY

### TC-ACT-001: Lihat Active Parking

**Deskripsi:** User melihat booking aktif yang sedang berjalan

**Prasyarat:**
- User sudah login
- User memiliki booking aktif

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Activity Page | - | Tampil tab "Active" dan "History" |
| 2 | Verifikasi tab Active | - | Tab Active terpilih (default) |
| 3 | Verifikasi booking card | - | Card menampilkan:<br>- Nama mall<br>- Slot code<br>- Waktu mulai & selesai<br>- Status "Active" |
| 4 | Verifikasi countdown timer | - | Timer menunjukkan sisa waktu parkir |
| 5 | Verifikasi QR code button | - | Tombol "Tampilkan QR" tersedia |
| 6 | Klik "Tampilkan QR" | - | QR code dialog muncul |
| 7 | Verifikasi QR code | - | QR code valid untuk exit |
| 8 | Tutup QR dialog | - | Kembali ke Activity Page |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Activity page dengan active booking
- [ ] Countdown timer
- [ ] QR code dialog

**Catatan:**
```
Status: _________________
Booking ID: _________________
```

---

### TC-ACT-002: Lihat History Parking

**Deskripsi:** User melihat riwayat booking yang sudah selesai

**Prasyarat:**
- User sudah login
- User memiliki riwayat booking

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Activity Page | - | Tampil di tab Active |
| 2 | Klik tab "History" | - | Tab History terpilih |
| 3 | Verifikasi list history | - | Tampil list booking selesai |
| 4 | Verifikasi sorting | - | Urutan dari terbaru ke terlama |
| 5 | Verifikasi booking card | - | Card menampilkan:<br>- Nama mall<br>- Slot code<br>- Tanggal<br>- Durasi<br>- Total biaya<br>- Status "Completed" |
| 6 | Klik salah satu history | - | Redirect ke Detail History |
| 7 | Verifikasi detail | - | Semua informasi lengkap tampil |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] History tab dengan list booking
- [ ] Detail history page

**Catatan:**
```
Status: _________________
```

---

### TC-ACT-003: QR Code untuk Exit

**Deskripsi:** User menggunakan QR code untuk keluar parkiran

**Prasyarat:**
- User memiliki active booking
- QR scanner tersedia (simulasi)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Activity Page | - | Active booking tampil |
| 2 | Klik "Tampilkan QR" | - | QR code dialog muncul |
| 3 | Verifikasi QR content | - | QR berisi booking ID |
| 4 | Screenshot QR code | - | QR code tersimpan |
| 5 | Scan QR (simulasi backend) | Booking ID | Backend verify booking |
| 6 | Verifikasi response | - | Status booking berubah "Completed" |
| 7 | Refresh Activity Page | - | Booking pindah ke History |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] QR code
- [ ] Booking di history setelah scan

**Catatan:**
```
Status: _________________
QR Content: _________________
```

---

### TC-ACT-004: Empty State - No Active Booking

**Deskripsi:** Tampilan ketika user tidak memiliki booking aktif

**Prasyarat:**
- User sudah login
- User TIDAK memiliki booking aktif

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Activity Page | - | Tab Active terpilih |
| 2 | Verifikasi empty state | - | Tampil ilustrasi + pesan "Belum ada booking aktif" |
| 3 | Verifikasi CTA button | - | Tombol "Booking Sekarang" tersedia |
| 4 | Klik "Booking Sekarang" | - | Redirect ke Map Page |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Empty state active booking

**Catatan:**
```
Status: _________________
```

---

### TC-ACT-005: Circular Timer Widget

**Deskripsi:** Timer countdown visual untuk active booking

**Prasyarat:**
- User memiliki active booking

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Activity Page | - | Active booking tampil |
| 2 | Verifikasi circular timer | - | Timer circular dengan progress bar |
| 3 | Verifikasi waktu tersisa | - | Tampil "1j 30m" atau format serupa |
| 4 | Tunggu 1 menit | - | Timer update otomatis |
| 5 | Verifikasi warna timer | - | Hijau jika > 30 menit<br>Kuning jika 10-30 menit<br>Merah jika < 10 menit |
| 6 | Verifikasi progress bar | - | Progress berkurang seiring waktu |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Circular timer dengan berbagai warna

**Catatan:**
```
Status: _________________
```

---

## 6. FITUR ADMIN PARKIRAN

### TC-ADM-001: Tambah Parkiran Baru dengan Auto-Generate Slot

**Deskripsi:** Admin mall menambahkan parkiran baru dan sistem auto-generate slot

**Prasyarat:**
- Login sebagai admin mall
- Backend server running

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Login admin | Credentials admin | Dashboard admin tampil |
| 2 | Navigate ke "Parkiran" | - | List parkiran tampil |
| 3 | Klik "Tambah Parkiran Baru" | - | Form tambah parkiran tampil |
| 4 | Isi form | Nama: "Parkiran Mawar"<br>Kode: "MWR"<br>Jumlah Lantai: 2 | Form terisi |
| 5 | Isi lantai 1 | Nama: "Lantai 1 Mobil"<br>Jumlah Slot: 30 | Lantai 1 terisi |
| 6 | Klik "Tambah Lantai" | - | Form lantai 2 muncul |
| 7 | Isi lantai 2 | Nama: "Lantai 2 Mobil"<br>Jumlah Slot: 25 | Lantai 2 terisi |
| 8 | Verifikasi preview | - | Total kapasitas: 55 slot |
| 9 | Klik "Simpan" | - | Loading indicator muncul |
| 10 | Tunggu response | - | Success message muncul |
| 11 | Verifikasi database | Query SQL | Parkiran tersimpan |
| 12 | Verifikasi floors | Query SQL | 2 floors tersimpan |
| 13 | Verifikasi slots | Query SQL | 55 slots ter-generate:<br>- MWR-L1-001 s/d MWR-L1-030<br>- MWR-L2-001 s/d MWR-L2-025 |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Form tambah parkiran
- [ ] Preview kapasitas
- [ ] Success message
- [ ] Database records

**SQL Verification:**
```sql
-- Cek parkiran
SELECT * FROM parkiran WHERE kode_parkiran = 'MWR';

-- Cek floors
SELECT * FROM parking_floors WHERE id_parkiran = ?;

-- Cek slots
SELECT slot_code FROM parking_slots 
WHERE id_floor IN (SELECT id_floor FROM parking_floors WHERE id_parkiran = ?)
ORDER BY slot_code;
```

**Catatan:**
```
Status: _________________
Parkiran ID: _________________
Total Slots Generated: _________________
```

---

### TC-ADM-002: Edit Parkiran

**Deskripsi:** Admin mengubah data parkiran yang sudah ada

**Prasyarat:**
- Login sebagai admin
- Minimal 1 parkiran sudah ada

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka list parkiran | - | List parkiran tampil |
| 2 | Klik "Edit" pada parkiran | - | Form edit tampil dengan data lama |
| 3 | Ubah nama parkiran | "Parkiran Mawar Baru" | Field terupdate |
| 4 | Ubah jumlah slot lantai 1 | 35 (dari 30) | Field terupdate |
| 5 | Verifikasi preview | - | Total kapasitas: 60 slot (35 + 25) |
| 6 | Klik "Simpan" | - | Loading indicator muncul |
| 7 | Tunggu response | - | Success message muncul |
| 8 | Verifikasi database | Query SQL | Data terupdate |
| 9 | Verifikasi slots | Query SQL | 5 slot baru ter-generate (MWR-L1-031 s/d MWR-L1-035) |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-ADM-003: Hapus Parkiran (Cascade Delete)

**Deskripsi:** Admin menghapus parkiran dan semua data terkait terhapus

**Prasyarat:**
- Login sebagai admin
- Parkiran test tersedia

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka list parkiran | - | List parkiran tampil |
| 2 | Klik "Hapus" pada parkiran test | - | Konfirmasi dialog muncul |
| 3 | Klik "Ya, Hapus" | - | Loading indicator muncul |
| 4 | Tunggu response | - | Success message muncul |
| 5 | Verifikasi list | - | Parkiran tidak ada di list |
| 6 | Verifikasi database parkiran | Query SQL | Record terhapus |
| 7 | Verifikasi database floors | Query SQL | Floors terhapus (cascade) |
| 8 | Verifikasi database slots | Query SQL | Slots terhapus (cascade) |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**SQL Verification:**
```sql
-- Cek parkiran (should be empty)
SELECT * FROM parkiran WHERE id_parkiran = ?;

-- Cek floors (should be empty)
SELECT * FROM parking_floors WHERE id_parkiran = ?;

-- Cek slots (should be empty)
SELECT * FROM parking_slots WHERE id_floor IN 
  (SELECT id_floor FROM parking_floors WHERE id_parkiran = ?);
```

**Catatan:**
```
Status: _________________
```

---

### TC-ADM-004: Lihat Detail Parkiran dengan Status Slot

**Deskripsi:** Admin melihat detail parkiran dan status real-time slot

**Prasyarat:**
- Login sebagai admin
- Parkiran dengan booking aktif tersedia

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka list parkiran | - | List parkiran tampil |
| 2 | Klik "Detail" pada parkiran | - | Detail page tampil |
| 3 | Verifikasi info parkiran | - | Nama, kode, kapasitas tampil |
| 4 | Verifikasi summary | - | Tampil:<br>- Total slots<br>- Available slots<br>- Occupied slots<br>- Reserved slots |
| 5 | Verifikasi list lantai | - | Semua lantai tampil dengan status |
| 6 | Klik lantai | "Lantai 1" | Expand detail lantai |
| 7 | Verifikasi slot visualization | - | Grid slot dengan warna status |
| 8 | Verifikasi legend | - | Hijau = available<br>Merah = occupied<br>Kuning = reserved<br>Abu = maintenance |
| 9 | Klik refresh | - | Data terupdate real-time |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Detail parkiran page
- [ ] Summary statistics
- [ ] Slot visualization per lantai

**Catatan:**
```
Status: _________________
Available Slots: _________________
```

---


## 7. FITUR POINT SYSTEM

### TC-PNT-001: Lihat Saldo Point

**Deskripsi:** User melihat saldo point yang dimiliki

**Prasyarat:**
- User sudah login
- User memiliki point

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Home Page | - | Premium Points Card tampil |
| 2 | Verifikasi saldo point | - | Tampil jumlah point (contoh: "1,250 Points") |
| 3 | Verifikasi badge tier | - | Tampil tier (Bronze/Silver/Gold/Platinum) |
| 4 | Klik card point | - | Redirect ke Point Page |
| 5 | Verifikasi Point Page | - | Tampil:<br>- Saldo point besar<br>- Point balance card<br>- Point history |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Premium Points Card di Home
- [ ] Point Page dengan saldo

**Catatan:**
```
Status: _________________
Current Points: _________________
Tier: _________________
```

---

### TC-PNT-002: Riwayat Point (Earn & Spend)

**Deskripsi:** User melihat riwayat perolehan dan penggunaan point

**Prasyarat:**
- User sudah login
- User memiliki riwayat point

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Point Page | - | Point history tampil |
| 2 | Verifikasi list history | - | Tampil list transaksi point |
| 3 | Verifikasi item earn | - | Item dengan icon "+" hijau:<br>- Deskripsi: "Booking Completed"<br>- Point: "+50"<br>- Tanggal |
| 4 | Verifikasi item spend | - | Item dengan icon "-" merah:<br>- Deskripsi: "Discount Applied"<br>- Point: "-100"<br>- Tanggal |
| 5 | Verifikasi sorting | - | Urutan dari terbaru ke terlama |
| 6 | Scroll ke bawah | - | Load more history (pagination) |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Point history list
- [ ] Earn transaction
- [ ] Spend transaction

**Catatan:**
```
Status: _________________
```

---

### TC-PNT-003: Filter Riwayat Point

**Deskripsi:** User memfilter riwayat point berdasarkan tipe dan periode

**Prasyarat:**
- User di Point Page
- User memiliki riwayat point

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Klik tombol "Filter" | - | Filter bottom sheet muncul |
| 2 | Pilih tipe "Earn" | - | Checkbox terpilih |
| 3 | Pilih periode "7 Hari Terakhir" | - | Radio button terpilih |
| 4 | Klik "Terapkan Filter" | - | Bottom sheet tutup |
| 5 | Verifikasi hasil | - | Hanya tampil transaksi earn 7 hari terakhir |
| 6 | Buka filter lagi | - | Filter tersimpan |
| 7 | Pilih "Semua Tipe" | - | Checkbox terpilih |
| 8 | Pilih "30 Hari Terakhir" | - | Radio button terpilih |
| 9 | Klik "Terapkan Filter" | - | Tampil semua transaksi 30 hari |
| 10 | Klik "Reset Filter" | - | Filter kembali default |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Filter bottom sheet
- [ ] Hasil filter

**Catatan:**
```
Status: _________________
```

---

### TC-PNT-004: Point Statistics

**Deskripsi:** User melihat statistik point (total earned, spent, balance)

**Prasyarat:**
- User di Point Page
- User memiliki riwayat point

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Point Page | - | Statistics card tampil |
| 2 | Verifikasi total earned | - | Tampil total point yang didapat |
| 3 | Verifikasi total spent | - | Tampil total point yang digunakan |
| 4 | Verifikasi current balance | - | Tampil saldo saat ini |
| 5 | Verifikasi perhitungan | - | Balance = Earned - Spent |
| 6 | Klik "Lihat Detail" | - | Expand detail statistics |
| 7 | Verifikasi breakdown | - | Tampil breakdown per kategori |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Statistics card
- [ ] Detail breakdown

**Catatan:**
```
Status: _________________
Total Earned: _________________
Total Spent: _________________
Balance: _________________
```

---

### TC-PNT-005: Gunakan Point untuk Diskon Booking

**Deskripsi:** User menggunakan point untuk mendapat diskon saat booking

**Prasyarat:**
- User memiliki point cukup (min 100 point)
- User di Booking Page

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Isi form booking | Mall, kendaraan, waktu, durasi | Form terisi |
| 2 | Verifikasi biaya awal | - | Tampil biaya: Rp 20.000 |
| 3 | Verifikasi point usage widget | - | Widget "Gunakan Point" tampil |
| 4 | Verifikasi saldo point | - | Tampil saldo: "1,250 Points" |
| 5 | Klik "Gunakan Point" | - | Slider muncul |
| 6 | Geser slider | 100 point | Tampil diskon: "Rp 10.000" |
| 7 | Verifikasi biaya akhir | - | Biaya: Rp 10.000 (setelah diskon) |
| 8 | Verifikasi saldo setelah | - | Saldo akan jadi: "1,150 Points" |
| 9 | Klik "Konfirmasi Booking" | - | Konfirmasi dialog tampil dengan diskon |
| 10 | Klik "Ya, Booking" | - | Booking berhasil |
| 11 | Verifikasi point history | - | Transaksi "-100 Point Discount" muncul |
| 12 | Verifikasi saldo point | - | Saldo berkurang jadi 1,150 |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Point usage widget
- [ ] Slider point
- [ ] Biaya setelah diskon
- [ ] Point history setelah booking

**Catatan:**
```
Status: _________________
Points Used: _________________
Discount Amount: _________________
Final Balance: _________________
```

---

### TC-PNT-006: Point Info & Help

**Deskripsi:** User melihat informasi cara kerja point system

**Prasyarat:**
- User di Point Page

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Klik icon "Info" | - | Point info bottom sheet muncul |
| 2 | Verifikasi konten | - | Tampil:<br>- Cara mendapat point<br>- Cara menggunakan point<br>- Konversi point (1 point = Rp 100)<br>- Tier system<br>- Expiry policy |
| 3 | Scroll konten | - | Semua info terbaca |
| 4 | Klik "Mengerti" | - | Bottom sheet tutup |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Point info bottom sheet

**Catatan:**
```
Status: _________________
```

---

## 8. FITUR NOTIFIKASI

### TC-NOT-001: Lihat Daftar Notifikasi

**Deskripsi:** User melihat semua notifikasi yang diterima

**Prasyarat:**
- User sudah login
- User memiliki notifikasi

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Home Page | - | Bell icon dengan badge count tampil |
| 2 | Verifikasi badge count | - | Tampil jumlah unread (contoh: "3") |
| 3 | Klik bell icon | - | Redirect ke Notification Page |
| 4 | Verifikasi list notifikasi | - | Tampil list notifikasi |
| 5 | Verifikasi notifikasi unread | - | Background putih, bold text |
| 6 | Verifikasi notifikasi read | - | Background abu, normal text |
| 7 | Verifikasi konten | - | Setiap notifikasi memiliki:<br>- Icon<br>- Title<br>- Message<br>- Timestamp |
| 8 | Verifikasi sorting | - | Urutan dari terbaru ke terlama |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Bell icon dengan badge
- [ ] Notification page

**Catatan:**
```
Status: _________________
Unread Count: _________________
```

---

### TC-NOT-002: Mark Notifikasi sebagai Read

**Deskripsi:** User menandai notifikasi sebagai sudah dibaca

**Prasyarat:**
- User di Notification Page
- User memiliki notifikasi unread

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Verifikasi unread count | - | Badge count: "3" |
| 2 | Klik notifikasi unread | - | Notifikasi detail muncul |
| 3 | Verifikasi status | - | Notifikasi berubah jadi read (background abu) |
| 4 | Kembali ke Home | - | Badge count berkurang: "2" |
| 5 | Buka Notification Page lagi | - | Notifikasi tetap read |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Notifikasi sebelum read
- [ ] Notifikasi setelah read
- [ ] Badge count update

**Catatan:**
```
Status: _________________
```

---

### TC-NOT-003: Notifikasi Booking Reminder

**Deskripsi:** User menerima notifikasi reminder 30 menit sebelum booking

**Prasyarat:**
- User memiliki booking 30 menit lagi
- Push notification enabled

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buat booking | Waktu: 30 menit dari sekarang | Booking berhasil |
| 2 | Tunggu 30 menit | - | Push notification muncul |
| 3 | Verifikasi notifikasi | - | Title: "Booking Reminder"<br>Message: "Booking Anda di [Mall] akan dimulai dalam 30 menit" |
| 4 | Tap notifikasi | - | App terbuka ke Activity Page |
| 5 | Verifikasi in-app notification | - | Notifikasi muncul di Notification Page |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Push notification
- [ ] In-app notification

**Catatan:**
```
Status: _________________
Notification Time: _________________
```

---

### TC-NOT-004: Notifikasi Booking Completed

**Deskripsi:** User menerima notifikasi setelah booking selesai

**Prasyarat:**
- User memiliki active booking
- Booking selesai (scan QR exit)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Scan QR exit | - | Booking completed |
| 2 | Verifikasi push notification | - | Notification muncul:<br>Title: "Booking Completed"<br>Message: "Terima kasih telah parkir di [Mall]. Anda mendapat 50 point!" |
| 3 | Tap notifikasi | - | App terbuka ke History detail |
| 4 | Verifikasi in-app notification | - | Notifikasi muncul di Notification Page |
| 5 | Verifikasi point | - | Point bertambah 50 |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Push notification completed
- [ ] Point earned notification

**Catatan:**
```
Status: _________________
Points Earned: _________________
```

---


## 9. FITUR PROFILE & SETTINGS

### TC-PRF-001: Lihat Profile User

**Deskripsi:** User melihat informasi profil pribadi

**Prasyarat:**
- User sudah login

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Profile Page | - | Profile page tampil |
| 2 | Verifikasi foto profil | - | Foto profil tampil (default atau custom) |
| 3 | Verifikasi nama | - | Nama user tampil |
| 4 | Verifikasi nomor HP | - | Nomor HP tampil |
| 5 | Verifikasi email | - | Email tampil (jika ada) |
| 6 | Verifikasi menu | - | Menu tersedia:<br>- Kendaraan Saya<br>- Riwayat Booking<br>- Point Saya<br>- Pengaturan<br>- Logout |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Profile page

**Catatan:**
```
Status: _________________
```

---

### TC-PRF-002: Edit Profile

**Deskripsi:** User mengubah informasi profil

**Prasyarat:**
- User sudah login

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Profile Page | - | Profile page tampil |
| 2 | Klik "Edit Profile" | - | Form edit tampil |
| 3 | Ubah nama | "John Doe Updated" | Field terupdate |
| 4 | Ubah email | "john@example.com" | Field terupdate |
| 5 | Upload foto profil | Pilih foto | Preview foto muncul |
| 6 | Klik "Simpan" | - | Loading indicator muncul |
| 7 | Tunggu response | - | Success message muncul |
| 8 | Verifikasi perubahan | - | Data baru tampil di profile |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Form edit profile
- [ ] Profile setelah update

**Catatan:**
```
Status: _________________
```

---

### TC-PRF-003: Ubah PIN

**Deskripsi:** User mengubah PIN login

**Prasyarat:**
- User sudah login

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Profile Page | - | Profile page tampil |
| 2 | Klik "Ubah PIN" | - | Form ubah PIN tampil |
| 3 | Isi PIN lama | "123456" | Field terisi (masked) |
| 4 | Isi PIN baru | "654321" | Field terisi (masked) |
| 5 | Isi konfirmasi PIN | "654321" | Field terisi (masked) |
| 6 | Klik "Simpan" | - | Loading indicator muncul |
| 7 | Tunggu response | - | Success message muncul |
| 8 | Logout | - | Redirect ke login |
| 9 | Login dengan PIN baru | "654321" | Login berhasil |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-PRF-004: Logout

**Deskripsi:** User keluar dari aplikasi

**Prasyarat:**
- User sudah login

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Profile Page | - | Profile page tampil |
| 2 | Klik "Logout" | - | Konfirmasi dialog muncul |
| 3 | Klik "Ya, Logout" | - | Loading indicator muncul |
| 4 | Tunggu response | - | Redirect ke login page |
| 5 | Verifikasi token | - | Token terhapus dari secure storage |
| 6 | Coba akses protected page | - | Redirect ke login |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

## 10. FITUR MAP & NAVIGATION

### TC-MAP-001: Lihat Peta Mall

**Deskripsi:** User melihat peta dengan marker mall

**Prasyarat:**
- User sudah login
- Location permission granted

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Map Page | - | Peta tampil dengan loading |
| 2 | Tunggu map load | - | Peta tampil dengan marker mall |
| 3 | Verifikasi marker | - | Marker untuk setiap mall tampil |
| 4 | Verifikasi user location | - | Blue dot menunjukkan lokasi user |
| 5 | Zoom in/out | Pinch gesture | Peta zoom sesuai gesture |
| 6 | Pan map | Drag gesture | Peta bergerak sesuai drag |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Map dengan markers
- [ ] User location

**Catatan:**
```
Status: _________________
```

---

### TC-MAP-002: Klik Marker Mall

**Deskripsi:** User mengklik marker untuk melihat info mall

**Prasyarat:**
- User di Map Page

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Klik marker mall | "Mega Mall" | Bottom sheet info muncul |
| 2 | Verifikasi info | - | Tampil:<br>- Nama mall<br>- Alamat<br>- Jarak dari user<br>- Tarif parkir<br>- Available slots |
| 3 | Verifikasi tombol | - | Tombol "Booking Sekarang" dan "Lihat Rute" tersedia |
| 4 | Klik "Lihat Rute" | - | Google Maps terbuka dengan rute |
| 5 | Kembali ke app | - | Bottom sheet masih terbuka |
| 6 | Klik "Booking Sekarang" | - | Redirect ke Booking Page |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Bottom sheet info mall
- [ ] Google Maps dengan rute

**Catatan:**
```
Status: _________________
```

---

### TC-MAP-003: Search Mall

**Deskripsi:** User mencari mall menggunakan search bar

**Prasyarat:**
- User di Map Page

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Klik search bar | - | Keyboard muncul |
| 2 | Ketik nama mall | "Mega" | Autocomplete suggestions muncul |
| 3 | Pilih suggestion | "Mega Mall Batam Centre" | Peta zoom ke mall |
| 4 | Verifikasi marker | - | Marker mall ter-highlight |
| 5 | Verifikasi bottom sheet | - | Info mall otomatis muncul |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Search bar dengan suggestions
- [ ] Peta zoom ke mall

**Catatan:**
```
Status: _________________
```

---

## 11. FITUR QR CODE

### TC-QR-001: Generate QR Code untuk Entry

**Deskripsi:** Sistem generate QR code setelah booking berhasil

**Prasyarat:**
- User berhasil booking

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Selesai booking | - | Success dialog dengan QR muncul |
| 2 | Verifikasi QR code | - | QR code tampil dengan jelas |
| 3 | Verifikasi info | - | Tampil:<br>- Booking ID<br>- Mall name<br>- Slot code<br>- Waktu mulai |
| 4 | Klik "Simpan QR" | - | QR tersimpan ke gallery |
| 5 | Klik "Bagikan" | - | Share sheet muncul |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] QR code dialog
- [ ] QR tersimpan di gallery

**Catatan:**
```
Status: _________________
QR Content: _________________
```

---

### TC-QR-002: Scan QR Code untuk Exit

**Deskripsi:** User scan QR code untuk keluar parkiran

**Prasyarat:**
- User memiliki active booking
- QR scanner tersedia

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Activity Page | - | Active booking tampil |
| 2 | Klik "Tampilkan QR Exit" | - | QR code dialog muncul |
| 3 | Scan QR dengan scanner | - | Scanner baca QR |
| 4 | Verifikasi backend | - | Backend verify booking ID |
| 5 | Verifikasi response | - | Exit berhasil, biaya final dihitung |
| 6 | Verifikasi status | - | Booking status jadi "Completed" |
| 7 | Verifikasi point | - | Point earned ditambahkan |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] QR exit code
- [ ] Scan result

**Catatan:**
```
Status: _________________
Final Cost: _________________
Points Earned: _________________
```

---

## 12. FITUR RESPONSIVENESS & ACCESSIBILITY

### TC-RES-001: Responsive Design - Tablet

**Deskripsi:** Aplikasi tampil dengan baik di tablet

**Prasyarat:**
- Aplikasi running di tablet atau emulator tablet

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Home Page | - | Layout menyesuaikan lebar layar |
| 2 | Verifikasi grid | - | Grid cards menggunakan space dengan baik |
| 3 | Buka Booking Page | - | Form tidak terlalu lebar, centered |
| 4 | Verifikasi slot visualization | - | Grid slot lebih besar, lebih banyak kolom |
| 5 | Rotate device | Landscape | Layout menyesuaikan orientasi |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Home page tablet portrait
- [ ] Home page tablet landscape
- [ ] Booking page tablet

**Catatan:**
```
Status: _________________
Device: _________________
```

---

### TC-RES-002: Responsive Design - Small Phone

**Deskripsi:** Aplikasi tampil dengan baik di phone kecil

**Prasyarat:**
- Aplikasi running di phone kecil (< 5 inch)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Home Page | - | Semua elemen tampil, tidak terpotong |
| 2 | Verifikasi text | - | Text tidak overflow |
| 3 | Verifikasi buttons | - | Buttons tidak terlalu kecil (min 48x48) |
| 4 | Scroll page | - | Scroll smooth, tidak lag |
| 5 | Buka Booking Page | - | Form fields tidak terlalu kecil |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Home page small phone
- [ ] Booking page small phone

**Catatan:**
```
Status: _________________
Device: _________________
```

---

### TC-ACC-001: Screen Reader Support

**Deskripsi:** Aplikasi dapat digunakan dengan screen reader

**Prasyarat:**
- Screen reader enabled (TalkBack/VoiceOver)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Home Page | - | Screen reader membaca "Home Page" |
| 2 | Swipe ke button | - | Screen reader membaca label button |
| 3 | Tap button | - | Action terjadi, feedback audio |
| 4 | Buka Booking Page | - | Form fields memiliki label jelas |
| 5 | Focus ke input | - | Screen reader membaca label + hint |
| 6 | Verifikasi error | - | Error message dibaca dengan jelas |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
Screen Reader: _________________
```

---

### TC-ACC-002: Keyboard Navigation

**Deskripsi:** Aplikasi dapat dinavigasi dengan keyboard (untuk web/desktop)

**Prasyarat:**
- Aplikasi running di web/desktop

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka Booking Page | - | Form tampil |
| 2 | Press Tab | - | Focus pindah ke field pertama |
| 3 | Press Tab lagi | - | Focus pindah ke field berikutnya |
| 4 | Press Shift+Tab | - | Focus kembali ke field sebelumnya |
| 5 | Press Enter di button | - | Action terjadi |
| 6 | Press Escape di dialog | - | Dialog tutup |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

## 13. FITUR PERFORMANCE

### TC-PERF-001: Loading Time Home Page

**Deskripsi:** Home page load dalam waktu acceptable

**Prasyarat:**
- User sudah login
- Network normal (4G/WiFi)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Start timer | - | Timer mulai |
| 2 | Buka Home Page | - | Loading indicator muncul |
| 3 | Tunggu page load | - | Page fully loaded |
| 4 | Stop timer | - | Timer stop |
| 5 | Verifikasi waktu | - | Load time < 2 detik |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
Load Time: _________ ms
Network: _________________
```

---

### TC-PERF-002: Booking Creation Time

**Deskripsi:** Booking creation selesai dalam waktu acceptable

**Prasyarat:**
- User di Booking Page
- Form sudah terisi

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Start timer | - | Timer mulai |
| 2 | Klik "Konfirmasi Booking" | - | Loading indicator muncul |
| 3 | Tunggu response | - | Success dialog muncul |
| 4 | Stop timer | - | Timer stop |
| 5 | Verifikasi waktu | - | Response time < 3 detik |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
Response Time: _________ ms
```

---

### TC-PERF-003: Memory Usage

**Deskripsi:** Aplikasi tidak memory leak

**Prasyarat:**
- Aplikasi running
- Memory profiler enabled

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Check initial memory | - | Catat memory usage awal |
| 2 | Navigate ke semua page | - | Memory naik saat load |
| 3 | Kembali ke Home | - | Memory turun (garbage collected) |
| 4 | Repeat 10x | - | Memory tidak terus naik |
| 5 | Check final memory | - | Memory usage stabil |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
Initial Memory: _________ MB
Final Memory: _________ MB
```

---


## 14. FITUR ERROR HANDLING

### TC-ERR-001: Network Error Handling

**Deskripsi:** Aplikasi handle network error dengan baik

**Prasyarat:**
- User sudah login

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Matikan internet | - | Internet off |
| 2 | Buka Booking Page | - | Loading indicator muncul |
| 3 | Tunggu timeout | - | Error message: "Tidak ada koneksi internet" |
| 4 | Verifikasi retry button | - | Tombol "Coba Lagi" tersedia |
| 5 | Nyalakan internet | - | Internet on |
| 6 | Klik "Coba Lagi" | - | Data berhasil load |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Error message network
- [ ] Retry button

**Catatan:**
```
Status: _________________
```

---

### TC-ERR-002: Server Error (500) Handling

**Deskripsi:** Aplikasi handle server error dengan baik

**Prasyarat:**
- Backend dapat di-simulate error 500

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Trigger action yang error | - | Loading indicator muncul |
| 2 | Tunggu response | - | Error message: "Terjadi kesalahan server. Silakan coba lagi." |
| 3 | Verifikasi app tidak crash | - | App tetap berjalan normal |
| 4 | Verifikasi retry button | - | Tombol "Coba Lagi" tersedia |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Error message server

**Catatan:**
```
Status: _________________
```

---

### TC-ERR-003: Validation Error Handling

**Deskripsi:** Aplikasi tampilkan validation error dengan jelas

**Prasyarat:**
- User di form input

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Submit form kosong | - | Error message di setiap field |
| 2 | Verifikasi error text | - | Error text berwarna merah, jelas |
| 3 | Isi field dengan benar | - | Error hilang |
| 4 | Isi field dengan format salah | "abc" di field nomor | Error: "Format nomor tidak valid" |
| 5 | Perbaiki input | - | Error hilang |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Validation errors

**Catatan:**
```
Status: _________________
```

---

### TC-ERR-004: Session Expired Handling

**Deskripsi:** Aplikasi handle session expired dengan baik

**Prasyarat:**
- User sudah login
- Token expired (simulate)

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Expire token | - | Token invalid |
| 2 | Lakukan action (booking) | - | Loading indicator muncul |
| 3 | Tunggu response | - | Error: "Sesi Anda telah berakhir" |
| 4 | Verifikasi redirect | - | Auto redirect ke login page |
| 5 | Login ulang | - | Login berhasil |
| 6 | Verifikasi state | - | Kembali ke page sebelumnya |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Session expired message
- [ ] Login page

**Catatan:**
```
Status: _________________
```

---

## 15. INTEGRATION TESTING

### TC-INT-001: End-to-End Booking Flow

**Deskripsi:** Test complete flow dari login sampai booking selesai

**Prasyarat:**
- Fresh install app
- Backend running
- Test account tersedia

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Buka app | - | Login page tampil |
| 2 | Login | Nomor HP + PIN | Home page tampil |
| 3 | Tambah kendaraan | Data kendaraan | Kendaraan tersimpan |
| 4 | Buka Map | - | Peta dengan markers tampil |
| 5 | Pilih mall | "Mega Mall" | Info mall tampil |
| 6 | Klik "Booking Sekarang" | - | Booking page tampil |
| 7 | Isi form booking | Semua field | Form terisi |
| 8 | Pilih slot | "B-015" | Slot reserved |
| 9 | Konfirmasi booking | - | Booking berhasil |
| 10 | Verifikasi QR | - | QR code tampil |
| 11 | Buka Activity | - | Booking tampil di Active |
| 12 | Scan QR exit | - | Booking completed |
| 13 | Verifikasi History | - | Booking di History |
| 14 | Verifikasi Point | - | Point bertambah |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Setiap step (14 screenshots)

**Catatan:**
```
Status: _________________
Total Time: _________ minutes
Issues Found: _________________
```

---

### TC-INT-002: Multiple Bookings Conflict

**Deskripsi:** Test booking conflict ketika 2 user booking slot sama

**Prasyarat:**
- 2 devices/accounts
- Backend running

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | User A: Pilih slot | "A-010" | Slot reserved |
| 2 | User B: Pilih slot yang sama | "A-010" | Error: "Slot sudah direserve" |
| 3 | User A: Konfirmasi booking | - | Booking berhasil |
| 4 | User B: Refresh slot | - | Slot A-010 jadi occupied |
| 5 | User B: Pilih slot lain | "A-011" | Slot reserved |
| 6 | User B: Konfirmasi booking | - | Booking berhasil |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Conflict error
- [ ] Slot status update

**Catatan:**
```
Status: _________________
```

---

### TC-INT-003: Booking with Point Discount

**Deskripsi:** Test complete flow booking dengan point discount

**Prasyarat:**
- User memiliki point cukup
- User di Booking Page

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Verifikasi saldo point awal | - | Catat saldo: 1000 point |
| 2 | Isi form booking | - | Biaya: Rp 20.000 |
| 3 | Gunakan point | 100 point | Diskon: Rp 10.000 |
| 4 | Verifikasi biaya akhir | - | Biaya: Rp 10.000 |
| 5 | Konfirmasi booking | - | Booking berhasil |
| 6 | Verifikasi point history | - | Transaksi "-100 Point" muncul |
| 7 | Verifikasi saldo point | - | Saldo: 900 point |
| 8 | Scan QR exit | - | Booking completed |
| 9 | Verifikasi point earned | - | Transaksi "+50 Point" muncul |
| 10 | Verifikasi saldo akhir | - | Saldo: 950 point |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Screenshot:**
- [ ] Point usage
- [ ] Point history
- [ ] Final balance

**Catatan:**
```
Status: _________________
Initial Balance: _________________
Final Balance: _________________
```

---

## 16. SECURITY TESTING

### TC-SEC-001: SQL Injection Prevention

**Deskripsi:** Test aplikasi tidak vulnerable terhadap SQL injection

**Prasyarat:**
- Backend running

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Login dengan SQL injection | Nomor HP: `' OR '1'='1` | Error: "Invalid credentials" |
| 2 | Search mall dengan SQL | Query: `'; DROP TABLE mall; --` | Error atau no results |
| 3 | Verifikasi database | - | Database tidak terpengaruh |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-SEC-002: XSS Prevention

**Deskripsi:** Test aplikasi tidak vulnerable terhadap XSS

**Prasyarat:**
- User di form input

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Input script tag | `<script>alert('XSS')</script>` | Text di-escape, tidak execute |
| 2 | Verifikasi display | - | Tampil sebagai plain text |
| 3 | Submit form | - | Backend reject atau sanitize |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

### TC-SEC-003: Authentication Token Security

**Deskripsi:** Test token disimpan dengan aman

**Prasyarat:**
- User sudah login

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Login | - | Token tersimpan |
| 2 | Check storage | - | Token di secure storage (encrypted) |
| 3 | Logout | - | Token terhapus |
| 4 | Check storage lagi | - | Token tidak ada |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**Catatan:**
```
Status: _________________
```

---

## 17. BACKEND API TESTING

### TC-API-001: Test POST /api/auth/register

**Deskripsi:** Test endpoint registrasi user

**Prasyarat:**
- Backend running
- Postman/cURL ready

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Send POST request | `{"nama":"Test","nomor_hp":"081234567890","pin":"123456"}` | Status: 200<br>Response: `{"success":true,"message":"OTP telah dikirim"}` |
| 2 | Verifikasi database | - | OTP record tersimpan |
| 3 | Verifikasi email | - | Email OTP terkirim ke Mailtrap |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**cURL Command:**
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nama":"Test User","nomor_hp":"081234567890","pin":"123456"}'
```

**Catatan:**
```
Status: _________________
Response Time: _________ ms
```

---

### TC-API-002: Test POST /api/bookings

**Deskripsi:** Test endpoint create booking

**Prasyarat:**
- Backend running
- Valid auth token
- Postman/cURL ready

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Send POST request | `{"id_parkiran":1,"id_kendaraan":1,"waktu_mulai":"2025-01-07 14:00:00","durasi_booking":2}` | Status: 201<br>Response: `{"success":true,"data":{"id_booking":...}}` |
| 2 | Verifikasi database | - | Booking record tersimpan |
| 3 | Verifikasi slot | - | Slot status jadi "reserved" |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**cURL Command:**
```bash
curl -X POST http://localhost:8000/api/bookings \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"id_parkiran":1,"id_kendaraan":1,"waktu_mulai":"2025-01-07 14:00:00","durasi_booking":2}'
```

**Catatan:**
```
Status: _________________
Response Time: _________ ms
Booking ID: _________________
```

---

### TC-API-003: Test GET /api/parking/floors/{mallId}

**Deskripsi:** Test endpoint get floors

**Prasyarat:**
- Backend running
- Valid auth token

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Send GET request | Mall ID: 1 | Status: 200<br>Response: Array of floors dengan `available_slots` |
| 2 | Verifikasi data | - | Setiap floor memiliki:<br>- id_floor<br>- floor_name<br>- total_slots<br>- available_slots |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**cURL Command:**
```bash
curl -X GET http://localhost:8000/api/parking/floors/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Catatan:**
```
Status: _________________
Response Time: _________ ms
```

---

### TC-API-004: Test GET /api/parking/slots/{floorId}/visualization

**Deskripsi:** Test endpoint get slots untuk visualization

**Prasyarat:**
- Backend running
- Valid auth token

**Langkah Pengujian:**

| No | Aksi | Input | Output yang Diharapkan |
|----|------|-------|------------------------|
| 1 | Send GET request | Floor ID: 1 | Status: 200<br>Response: Array of slots |
| 2 | Verifikasi data | - | Setiap slot memiliki:<br>- id_slot<br>- slot_code<br>- status<br>- position_x<br>- position_y |
| 3 | Verifikasi status | - | Status: available/occupied/reserved/maintenance |

**Output Aktual:** ⬜ Pass / ⬜ Fail

**cURL Command:**
```bash
curl -X GET http://localhost:8000/api/parking/slots/1/visualization \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Catatan:**
```
Status: _________________
Response Time: _________ ms
Total Slots: _________________
```

---

## 📊 SUMMARY & STATISTICS

### Test Case Summary

| Kategori | Jumlah Test Case | Status |
|----------|------------------|--------|
| Autentikasi | 4 | ⬜ |
| Manajemen Kendaraan | 4 | ⬜ |
| Booking Parkir | 5 | ⬜ |
| Slot Reservation | 4 | ⬜ |
| Activity & History | 5 | ⬜ |
| Admin Parkiran | 4 | ⬜ |
| Point System | 6 | ⬜ |
| Notifikasi | 4 | ⬜ |
| Profile & Settings | 4 | ⬜ |
| Map & Navigation | 3 | ⬜ |
| QR Code | 2 | ⬜ |
| Responsiveness & Accessibility | 4 | ⬜ |
| Performance | 3 | ⬜ |
| Error Handling | 4 | ⬜ |
| Integration Testing | 3 | ⬜ |
| Security Testing | 3 | ⬜ |
| Backend API Testing | 4 | ⬜ |
| **TOTAL** | **66** | **⬜** |

---

### Test Execution Checklist

#### Pre-Testing Setup
- [ ] Backend server running (`php artisan serve`)
- [ ] Database migrated dan seeded
- [ ] Mailtrap configured untuk OTP
- [ ] Flutter app compiled (`flutter run`)
- [ ] Test devices ready (phone, tablet)
- [ ] Network connection stable
- [ ] Test accounts created
- [ ] Test data prepared

#### Testing Environment
- [ ] Development environment
- [ ] Staging environment
- [ ] Production environment (UAT)

#### Test Data Required
- [ ] Test user accounts (min 3)
- [ ] Test vehicles (min 2 per user)
- [ ] Test malls (min 3: 2 bertingkat, 1 sederhana)
- [ ] Test parkiran dengan slots
- [ ] Test bookings (active & history)
- [ ] Test point transactions

---

### Bug Tracking Template

**Bug ID:** BUG-XXX  
**Test Case:** TC-XXX-XXX  
**Severity:** Critical / High / Medium / Low  
**Priority:** P0 / P1 / P2 / P3  

**Description:**
```
[Deskripsi bug secara detail]
```

**Steps to Reproduce:**
```
1. [Step 1]
2. [Step 2]
3. [Step 3]
```

**Expected Result:**
```
[Hasil yang diharapkan]
```

**Actual Result:**
```
[Hasil aktual yang terjadi]
```

**Screenshots:**
```
[Attach screenshots]
```

**Environment:**
- Device: [Device name]
- OS: [Android/iOS version]
- App Version: [Version]
- Backend Version: [Version]

**Logs:**
```
[Paste relevant logs]
```

---

### Test Report Template

**Test Report - QParkin Application**

**Date:** [Tanggal Testing]  
**Tester:** [Nama Tester]  
**Environment:** [Development/Staging/Production]  
**App Version:** [Version]  
**Backend Version:** [Version]

#### Executive Summary
- Total Test Cases: 66
- Passed: ___
- Failed: ___
- Blocked: ___
- Not Executed: ___
- Pass Rate: ____%

#### Test Results by Category

| Kategori | Total | Pass | Fail | Pass Rate |
|----------|-------|------|------|-----------|
| Autentikasi | 4 | ___ | ___ | ___% |
| Manajemen Kendaraan | 4 | ___ | ___ | ___% |
| Booking Parkir | 5 | ___ | ___ | ___% |
| Slot Reservation | 4 | ___ | ___ | ___% |
| Activity & History | 5 | ___ | ___ | ___% |
| Admin Parkiran | 4 | ___ | ___ | ___% |
| Point System | 6 | ___ | ___ | ___% |
| Notifikasi | 4 | ___ | ___ | ___% |
| Profile & Settings | 4 | ___ | ___ | ___% |
| Map & Navigation | 3 | ___ | ___ | ___% |
| QR Code | 2 | ___ | ___ | ___% |
| Responsiveness | 4 | ___ | ___ | ___% |
| Performance | 3 | ___ | ___ | ___% |
| Error Handling | 4 | ___ | ___ | ___% |
| Integration | 3 | ___ | ___ | ___% |
| Security | 3 | ___ | ___ | ___% |
| Backend API | 4 | ___ | ___ | ___% |

#### Critical Issues Found
1. [Issue 1]
2. [Issue 2]
3. [Issue 3]

#### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

#### Sign-off
- Tester: _________________ Date: _________
- QA Lead: _________________ Date: _________
- Project Manager: _________________ Date: _________

---

## 📝 NOTES FOR TESTERS

### Testing Best Practices

1. **Test Systematically**
   - Follow test cases in order
   - Don't skip steps
   - Document everything

2. **Use Real Data**
   - Use realistic test data
   - Test with various scenarios
   - Include edge cases

3. **Document Issues**
   - Take screenshots
   - Copy error messages
   - Note reproduction steps

4. **Test on Multiple Devices**
   - Different screen sizes
   - Different OS versions
   - Different network conditions

5. **Verify Data Persistence**
   - Check database after actions
   - Verify data consistency
   - Test data integrity

### Common Issues to Watch For

- ❌ UI elements overlapping
- ❌ Text overflow
- ❌ Buttons too small
- ❌ Slow loading times
- ❌ Memory leaks
- ❌ Network errors not handled
- ❌ Validation errors unclear
- ❌ Data not persisting
- ❌ Inconsistent behavior
- ❌ Accessibility issues

### Quick Commands Reference

**Flutter:**
```bash
# Run app
flutter run --dart-define=API_URL=http://192.168.x.xx:8000

# Run tests
flutter test

# Analyze code
flutter analyze

# Build APK
flutter build apk --release
```

**Laravel:**
```bash
# Start server
php artisan serve

# Run migrations
php artisan migrate

# Seed database
php artisan db:seed

# Run tests
php artisan test

# Clear cache
php artisan config:clear
```

---

## ✅ CONCLUSION

Dokumen test case ini mencakup **66 test case** yang komprehensif untuk aplikasi QParkin, meliputi:

- ✅ Semua fitur utama (Auth, Booking, Slot, Activity, Admin, Point, dll)
- ✅ Integration testing end-to-end
- ✅ Performance testing
- ✅ Security testing
- ✅ Accessibility testing
- ✅ Backend API testing

**Siap digunakan untuk:**
- Testing manual oleh QA team
- User Acceptance Testing (UAT)
- Regression testing
- Dokumentasi untuk presentasi/laporan

**Format:**
- Tabel yang rapi dan mudah dibaca
- Checkbox untuk tracking status
- Space untuk screenshot dan catatan
- Template bug report dan test report

---

**Prepared by:** Kiro AI Assistant  
**Date:** 6 Januari 2025  
**Version:** 1.0  
**Status:** ✅ Ready for Use

