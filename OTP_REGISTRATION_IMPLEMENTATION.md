# 🔐 Implementasi OTP Registrasi QParkin

## 📋 Ringkasan Implementasi

Sistem OTP (One-Time Password) telah diimplementasikan untuk verifikasi registrasi user baru di aplikasi QParkin. OTP dikirim via email Mailtrap sebagai simulasi pengiriman SMS.

---

## 🎯 Alur OTP Lengkap

### 1️⃣ **User Submit Form Registrasi**
```
Input: Nama, Nomor HP, PIN 6 digit
↓
POST /api/auth/register
```

### 2️⃣ **Backend Generate & Kirim OTP**
```
✓ Validasi input (nama, nomor_hp, pin)
✓ Cek nomor HP belum terdaftar
✓ Generate OTP 6 digit random
✓ Simpan OTP ke database (berlaku 5 menit)
✓ Simpan data registrasi ke cache (berlaku 10 menit)
✓ Kirim OTP via email Mailtrap
  → Email: {nomor_hp}@qparkin.test
  → Subject: Kode OTP Registrasi QParkin
✓ Return success + nomor_hp
```

### 3️⃣ **Frontend Tampilkan Dialog OTP**
```
✓ Popup dialog dengan 6 input field
✓ Countdown timer 5 menit
✓ Auto-focus ke field berikutnya
✓ Auto-verify saat 6 digit terisi
✓ Tombol "Kirim Ulang" (aktif setelah countdown habis)
```

### 4️⃣ **User Input OTP**
```
Input: 6 digit OTP
↓
POST /api/auth/verify-otp
```

### 5️⃣ **Backend Verifikasi OTP**
```
✓ Cari OTP di database berdasarkan nomor_hp
✓ Validasi:
  - OTP belum digunakan
  - OTP belum kedaluwarsa
  - Kode OTP cocok
✓ Ambil data registrasi dari cache
✓ Buat user baru dengan status 'aktif'
✓ Tandai OTP sebagai terverifikasi
✓ Hapus cache data registrasi
✓ Return success
```

### 6️⃣ **Frontend Redirect ke Login**
```
✓ Tutup dialog OTP
✓ Tampilkan pesan sukses
✓ Navigasi ke halaman login
```

---

## 📁 File yang Dibuat/Dimodifikasi

### Backend (Laravel)

#### ✅ **File Baru:**
1. **Migration:** `qparkin_backend/database/migrations/2025_01_05_000000_create_otp_verifications_table.php`
   - Tabel untuk menyimpan OTP sementara
   - Kolom: `nomor_hp`, `otp_code`, `expires_at`, `is_verified`

2. **Model:** `qparkin_backend/app/Models/OtpVerification.php`
   - Method: `isExpired()`, `isValid()`

3. **Mailable:** `qparkin_backend/app/Mail/OtpMail.php`
   - Class untuk mengirim email OTP

4. **View:** `qparkin_backend/resources/views/emails/otp.blade.php`
   - Template email OTP dengan desain profesional

#### ✅ **File Dimodifikasi:**
1. **Controller:** `qparkin_backend/app/Http/Controllers/Auth/ApiAuthController.php`
   - Method baru: `register()` - Generate & kirim OTP
   - Method baru: `verifyOtp()` - Verifikasi OTP & buat user
   - Method baru: `resendOtp()` - Kirim ulang OTP

2. **Routes:** `qparkin_backend/routes/api.php`
   - `POST /api/auth/register` - Kirim OTP
   - `POST /api/auth/verify-otp` - Verifikasi OTP
   - `POST /api/auth/resend-otp` - Kirim ulang OTP

### Frontend (Flutter)

#### ✅ **File Baru:**
1. **Dialog:** `qparkin_app/lib/presentation/dialogs/otp_verification_dialog.dart`
   - UI popup input OTP 6 digit
   - Countdown timer 5 menit
   - Auto-focus & auto-verify
   - Tombol kirim ulang

#### ✅ **File Dimodifikasi:**
1. **Service:** `qparkin_app/lib/data/services/auth_service.dart`
   - Method: `register()` - Panggil API register (kirim OTP)
   - Method: `verifyOtp()` - Panggil API verify-otp
   - Method: `resendOtp()` - Panggil API resend-otp

