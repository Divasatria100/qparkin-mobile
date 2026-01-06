# UserSeeder Fix - Idempotent Seeding

## Masalah
UserSeeder menggunakan `id_user` hardcode yang menyebabkan duplicate primary key error ketika database sudah memiliki data user dari registrasi aplikasi.

## Solusi
Menggunakan `updateOrInsert()` dengan identifier unik untuk setiap role:

### 1. Super Admin
- **Identifier**: `name = 'qparkin'` + `role = 'super_admin'`
- **Kredensial**: username `qparkin`, password `superadmin123`
- **Saldo Poin**: 999999

### 2. Customer
- **Identifier**: `nomor_hp = '082284710929'` + `role = 'customer'`
- **Kredensial**: nomor HP `082284710929`

### 3. Admin Mall
- **Identifier**: `email = 'admin@qparkin.com'` + `role = 'admin_mall'`
- **Kredensial**: email `admin@qparkin.com`, password `admin123`

## Keuntungan
✅ Tidak menggunakan `id_user` hardcode - auto-increment berjalan normal
✅ Aman dijalankan berulang kali tanpa error duplicate
✅ Tidak menghapus data user yang sudah ada
✅ Hanya membuat akun default jika belum ada (berdasarkan identifier unik)
✅ Update data jika akun sudah ada (misalnya reset password)

## Cara Menjalankan
```bash
php artisan db:seed --class=UserSeeder
```

Atau jalankan semua seeder:
```bash
php artisan db:seed
```

## Testing
Seeder dapat dijalankan berkali-kali tanpa error:
```bash
php artisan db:seed --class=UserSeeder
php artisan db:seed --class=UserSeeder  # Tidak akan error
```
