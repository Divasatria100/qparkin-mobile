# 🚀 Quick Start: OTP Registrasi QParkin

## ⚡ Setup Cepat (5 Menit)

### 1️⃣ Backend Setup
```bash
cd qparkin_backend

# Jalankan migration
php artisan migrate

# Start server
php artisan serve
```

### 2️⃣ Frontend Setup
```bash
cd qparkin_app

# Jalankan app (ganti IP dengan IP lokal Anda)
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

---

## 🧪 Testing Manual (3 Langkah)

### **Langkah 1: Register**
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nama":"Test User","nomor_hp":"081234567890","pin":"123456"}'
```

### **Langkah 2: Cek Mailtrap**
- Login ke https://mailtrap.io
- Buka inbox → Cari email "Kode OTP Registrasi QParkin"
- Salin kode OTP (contoh: `123456`)

### **Langkah 3: Verify OTP**
```bash
curl -X POST http://localhost:8000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"nomor_hp":"081234567890","otp_code":"123456"}'
```

✅ **Sukses!** User sudah terdaftar dan bisa login.

---

## 📱 Testing di Flutter App

1. Buka app → Klik "Sign Up"
2. Isi form (Nama, Nomor HP, PIN)
3. Klik "Sign Up"
4. **Dialog OTP muncul**
5. Buka Mailtrap → Salin OTP
6. Input OTP di dialog
7. **Sukses!** Redirect ke login

---

## 🎯 Alur Singkat

```
User Register → Backend Generate OTP → Kirim ke Mailtrap
                                     ↓
User Input OTP ← Dialog OTP Muncul ←┘
       ↓
Backend Verify → Buat User → Redirect ke Login
```

---

## 📧 Email Format

- **To:** `{nomor_hp}@qparkin.test`
- **Subject:** Kode OTP Registrasi QParkin
- **Berlaku:** 5 menit
- **Hanya 1x pakai**

---

## 🔧 Troubleshooting Cepat

| Masalah | Solusi |
|---------|--------|
| Email tidak masuk | Cek `.env` → `MAIL_HOST`, `MAIL_USERNAME`, `MAIL_PASSWORD` |
| OTP kedaluwarsa | Ubah `addMinutes(5)` → `addMinutes(10)` di `ApiAuthController.php` |
| Dialog tidak muncul | Cek `result['success']` di debug console |
| Cache error | `php artisan cache:clear` |

---

## 📝 API Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Kirim OTP |
| POST | `/api/auth/verify-otp` | Verifikasi OTP |
| POST | `/api/auth/resend-otp` | Kirim ulang OTP |

---

**Dokumentasi lengkap:** Lihat `OTP_REGISTRATION_IMPLEMENTATION.md`
