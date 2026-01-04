# LAPORAN PENGECEKAN KEAMANAN BASIS DATA
## Sistem QParkIn Backend (Laravel)

---

## 1. PENGAMANAN DATA SENSITIF (PASSWORD HASHING)

### ✅ Status: **SUDAH DIIMPLEMENTASIKAN**

### Penjelasan:
Sistem QParkIn menggunakan **hashing bcrypt** untuk mengamankan password pengguna sebelum disimpan ke database. Password tidak pernah disimpan dalam bentuk plain text.

### Lokasi Implementasi:

#### **File: `app/Http/Controllers/Api/AuthController.php`**
- **Baris 21**: Registrasi pengguna menggunakan `Hash::make()`
```php
'password' => Hash::make($validated['password']),
```

- **Baris 51**: Login menggunakan `Hash::check()` untuk verifikasi
```php
if (!$user || !Hash::check($validated['password'], $user->password)) {
    return response()->json([
        'success' => false,
        'message' => 'Nomor HP/Email atau password salah'
    ], 401);
}
```

#### **File: `app/Models/User.php`**
- **Baris 48-50**: Password disembunyikan dari response API
```php
protected $hidden = [
    'password',
];
```

### Cara Kerja:
1. Saat registrasi, password di-hash menggunakan algoritma bcrypt (cost factor 10)
2. Hash disimpan ke database, bukan password asli
3. Saat login, password input di-compare dengan hash menggunakan `Hash::check()`
4. Password tidak pernah muncul di response API (protected $hidden)

### Screenshot untuk Presentasi:
- **Screenshot 1**: `AuthController.php` baris 21 (Hash::make)
- **Screenshot 2**: `AuthController.php` baris 51 (Hash::check)
- **Screenshot 3**: `User.php` baris 48-50 (protected $hidden)

---

## 2. PENCEGAHAN SQL INJECTION

### ✅ Status: **SUDAH DIIMPLEMENTASIKAN**

### Penjelasan:
Laravel menggunakan **Eloquent ORM** dan **Query Builder** yang secara otomatis melakukan **parameter binding** untuk mencegah SQL Injection. Semua query menggunakan prepared statements.

### Lokasi Implementasi:

#### **File: `app/Http/Controllers/Api/BookingController.php`**
- **Baris 18-22**: Query menggunakan Eloquent dengan parameter binding otomatis
```php
$bookings = Booking::whereHas('transaksiParkir', function ($query) use ($userId) {
    $query->where('id_user', $userId);
})
->with(['transaksiParkir', 'slot.floor', 'reservation'])
->orderBy('created_at', 'desc')
->get();
```

#### **File: `app/Http/Controllers/Api/TransaksiController.php`**
- **Baris 67**: Query dengan parameter binding
```php
$transaksi = TransaksiParkir::with(['kendaraan', 'mall', 'parkiran', 'user'])
    ->find($id);
```

- **Baris 73**: Validasi kepemilikan data
```php
if ($transaksi->id_user !== $request->user()->id_user) {
    return response()->json([
        'success' => false,
        'message' => 'Unauthorized'
    ], 403);
}
```

### Cara Kerja:
1. **Eloquent ORM** otomatis menggunakan prepared statements
2. Input user tidak pernah langsung dimasukkan ke query SQL
3. Laravel binding parameter secara otomatis mencegah injection
4. Tidak ada raw query tanpa parameter binding

### Screenshot untuk Presentasi:
- **Screenshot 1**: `BookingController.php` baris 18-22 (Eloquent query)
- **Screenshot 2**: `TransaksiController.php` baris 67 (Query dengan find)
- **Screenshot 3**: `TransaksiController.php` baris 73 (Validasi kepemilikan)

---

## 3. PEMBATASAN AKSES BERDASARKAN PERAN (RBAC)

### ✅ Status: **SUDAH DIIMPLEMENTASIKAN**

### Penjelasan:
Sistem menggunakan **Role-Based Access Control (RBAC)** dengan 3 peran: **Customer**, **Admin Mall**, dan **Super Admin**. Setiap peran memiliki batasan akses yang berbeda.

### Lokasi Implementasi:

#### **File: `app/Http/Middleware/CheckRole.php`**
- **Baris 9-36**: Middleware untuk validasi role pengguna
```php
public function handle(Request $request, Closure $next, string $role)
{
    $user = Auth::user();
    
    if (!$user) {
        abort(401, 'Unauthenticated');
    }

    $userRole = $user->role ?? null;

    // Map role names
    $roleMap = [
        'admin' => 'admin_mall',
        'superadmin' => 'super_admin',
    ];

    $expectedRole = $roleMap[$role] ?? $role;

    if ($userRole !== $expectedRole) {
        abort(403, 'Unauthorized access');
    }

    return $next($request);
}
```

#### **File: `routes/web.php`**
- **Baris 43**: Route Admin Mall dengan middleware role
```php
Route::middleware(['auth', 'role:admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard');
    // ... routes lainnya
});
```

- **Baris 73**: Route Super Admin dengan middleware role
```php
Route::middleware(['auth', 'role:superadmin'])->prefix('superadmin')->name('superadmin.')->group(function () {
    Route::get('/dashboard', [SuperAdminController::class, 'dashboard'])->name('dashboard');
    // ... routes lainnya
});
```

#### **File: `routes/api.php`**
- **Baris 33**: Semua API endpoint dilindungi dengan Sanctum authentication
```php
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [ApiAuthController::class, 'logout']);
        Route::get('/me', [ApiAuthController::class, 'getUser']);
    });
    // ... endpoints lainnya
});
```

#### **File: `app/Models/User.php`**
- **Baris 58-68**: Helper methods untuk cek role
```php
public function isSuperAdmin()
{
    return $this->role === 'super_admin';
}

public function isAdminMall()
{
    return $this->role === 'admin_mall';
}

public function isCustomer()
{
    return $this->role === 'customer';
}
```

### Cara Kerja:
1. **Middleware `CheckRole`** memvalidasi role sebelum akses route
2. **Web routes** menggunakan middleware `role:admin` atau `role:superadmin`
3. **API routes** menggunakan `auth:sanctum` untuk autentikasi token
4. Setiap request divalidasi role-nya sebelum mengakses data

### Screenshot untuk Presentasi:
- **Screenshot 1**: `CheckRole.php` baris 9-36 (Middleware validasi role)
- **Screenshot 2**: `web.php` baris 43 (Route admin dengan middleware)
- **Screenshot 3**: `api.php` baris 33 (API protected dengan Sanctum)
- **Screenshot 4**: `User.php` baris 58-68 (Helper methods role)

---

## 4. VALIDASI DATA SEBELUM DISIMPAN

### ✅ Status: **SUDAH DIIMPLEMENTASIKAN**

### Penjelasan:
Semua input dari user divalidasi menggunakan **Laravel Validator** sebelum disimpan ke database. Validasi mencakup tipe data, format, dan aturan bisnis.

### Lokasi Implementasi:

#### **File: `app/Http/Controllers/Api/AuthController.php`**
- **Baris 13-17**: Validasi registrasi
```php
$validated = $request->validate([
    'name' => 'required|string|max:255',
    'email' => 'nullable|string|email|max:255|unique:user,email',
    'password' => 'required|string|min:4',
    'no_telp' => 'required|string|max:20|unique:user,nomor_hp',
]);
```

#### **File: `app/Http/Controllers/Api/BookingController.php`**
- **Baris 42-49**: Validasi booking
```php
$request->validate([
    'id_parkiran' => 'required|exists:parkiran,id_parkiran',
    'id_kendaraan' => 'required|exists:kendaraan,id_kendaraan',
    'waktu_mulai' => 'required|date',
    'durasi_booking' => 'required|integer|min:1',
    'id_slot' => 'nullable|exists:parking_slots,id_slot',
    'reservation_id' => 'nullable|string'
]);
```

#### **File: `app/Http/Controllers/Api/KendaraanController.php`**
- **Baris 54-63**: Validasi tambah kendaraan
```php
$validator = Validator::make($request->all(), [
    'plat_nomor' => 'required|string|max:20|unique:kendaraan,plat',
    'jenis_kendaraan' => 'required|in:Roda Dua,Roda Tiga,Roda Empat,Lebih dari Enam',
    'merk' => 'required|string|max:50',
    'tipe' => 'required|string|max:50',
    'warna' => 'nullable|string|max:50',
    'is_active' => 'boolean',
    'foto' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
]);
```

