# ✅ Checklist Implementasi OTP QParkin

## 📋 Sebelum Testing

### Backend Setup
- [ ] Migration sudah dijalankan: `php artisan migrate`
- [ ] File `.env` sudah dikonfigurasi Mailtrap:
  ```
  MAIL_HOST=sandbox.smtp.mailtrap.io
  MAIL_PORT=2525
  MAIL_USERNAME=22aadad370a1c9
  MAIL_PASSWORD=****4ddd
  ```
- [ ] Server Laravel berjalan: `php artisan serve`
- [ ] Bisa akses: http://localhost:8000/api/health

### Frontend Setup
- [ ] Dependencies sudah terinstall: `flutter pub get`
- [ ] API_URL sudah dikonfigurasi dengan IP lokal
- [ ] App bisa dijalankan: `flutter run --dart-define=API_URL=http://192.168.1.100:8000`

### Mailtrap Setup
- [ ] Sudah punya akun Mailtrap: https://mailtrap.io
- [ ] Sudah login dan bisa akses inbox
- [ ] Kredensial Mailtrap sudah benar di `.env`

---

## 🧪 Testing Checklist

### Test 1: Backend API (Manual)
- [ ] Test register endpoint:
  ```bash
  curl -X POST http://localhost:8000/api/auth/register \
    -H "Content-Type: application/json" \
    -d '{"nama":"Test User","nomor_hp":"081234567890","pin":"123456"}'
  ```
- [ ] Response sukses: `{"success":true,"message":"OTP telah dikirim..."}`
- [ ] Email masuk ke Mailtrap inbox
- [ ] Email berisi kode OTP 6 digit
- [ ] Test verify-otp endpoint dengan OTP dari email
- [ ] Response sukses: `{"success":true,"message":"Verifikasi berhasil..."}`
- [ ] User baru muncul di database tabel `user`

### Test 2: Backend API (Script)
- [ ] Jalankan: `test-otp-registration.bat`
- [ ] Script berjalan tanpa error
- [ ] Email masuk ke Mailtrap
- [ ] Input OTP dari email
- [ ] Verifikasi berhasil

### Test 3: Resend OTP
- [ ] Jalankan: `test-otp-resend.bat`
- [ ] Email OTP baru masuk ke Mailtrap
- [ ] OTP lama tidak bisa digunakan
- [ ] OTP baru bisa digunakan untuk verifikasi

### Test 4: Flutter App (Full Flow)
- [ ] Buka app → Klik "Sign Up"
- [ ] Isi form:
  - Nama: `Test User`
  - Nomor HP: `081234567890`
  - PIN: `123456`
- [ ] Klik tombol "Sign Up"
- [ ] Loading indicator muncul
- [ ] Dialog OTP muncul dengan:
  - [ ] 6 input field
  - [ ] Countdown timer (05:00)
  - [ ] Info nomor HP
- [ ] Buka Mailtrap → Email masuk
- [ ] Salin kode OTP dari email
- [ ] Input OTP di dialog (auto-focus bekerja)
- [ ] Klik "Verifikasi" atau tunggu auto-verify
- [ ] Loading indicator muncul
- [ ] Dialog tertutup
- [ ] Snackbar sukses muncul
- [ ] Redirect ke halaman login
- [ ] Bisa login dengan nomor HP & PIN yang tadi didaftarkan

### Test 5: Error Scenarios
- [ ] Test nomor HP sudah terdaftar:
  - [ ] Daftar dengan nomor HP yang sama 2x
  - [ ] Error: "Nomor HP sudah terdaftar"
- [ ] Test OTP salah:
  - [ ] Input OTP yang salah
  - [ ] Error: "Kode OTP salah"
- [ ] Test OTP kedaluwarsa:
  - [ ] Tunggu > 5 menit
  - [ ] Input OTP
  - [ ] Error: "Kode OTP sudah kedaluwarsa"
