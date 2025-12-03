# Fix Error 422 - Login & Register

## Masalah yang Ditemukan

1. **Duplikasi Controller**: Ada 2 controller auth berbeda
   - `App\Http\Controllers\Api\AuthController` (tidak sesuai database)
   - `App\Http\Controllers\Auth\ApiAuthController` (sesuai database) ✅

2. **Ketidakcocokan Field**:
   - Database table: `user` (singular) dengan field `nomor_hp`, `name`
   - Controller lama validasi: `unique:users` (plural) ❌
   - Flutter mengirim: `email`, `password`, `no_telp` ❌

## Perubahan yang Dilakukan

### Backend (qparkin_backend)

1. **routes/api.php**
   - Ganti dari `Api\AuthController` ke `Auth\ApiAuthController`
   - Endpoint tetap sama: `/api/auth/login`, `/api/auth/register`

2. **Auth\ApiAuthController.php** (sudah benar, tidak perlu diubah)
   - Validasi: `nomor_hp`, `pin` (size:6)
   - Table: `user` (singular)
   - Response format sudah sesuai

### Frontend (qparkin_app)

1. **lib/data/services/auth_service.dart**
   - **Login**: Kirim `nomor_hp` dan `pin` (bukan `email` dan `password`)
   - **Register**: Kirim `nama`, `nomor_hp`, `pin` (bukan `name`, `email`, `password`, `no_telp`)
   - Response parsing disesuaikan dengan format backend

## API Contract

### POST /api/auth/register
**Request:**
```json
{
  "nama": "John Doe",
  "nomor_hp": "081234567890",
  "pin": "123456"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Registrasi berhasil"
}
```

### POST /api/auth/login
**Request:**
```json
{
  "nomor_hp": "081234567890",
  "pin": "123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login berhasil",
  "user": {
    "id_user": 1,
    "name": "John Doe",
    "email": null,
    "nomor_hp": "081234567890",
    "role": "customer",
    "saldo_poin": 0
  },
  "token": "1|xxxxxxxxxxxxx"
}
```

## Testing

1. Clear cache Laravel:
   ```bash
   php artisan config:clear
   php artisan route:clear
   php artisan cache:clear
   ```

2. Verify routes:
   ```bash
   php artisan route:list --path=api/auth
   ```

3. Test dari Flutter app dengan nomor HP dan PIN 6 digit

## Database Schema

Table: `user` (singular)
- `id_user` (PK)
- `name`
- `nomor_hp` (unique, nullable)
- `email` (unique, nullable)
- `password` (nullable untuk Google login)
- `role` (enum: customer, admin_mall, super_admin)
- `saldo_poin` (default: 0)
- `status` (enum: aktif, non-aktif)
- `provider` (nullable: google, email)
- `provider_id` (nullable)