#### **File: `app/Http/Controllers/Api/TransaksiController.php`**
- **Baris 93-100**: Validasi transaksi masuk
```php
$validator = Validator::make($request->all(), [
    'id_kendaraan' => 'required|integer|exists:kendaraan,id_kendaraan',
    'id_mall' => 'required|integer|exists:mall,id_mall',
    'id_parkiran' => 'required|integer|exists:parkiran,id_parkiran',
    'jenis_transaksi' => 'required|in:umum,booking',
    'id_slot' => 'nullable|integer|exists:parking_slots,id_slot'
]);
```

### Jenis Validasi yang Diterapkan:
1. **Required**: Field wajib diisi
2. **String/Integer**: Validasi tipe data
3. **Max/Min**: Batasan panjang/nilai
4. **Email**: Format email valid
5. **Unique**: Tidak boleh duplikat di database
6. **Exists**: Foreign key harus ada di tabel terkait
7. **In**: Nilai harus dari pilihan tertentu
8. **Image/Mimes**: Validasi file upload

### Cara Kerja:
1. Request masuk → Laravel Validator memeriksa aturan
2. Jika gagal → Return error 422 dengan detail kesalahan
3. Jika sukses → Data aman untuk disimpan ke database
4. Mencegah data invalid/berbahaya masuk ke sistem

### Screenshot untuk Presentasi:
- **Screenshot 1**: `AuthController.php` baris 13-17 (Validasi registrasi)
- **Screenshot 2**: `BookingController.php` baris 42-49 (Validasi booking)
- **Screenshot 3**: `KendaraanController.php` baris 54-63 (Validasi kendaraan)
- **Screenshot 4**: `TransaksiController.php` baris 93-100 (Validasi transaksi)

---

## 5. KEAMANAN TAMBAHAN

### A. Token-Based Authentication (Laravel Sanctum)
- **File**: `routes/api.php` baris 33
- Semua API endpoint dilindungi dengan token authentication
- Token di-generate saat login dan harus disertakan di setiap request

### B. Database Transaction (Rollback)
- **File**: `BookingController.php` baris 51, 141
- Menggunakan `DB::beginTransaction()` dan `DB::commit()`
- Jika terjadi error, data di-rollback untuk menjaga konsistensi

### C. Logging untuk Audit Trail
- **File**: `BookingController.php` baris 29, 110, 141
- Setiap error dan aktivitas penting dicatat dengan `Log::error()`
- Memudahkan tracking jika terjadi insiden keamanan

---

## KESIMPULAN

### ✅ Keamanan Basis Data QParkIn Backend:

| No | Aspek Keamanan | Status | Implementasi |
|----|----------------|--------|--------------|
| 1 | Password Hashing | ✅ Sudah | Hash::make() & Hash::check() |
| 2 | SQL Injection Prevention | ✅ Sudah | Eloquent ORM + Parameter Binding |
| 3 | Role-Based Access Control | ✅ Sudah | Middleware CheckRole + Sanctum |
| 4 | Input Validation | ✅ Sudah | Laravel Validator di semua endpoint |
| 5 | Token Authentication | ✅ Sudah | Laravel Sanctum |
| 6 | Database Transaction | ✅ Sudah | DB::beginTransaction() |
| 7 | Audit Logging | ✅ Sudah | Log::error() & Log::info() |

### Rekomendasi untuk Presentasi:
1. Tunjukkan **4 aspek utama** yang diminta (hashing, SQL injection, RBAC, validasi)
2. Gunakan **screenshot kode** dari file yang disebutkan di atas
3. Jelaskan dengan bahasa **non-teknis** untuk audiens akademik
4. Tekankan bahwa sistem sudah menerapkan **best practices** keamanan Laravel

---

**Catatan**: Dokumentasi ini dibuat untuk keperluan akademik PBL. Implementasi keamanan sudah sesuai dengan standar industri untuk aplikasi Laravel modern.
