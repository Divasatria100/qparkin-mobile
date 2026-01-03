# ANALISIS KEAMANAN DAN RENCANA AUDITING SISTEM QPARKIN

## EXECUTIVE SUMMARY

Dokumen ini menyajikan analisis komprehensif terhadap aspek keamanan aplikasi Qparkin Mobile dan Backend, mengidentifikasi komponen kritis yang memerlukan auditing, serta menyusun rencana pengamanan API yang sesuai dengan kondisi sistem saat ini.

**Tanggal Analisis:** 14 Desember 2025  
**Versi Aplikasi:** Mobile v1.0 (Flutter), Backend v1.0 (Laravel)  
**Lingkup:** Keamanan Data, API Security, Database Integrity

---

## 1. IDENTIFIKASI KOMPONEN KEAMANAN

### 1.1 Autentikasi dan Otorisasi Pengguna

#### A. Mekanisme Autentikasi Saat Ini

**Komponen Frontend (Mobile):**
- **Lokasi:** `lib/data/services/auth_service.dart`
- **Metode:** PIN 6 digit + Nomor HP
- **Storage:** Flutter Secure Storage untuk token dan data user
- **Endpoint:** 
  - Login: `/api/auth/login`
  - Register: `/api/auth/register`

**Implementasi:**
```dart
- Token disimpan di secure storage dengan key 'auth_token'
- User data disimpan terenkripsi dengan key 'user_data'
- Remember Me feature menyimpan nomor HP
- Timeout: 30 detik per request
```

**Temuan Keamanan:**

1. ✅ **Positif:** Menggunakan Flutter Secure Storage untuk penyimpanan token
2. ✅ **Positif:** Implementasi timeout untuk mencegah hanging requests
3. ⚠️ **Risiko:** PIN 6 digit memberikan 1 juta kombinasi (relatif lemah untuk production)
4. ⚠️ **Risiko:** Tidak ada implementasi rate limiting di client side
5. ⚠️ **Risiko:** Tidak ada mekanisme token refresh yang terlihat
6. ❌ **Kritis:** API_URL dikonfigurasi via environment variable tanpa validasi SSL pinning

#### B. Role-Based Access Control (RBAC)

**Peran Pengguna:**
- **Customer/Driver:** Akses penuh ke aplikasi mobile
- **Admin Mall:** Akses terbatas ke dashboard web (tidak di mobile)
- **Super Admin:** Akses penuh ke semua data via dashboard web

**Implementasi:**
- Pemisahan akses berdasarkan role di backend
- Mobile app hanya untuk customer
- Validasi role dilakukan di server side

**Temuan Keamanan:**
1. ✅ **Positif:** Pemisahan role yang jelas
2. ⚠️ **Risiko:** Tidak ada validasi role di client side (bergantung sepenuhnya pada backend)

---

### 1.2 Akses dan Perubahan Data pada Basis Data

#### A. Tabel Sensitif yang Memerlukan Proteksi

Berdasarkan SKPPL (Bab 5), tabel-tabel berikut mengandung data sensitif:

**Tabel Autentikasi:**

1. **`user`** - Menyimpan kredensial (password/PIN), email, nomor HP, saldo poin
   - **Kolom Kritis:** `password`, `email`, `no_hp`, `saldo_poin`
   - **Risiko:** Akses tidak sah dapat mengubah kredensial atau saldo

2. **`customer`, `admin_mall`, `super_admin`** - Data profil berdasarkan role
   - **Kolom Kritis:** `id_user`, `hak_akses`
   - **Risiko:** Privilege escalation jika hak akses diubah

**Tabel Transaksi Keuangan:**

3. **`transaksi_parkir`** - Catatan transaksi parkir
   - **Kolom Kritis:** `biaya`, `penalty`, `waktu_masuk`, `waktu_keluar`
   - **Risiko:** Manipulasi biaya atau durasi parkir

4. **`pembayaran`** - Detail pembayaran
   - **Kolom Kritis:** `nominal`, `metode`, `status`, `waktu_bayar`
   - **Risiko:** Perubahan status pembayaran tanpa otorisasi

5. **`riwayat_poin`** - Riwayat perubahan poin
   - **Kolom Kritis:** `poin`, `perubahan`, `id_transaksi`
   - **Risiko:** Manipulasi saldo poin pengguna

**Tabel Operasional:**

6. **`booking`** - Data pemesanan slot
   - **Kolom Kritis:** `status`, `waktu_mulai`, `waktu_selesai`
   - **Risiko:** Perubahan status booking tanpa validasi

7. **`parkiran`** - Ketersediaan slot parkir
   - **Kolom Kritis:** `kapasitas`, `status`
   - **Risiko:** Manipulasi ketersediaan slot

#### B. Operasi CRUD yang Memerlukan Audit

**CREATE Operations:**

- Registrasi user baru (`/api/auth/register`)
- Pembuatan booking (`/api/booking/create`)
- Penambahan kendaraan (`/api/profile/vehicles`)
- Pembuatan transaksi parkir (scan QR masuk)

**READ Operations:**
- Fetch user profile (`/api/profile/user`)
- Fetch vehicles (`/api/profile/vehicles`)
- Check slot availability (`/api/booking/check-availability`)
- Get active parking (`/api/parking/active`)
- Get floors and slots (`/api/parking/floors/*`, `/api/parking/slots/*`)

**UPDATE Operations:**
- Update user profile (`/api/profile/user`)
- Update booking status (sistem otomatis)
- Update pembayaran status (`/api/payment/*`)
- Update saldo poin (sistem otomatis via trigger)

**DELETE Operations:**
- Delete vehicle (tidak terlihat di kode saat ini)
- Cancel booking (tidak terlihat di kode saat ini)

**Temuan Keamanan:**
1. ⚠️ **Risiko:** Tidak ada soft delete implementation yang terlihat
2. ⚠️ **Risiko:** Operasi UPDATE tidak memiliki versioning atau audit trail yang jelas
3. ❌ **Kritis:** Tidak ada mekanisme rollback untuk transaksi keuangan

---

### 1.3 Endpoint API yang Sensitif

#### A. Endpoint Autentikasi