- [ ] Test resend OTP:
  - [ ] Tunggu countdown habis (00:00)
  - [ ] Klik "Kirim Ulang"
  - [ ] Timer reset ke 05:00
  - [ ] Email baru masuk ke Mailtrap

---

## 🔍 Verification Checklist

### Database
- [ ] Tabel `otp_verifications` ada di database
- [ ] Struktur tabel benar (nomor_hp, otp_code, expires_at, is_verified)
- [ ] OTP tersimpan saat register
- [ ] OTP ter-update `is_verified=1` setelah verifikasi
- [ ] User baru muncul di tabel `user` setelah verifikasi

### Email
- [ ] Email masuk ke Mailtrap inbox
- [ ] Subject: "Kode OTP Registrasi QParkin"
- [ ] To: `{nomor_hp}@qparkin.test`
- [ ] Body berisi:
  - [ ] Nama user
  - [ ] Kode OTP 6 digit
  - [ ] Nomor HP
  - [ ] Info berlaku 5 menit
  - [ ] Warning keamanan

### Frontend
- [ ] Dialog OTP tampil dengan benar
- [ ] 6 input field terpisah
- [ ] Auto-focus bekerja
- [ ] Auto-verify saat 6 digit terisi
- [ ] Countdown timer berjalan
- [ ] Timer berubah merah saat < 1 menit
- [ ] Tombol "Kirim Ulang" disabled saat countdown > 0
- [ ] Tombol "Kirim Ulang" enabled saat countdown = 0
- [ ] Loading indicator muncul saat proses
- [ ] Error handling bekerja (snackbar)

---

## 🐛 Troubleshooting Checklist

### Email tidak masuk
- [ ] Cek koneksi internet
- [ ] Cek kredensial Mailtrap di `.env`
- [ ] Cek log Laravel: `storage/logs/laravel.log`
- [ ] Test koneksi SMTP:
  ```bash
  php artisan tinker
  Mail::raw('Test', function($msg) {
      $msg->to('test@qparkin.test')->subject('Test');
  });
  ```

### Dialog OTP tidak muncul
- [ ] Cek response API di debug console
- [ ] Pastikan `result['success'] == true`
- [ ] Cek import `otp_verification_dialog.dart`
- [ ] Cek error di Flutter console

### OTP tidak valid
- [ ] Cek OTP di database: `SELECT * FROM otp_verifications ORDER BY created_at DESC LIMIT 1`
- [ ] Pastikan OTP belum expire
- [ ] Pastikan `is_verified = 0`
- [ ] Pastikan kode OTP cocok

### Cache error
- [ ] Clear cache: `php artisan cache:clear`
- [ ] Clear config: `php artisan config:clear`
- [ ] Restart server

---

## 📊 Final Verification

- [ ] **Backend:** 3 endpoint berfungsi (register, verify-otp, resend-otp)
- [ ] **Frontend:** Dialog OTP tampil dan berfungsi
- [ ] **Email:** Mailtrap menerima email OTP
- [ ] **Database:** OTP tersimpan dan user terbuat setelah verifikasi
- [ ] **Security:** OTP expire 5 menit, 1x pakai
- [ ] **UX:** Auto-focus, auto-verify, countdown timer bekerja
- [ ] **Error Handling:** Semua error scenario tertangani
- [ ] **Documentation:** Semua dokumentasi tersedia

---

## ✅ Sign-off

Jika semua checklist di atas sudah ✅, maka:

**🎉 IMPLEMENTASI OTP REGISTRASI QPARKIN SELESAI DAN BERFUNGSI!**

---

**Catatan:**
- Simpan checklist ini untuk referensi testing
- Gunakan untuk QA sebelum deployment
- Update checklist jika ada perubahan fitur

**Dokumentasi Terkait:**
- `OTP_REGISTRATION_IMPLEMENTATION.md` - Detail lengkap
- `OTP_QUICK_START.md` - Panduan cepat
- `OTP_FLOW_DIAGRAM.txt` - Diagram visual
- `RINGKASAN_OTP_IMPLEMENTASI.md` - Ringkasan bahasa Indonesia
