# 📧 Panduan Testing OTP via Mailtrap

## 🎯 Apa itu Mailtrap?

Mailtrap adalah layanan email testing yang menangkap email yang dikirim dari aplikasi development tanpa benar-benar mengirimkannya ke penerima. Sempurna untuk testing OTP!

---

## 🔑 Akses Mailtrap

### 1. Login ke Mailtrap
- URL: https://mailtrap.io
- Gunakan akun yang sudah dikonfigurasi di `.env`

### 2. Navigasi ke Inbox
```
Dashboard → Email Testing → Inboxes → [Your Inbox]
```

---

## 📬 Melihat Email OTP

### Setelah Register di QParkin:

1. **Refresh Inbox**
   - Klik tombol refresh atau tekan F5
   - Email baru akan muncul dalam beberapa detik

2. **Identifikasi Email OTP**
   - **From:** QParkin System <no-reply@qparkin.test>
   - **To:** {nomor_hp}@qparkin.test (contoh: 081234567890@qparkin.test)
   - **Subject:** Kode OTP Registrasi QParkin
   - **Time:** Baru saja (just now)

3. **Buka Email**
   - Klik pada email untuk membuka
   - Lihat preview HTML atau Text

---

## 🔍 Isi Email OTP

### Header
```
🅿️ QParkin
```

### Body
```
Halo, [Nama User]!

Terima kasih telah mendaftar di QParkin. Untuk menyelesaikan 
proses registrasi, silakan gunakan kode OTP berikut:

┌─────────────────────┐
│   Kode OTP Anda:    │
│                     │
│      123456         │  ← SALIN KODE INI
│                     │
└─────────────────────┘

📱 Nomor HP: 081234567890
⏰ Berlaku selama: 5 menit

⚠️ Perhatian:
• Jangan bagikan kode OTP ini kepada siapapun
• Kode ini hanya berlaku untuk 1 kali verifikasi
• Kode akan kedaluwarsa dalam 5 menit

Jika Anda tidak melakukan registrasi, abaikan email ini.
```

### Footer
```
Email ini dikirim secara otomatis, mohon tidak membalas.
© 2025 QParkin. All rights reserved.
```

---

## 📋 Langkah Testing

### Skenario 1: Testing Normal Flow

1. **Register di App**
   ```
   Nama: Test User
   Nomor HP: 081234567890
   PIN: 123456
   ```

2. **Cek Mailtrap**
   - Buka inbox
   - Cari email terbaru
   - To: `081234567890@qparkin.test`

3. **Salin OTP**
   - Kode OTP: `123456` (contoh)
   - Salin 6 digit angka

4. **Input di App**
   - Paste atau ketik di dialog OTP
   - Klik "Verifikasi"

5. **Verifikasi Sukses**
   - Dialog tertutup
   - Redirect ke login

---

### Skenario 2: Testing Resend OTP

1. **Tunggu Countdown Habis**
   - Timer: 00:00

2. **Klik "Kirim Ulang"**
   - Loading muncul
   - Timer reset ke 05:00

3. **Cek Mailtrap**
   - Email baru masuk
   - Kode OTP berbeda dari sebelumnya

4. **Gunakan OTP Baru**
   - OTP lama tidak bisa digunakan
   - OTP baru valid

---

### Skenario 3: Testing Multiple Users

1. **Register User 1**
   - HP: 081234567890
   - Email di Mailtrap: `081234567890@qparkin.test`

2. **Register User 2**
   - HP: 082345678901
   - Email di Mailtrap: `082345678901@qparkin.test`

3. **Cek Inbox**
   - 2 email berbeda
   - Masing-masing dengan OTP unik

---

## 🔍 Fitur Mailtrap yang Berguna

### 1. HTML & Text Preview
- **HTML Tab:** Lihat email dengan styling lengkap
- **Text Tab:** Lihat versi plain text
- **Raw Tab:** Lihat source email

### 2. Email Details
- **Headers:** Lihat semua header email
- **Spam Analysis:** Cek spam score (harus 0)
- **Validation:** Cek validasi HTML/CSS

### 3. Search & Filter
- Search by: From, To, Subject
- Filter by: Date, Status
- Sort by: Newest, Oldest

### 4. Forward Email
- Forward ke email real untuk testing
- Berguna untuk testing di device lain

---

## 🐛 Troubleshooting

### Email tidak masuk ke Mailtrap

#### Cek 1: Kredensial .env
```bash
# Buka .env
cat qparkin_backend/.env | grep MAIL

# Pastikan:
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=22aadad370a1c9
MAIL_PASSWORD=****4ddd
```

