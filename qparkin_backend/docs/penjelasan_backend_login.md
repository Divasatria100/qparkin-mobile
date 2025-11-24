# Analisis API Login Backend QParkin

## Status API Login dengan nomor_hp dan pin

### Apakah sudah ada API login menggunakan nomor_hp dan pin?

**Ya, sudah ada.**

### File terkait:

- **Controller**: `app/Http/Controllers/Auth/ApiAuthController.php` (method `login`)
- **Route**: `routes/api.php` (route `POST /api/login`)
- **Model**: `app/Models/User.php` (tabel `user`)

### Logic yang digunakan:

1. **Validasi input**: nomor_hp (required, string), pin (required, string, size 6 digit)
2. **Pencarian user**: berdasarkan kolom `no_hp` di tabel `user`
3. **Verifikasi pin**: menggunakan `Hash::check($request->pin, $user->pin)`
4. **Pengecekan status**: user harus status 'aktif'
5. **Token generation**: menggunakan Laravel Sanctum untuk membuat access token
6. **Response**: mengembalikan data user dan token jika berhasil

### Struktur tabel user terkait login:

```sql
CREATE TABLE `user` (
  `id_user` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL,  -- digunakan untuk login
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `pin` varchar(255) DEFAULT NULL,   -- PIN untuk login (tidak terlihat di migration utama)
  `role` enum('customer','admin_mall','super_admin') NOT NULL DEFAULT 'customer',
  `status` enum('aktif','non-aktif') NOT NULL DEFAULT 'aktif',
  -- ... kolom lainnya
);
```

**Catatan**: Kolom `pin` tidak terlihat di migration utama (`0001_01_01_000000_create_users_table.php`), kemungkinan ditambahkan melalui migration terpisah atau secara manual.

## Format Request untuk Flutter

### Endpoint:
```
POST /api/login
```

### Headers:
```
Content-Type: application/json
```

### Body (JSON):
```json
{
  "nomor_hp": "081234567890",
  "pin": "123456"
}
```

## Format Response untuk Flutter

### Response Success (HTTP 200):
```json
{
  "success": true,
  "message": "Login berhasil",
  "user": {
    "id_user": 1,
    "name": "Nama User",
    "email": "user@example.com",
    "nomor_hp": "081234567890",
    "role": "customer",
    "saldo_poin": 100
  },
  "token": "1|abc123def456..."
}
```

### Response Error - Nomor HP tidak terdaftar (HTTP 401):
```json
{
  "message": "Nomor HP tidak terdaftar."
}
```

### Response Error - PIN salah (HTTP 401):
```json
{
  "message": "PIN salah."
}
```

### Response Error - Akun tidak aktif (HTTP 403):
```json
{
  "message": "Akun tidak aktif. Silakan hubungi administrator."
}
```

### Response Error - Server error (HTTP 500):
```json
{
  "message": "Error creating token: [error message]"
}
```

## Catatan Tambahan

- API ini menggunakan Laravel Sanctum untuk authentication
- Token yang dikembalikan harus disimpan di Flutter untuk request selanjutnya
- Untuk request yang memerlukan authentication, sertakan header: `Authorization: Bearer {token}`
- Ada juga API login Google terpisah di method `googleLogin` yang sama
