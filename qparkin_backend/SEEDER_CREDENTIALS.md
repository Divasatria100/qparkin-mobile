# Database Seeder - Login Credentials

Setelah menjalankan `php artisan migrate --seed`, berikut adalah kredensial akun yang tersedia:

## 1. Super Admin
- **Username:** `qparkin`
- **Password:** `superadmin123`
- **Role:** super_admin
- **Email:** -
- **Nomor HP:** -
- **Saldo Poin:** 999,999
- **Dashboard:** `/superadmin/dashboard`

## 2. Admin Mall
- **Username:** `adminmall`
- **Password:** `admin123`
- **Role:** admin_mall
- **Email:** admin@qparkin.com
- **Nomor HP:** 081234567890
- **Saldo Poin:** 0
- **Assigned Mall:** Mega Mall Batam Centre (id_mall: 1)
- **Dashboard:** `/admin/dashboard`

## 3. Customer
- **Username:** `berkat`
- **Password:** (sudah di-hash, untuk testing API)
- **Role:** customer
- **Email:** -
- **Nomor HP:** 082284710929
- **Saldo Poin:** 0

---

## 🌐 Cara Login Web

### URL Login
```
http://localhost:8000/signin
```

### Super Admin
```
Username: qparkin
Password: superadmin123
```

### Admin Mall
```
Username: adminmall
Password: admin123
```

**PENTING:** Login web menggunakan field `name` (username), BUKAN email!

---

## 📱 Cara Login API (Mobile App)

### Endpoint
```
POST /api/login
```

### Request Body (Admin Mall)
```json
{
  "username": "adminmall",
  "password": "admin123"
}
```

### Request Body (Super Admin)
```json
{
  "username": "qparkin",
  "password": "superadmin123"
}
```

---

## 🔄 Reset Database

Jika ingin reset ulang database dan seeding:
```bash
php artisan migrate:fresh --seed
```

---

## 📝 Catatan Penting

1. **Field Login:** Sistem menggunakan kolom `name` sebagai username untuk login, bukan `email`
2. **Role Mapping:** 
   - Route `admin` → Database role `admin_mall`
   - Route `superadmin` → Database role `super_admin`
3. **Admin Mall:** Otomatis ter-assign ke Mega Mall Batam Centre setelah seeding
4. **Password Hash:** Semua password di-hash menggunakan bcrypt Laravel