#### Cek 2: Test Koneksi
```bash
php artisan tinker

# Di tinker:
Mail::raw('Test email', function($msg) {
    $msg->to('test@qparkin.test')->subject('Test');
});

# Cek Mailtrap, email harus masuk
```

#### Cek 3: Log Laravel
```bash
tail -f storage/logs/laravel.log

# Cari error terkait mail
```

#### Cek 4: Queue
```bash
# Jika menggunakan queue
php artisan queue:work

# Atau cek failed jobs
php artisan queue:failed
```

---

### Email masuk tapi OTP tidak terlihat

#### Solusi 1: Cek HTML Preview
- Klik tab "HTML" di Mailtrap
- Scroll ke bagian kode OTP
- Kode harus terlihat jelas

#### Solusi 2: Cek Text Preview
- Klik tab "Text"
- Cari "Kode OTP Anda:"
- Kode harus ada di bawahnya

#### Solusi 3: Cek Raw Email
- Klik tab "Raw"
- Search (Ctrl+F): "otp_code"
- Lihat value-nya

---

### Email masuk terlambat

#### Penyebab:
- Koneksi internet lambat
- Server Mailtrap sedang sibuk
- Queue Laravel belum diproses

#### Solusi:
- Tunggu 10-30 detik
- Refresh inbox
- Cek queue: `php artisan queue:work`

---

## 📊 Monitoring Email

### Statistik yang Bisa Dilihat:

1. **Delivery Rate**
   - Berapa email yang berhasil dikirim
   - Harus 100% untuk development

2. **Response Time**
   - Waktu dari kirim sampai terima
   - Biasanya < 5 detik

3. **Email Size**
   - Ukuran email (KB)
   - Email OTP biasanya < 10 KB

4. **Spam Score**
   - Score spam (harus 0)
   - Jika > 0, perbaiki template

---

## 🎨 Tampilan Email di Mailtrap

### Desktop View
```
┌─────────────────────────────────────────┐
│  From: QParkin System                   │
│  To: 081234567890@qparkin.test          │
│  Subject: Kode OTP Registrasi QParkin   │
├─────────────────────────────────────────┤
│                                         │
│  [Purple Header with Logo]              │
│                                         │
│  Halo, Test User!                       │
│                                         │
│  [OTP Box with Code: 123456]            │
│                                         │
│  [Info Box: HP & Waktu]                 │
│                                         │
│  [Warning Box: Keamanan]                │
│                                         │
│  [Footer]                               │
│                                         │
└─────────────────────────────────────────┘
```

### Mobile View
- Responsive design
- Tetap terbaca di layar kecil
- OTP code tetap besar dan jelas

---

## ✅ Checklist Mailtrap

Sebelum testing, pastikan:

- [ ] Sudah login ke Mailtrap
- [ ] Inbox sudah dipilih
- [ ] Kredensial di `.env` benar
- [ ] Server Laravel berjalan
- [ ] Koneksi internet stabil

Saat testing:

- [ ] Email masuk dalam < 10 detik
- [ ] Subject benar: "Kode OTP Registrasi QParkin"
- [ ] To address benar: `{nomor_hp}@qparkin.test`
- [ ] OTP code terlihat jelas (6 digit)
- [ ] HTML rendering sempurna
- [ ] Tidak ada error di log

---

## 🔗 Link Berguna

- **Mailtrap Dashboard:** https://mailtrap.io/inboxes
- **Mailtrap Docs:** https://help.mailtrap.io/
- **Laravel Mail Docs:** https://laravel.com/docs/mail

---

## 💡 Tips Pro

1. **Bookmark Inbox**
   - Simpan URL inbox untuk akses cepat

2. **Auto-Refresh**
   - Gunakan browser extension untuk auto-refresh
   - Atau tekan F5 setiap beberapa detik

3. **Multiple Tabs**
   - Buka Mailtrap di tab terpisah
   - Buka app di tab lain
   - Mudah switch untuk salin OTP

4. **Copy OTP Cepat**
   - Double-click pada kode OTP
   - Atau gunakan Ctrl+C setelah select

5. **Testing Batch**
   - Test multiple user sekaligus
   - Semua email akan masuk ke inbox
   - Mudah dibedakan dari "To" address

---

**Happy Testing! 🚀**

Jika ada pertanyaan atau masalah, cek dokumentasi lengkap di:
- `OTP_REGISTRATION_IMPLEMENTATION.md`
- `OTP_QUICK_START.md`
- `OTP_CHECKLIST.md`