2. **Screen:** `qparkin_app/lib/presentation/screens/signup_screen.dart`
   - Update `_handleSignUp()` untuk tampilkan dialog OTP
   - Integrasi dengan `OtpVerificationDialog`

---

## 🔧 Konfigurasi Backend

### 1. Jalankan Migration
```bash
cd qparkin_backend
php artisan migrate
```

### 2. Cek Konfigurasi Mailtrap (.env)
```env
MAIL_MAILER=smtp
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=22aadad370a1c9
MAIL_PASSWORD=****4ddd
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=no-reply@qparkin.test
MAIL_FROM_NAME="QParkin System"
```

### 3. Clear Cache (Opsional)
```bash
php artisan config:clear
php artisan cache:clear
```

---

## 🧪 Cara Testing OTP

### **A. Testing Backend (Manual via Postman/cURL)**

#### 1️⃣ **Register (Kirim OTP)**
```bash
POST http://localhost:8000/api/auth/register
Content-Type: application/json

{
  "nama": "John Doe",
  "nomor_hp": "081234567890",
  "pin": "123456"
}
```

**Response Sukses:**
```json
{
  "success": true,
  "message": "OTP telah dikirim. Silakan cek email Mailtrap.",
  "nomor_hp": "081234567890",
  "debug_email": "081234567890@qparkin.test"
}
```

#### 2️⃣ **Cek Email di Mailtrap**
- Login ke https://mailtrap.io
- Buka inbox Anda
- Cari email dengan subject: **"Kode OTP Registrasi QParkin"**
- Salin kode OTP 6 digit (contoh: `123456`)

#### 3️⃣ **Verify OTP**
```bash
POST http://localhost:8000/api/auth/verify-otp
Content-Type: application/json

{
  "nomor_hp": "081234567890",
  "otp_code": "123456"
}
```

**Response Sukses:**
```json
{
  "success": true,
  "message": "Verifikasi berhasil! Akun Anda telah aktif.",
  "user": {
    "id_user": 1,
    "name": "John Doe",
    "nomor_hp": "081234567890"
  }
}
```

#### 4️⃣ **Resend OTP (Opsional)**
```bash
POST http://localhost:8000/api/auth/resend-otp
Content-Type: application/json

{
  "nomor_hp": "081234567890"
}
```

---

### **B. Testing Frontend (Flutter App)**

#### 1️⃣ **Jalankan Backend**
```bash
cd qparkin_backend
php artisan serve
```

#### 2️⃣ **Jalankan Flutter App**
```bash
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```
*Ganti `192.168.1.100` dengan IP lokal Anda*

#### 3️⃣ **Test Flow:**
1. Buka aplikasi → Klik "Sign Up"
2. Isi form:
   - Nama: `Test User`
   - Nomor HP: `081234567890`
   - PIN: `123456`
3. Klik tombol "Sign Up"
4. **Dialog OTP muncul** dengan:
   - 6 input field
   - Countdown timer 5:00
   - Info nomor HP
5. Buka Mailtrap → Salin kode OTP
6. Input OTP di dialog
7. Klik "Verifikasi" atau tunggu auto-verify
8. **Sukses:** Redirect ke halaman login

---

## 🎨 Fitur Dialog OTP

### ✨ **UI/UX Features:**
- ✅ 6 input field terpisah untuk setiap digit
- ✅ Auto-focus ke field berikutnya saat input
- ✅ Auto-backspace ke field sebelumnya saat hapus
- ✅ Auto-verify saat 6 digit terisi lengkap
- ✅ Countdown timer 5 menit (format MM:SS)
- ✅ Warna timer berubah merah saat < 1 menit
- ✅ Tombol "Kirim Ulang" aktif setelah countdown habis
- ✅ Loading indicator saat verifikasi
- ✅ Desain modern dengan gradient purple

### 🔒 **Security Features:**
- ✅ OTP hanya berlaku 5 menit
- ✅ OTP hanya bisa digunakan 1 kali
- ✅ Data registrasi di-cache 10 menit (auto-expire)
- ✅ OTP lama dihapus saat generate OTP baru
- ✅ Validasi ketat di backend

---

## 📧 Format Email OTP

Email yang dikirim ke Mailtrap memiliki:
- **Subject:** Kode OTP Registrasi QParkin
- **To:** `{nomor_hp}@qparkin.test` (contoh: `081234567890@qparkin.test`)
- **Content:**
  - Header dengan logo QParkin
  - Greeting dengan nama user
  - Kode OTP dalam box besar (font monospace)
  - Info nomor HP dan waktu berlaku
  - Warning keamanan
  - Footer profesional

---

## 🐛 Troubleshooting

### **1. Email tidak terkirim**
**Solusi:**
```bash
# Cek konfigurasi .env
cat qparkin_backend/.env | grep MAIL

# Test koneksi SMTP
php artisan tinker
Mail::raw('Test email', function($msg) {
    $msg->to('test@qparkin.test')->subject('Test');
});
```

### **2. OTP kedaluwarsa terlalu cepat**
**Solusi:** Edit `ApiAuthController.php`
```php
// Ubah dari 5 menit ke 10 menit
'expires_at' => now()->addMinutes(10),
```

### **3. Dialog OTP tidak muncul**
**Solusi:**
- Cek response API di debug console
- Pastikan `result['success'] == true`
- Cek import `otp_verification_dialog.dart`

### **4. Error "Data registrasi tidak ditemukan"**
**Solusi:**
- Cache mungkin sudah expire (10 menit)
- User harus registrasi ulang
- Atau tingkatkan durasi cache:
```php
cache()->put('register_data_' . $request->nomor_hp, $data, now()->addMinutes(20));
```

---

## 📊 Database Schema

### **Tabel: otp_verifications**
```sql
CREATE TABLE otp_verifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nomor_hp VARCHAR(20) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_nomor_hp (nomor_hp)
);
```

---

## ✅ Checklist Implementasi

### Backend:
- [x] Migration tabel `otp_verifications`
- [x] Model `OtpVerification`
- [x] Mailable `OtpMail`
- [x] View email `otp.blade.php`
- [x] Controller method `register()` - Generate OTP
- [x] Controller method `verifyOtp()` - Verifikasi
- [x] Controller method `resendOtp()` - Kirim ulang
- [x] Routes API `/auth/register`, `/auth/verify-otp`, `/auth/resend-otp`
- [x] Konfigurasi Mailtrap di `.env`

### Frontend:
- [x] Dialog `OtpVerificationDialog`
- [x] Service method `register()` - Panggil API
- [x] Service method `verifyOtp()` - Verifikasi
- [x] Service method `resendOtp()` - Kirim ulang
- [x] Update `signup_screen.dart` - Integrasi dialog
- [x] UI countdown timer
- [x] UI auto-focus & auto-verify
- [x] Error handling

---

## 🚀 Next Steps (Opsional)

1. **Rate Limiting:** Batasi request OTP (max 3x per 10 menit)
2. **SMS Gateway:** Ganti Mailtrap dengan SMS gateway real (Twilio, Vonage)
3. **Analytics:** Track success rate verifikasi OTP
4. **Testing:** Unit test & integration test
5. **Logging:** Log semua aktivitas OTP untuk audit

---

## 📝 Catatan Penting

⚠️ **Email hanya simulasi!**
- Email tidak diinput oleh user
- Email dummy: `{nomor_hp}@qparkin.test`
- Hanya untuk development/testing via Mailtrap
- Untuk production, ganti dengan SMS Gateway

⚠️ **Keamanan:**
- Jangan commit kredensial Mailtrap ke Git
- Gunakan `.env` untuk konfigurasi sensitif
- Implementasikan rate limiting di production

⚠️ **Performance:**
- Cache Laravel digunakan untuk data registrasi sementara
- OTP lama otomatis dihapus saat generate baru
- Cleanup expired OTP bisa dijadwalkan via cron job

---

**Implementasi selesai! ✅**
OTP registrasi sudah berfungsi penuh dari frontend hingga backend.
