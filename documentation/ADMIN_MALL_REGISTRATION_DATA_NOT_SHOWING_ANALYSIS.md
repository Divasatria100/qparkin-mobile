# Analisis: Data Request Admin Mall Tidak Muncul di Halaman Pengajuan Akun

## 🔍 HASIL PEMERIKSAAN

### 1. **MASALAH UTAMA DITEMUKAN**

#### A. Ketidakcocokan Field di Controller Registrasi
**File:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`

```php
// YANG DISIMPAN (Line 31-42):
$user = User::create([
    'name' => $validated['name'],
    'email' => $validated['email'],
    'password' => Hash::make($validated['password']),
    'role' => 'admin',  // ❌ SALAH: Harusnya 'admin_mall' atau tidak perlu
    'status' => 'pending',
    'mall_name' => $validated['mall_name'],           // ❌ FIELD TIDAK ADA
    'mall_location' => $validated['location'],        // ❌ FIELD TIDAK ADA
    'mall_latitude' => $validated['latitude'] ?? null, // ❌ FIELD TIDAK ADA
    'mall_longitude' => $validated['longitude'] ?? null, // ❌ FIELD TIDAK ADA
    'mall_photo' => $photoPath,                       // ❌ FIELD TIDAK ADA
]);
```

#### B. Field yang Seharusnya Digunakan (Dari Migration)
**File:** `qparkin_backend/database/migrations/2025_12_22_000001_add_application_fields_to_user_table.php`

Field yang BENAR di tabel `user`:
- ✅ `application_status` (enum: 'pending', 'approved', 'rejected')
- ✅ `requested_mall_name` (string)
- ✅ `requested_mall_location` (string)
- ✅ `application_notes` (text)
- ✅ `applied_at` (timestamp)
- ✅ `reviewed_at` (timestamp)
- ✅ `reviewed_by` (foreign key ke user)

**TIDAK ADA** field berikut di tabel user:
- ❌ `mall_name`
- ❌ `mall_location`
- ❌ `mall_latitude`
- ❌ `mall_longitude`
- ❌ `mall_photo`

#### C. Query di SuperAdminController
**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php` (Line 397)

```php
public function pengajuan()
{
    $requests = User::where('status', 'pending')->get();  // ❌ QUERY SALAH
    return view('superadmin.pengajuan', compact('requests'));
}
```

**MASALAH:**
1. Query mencari `status = 'pending'` padahal seharusnya `application_status = 'pending'`
2. Field `status` adalah enum('aktif', 'non-aktif') bukan untuk pengajuan
3. Field `application_status` adalah yang benar untuk tracking pengajuan

---

## 🐛 PENYEBAB DATA TIDAK MUNCUL

### Skenario yang Terjadi:

1. **User mengisi form registrasi admin mall** di halaman signup
2. **Controller mencoba menyimpan ke field yang tidak ada:**
   - `mall_name` → Field tidak ada di database
   - `mall_location` → Field tidak ada di database
   - `mall_latitude` → Field tidak ada di database
   - `mall_longitude` → Field tidak ada di database
   - `mall_photo` → Field tidak ada di database
3. **Laravel akan throw error atau skip field yang tidak ada**
4. **Data tidak tersimpan dengan benar**
5. **SuperAdmin query mencari `status = 'pending'`** padahal:
   - Field `status` berisi 'aktif' atau 'non-aktif' (default: 'aktif')
   - Seharusnya query `application_status = 'pending'`
6. **Hasil: Tidak ada data yang muncul di halaman pengajuan**

---

## ✅ SOLUSI YANG HARUS DILAKUKAN

### 1. Perbaiki AdminMallRegistrationController

**File:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`

```php
public function store(Request $request)
{
    $validated = $request->validate([
        'name' => ['required', 'string', 'max:255'],
        'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:users'],
        'password' => ['required', 'confirmed', Rules\Password::defaults()],
        'mall_name' => ['required', 'string', 'max:255'],
        'location' => ['required', 'string', 'max:500'],
        'latitude' => ['nullable', 'numeric'],
        'longitude' => ['nullable', 'numeric'],
        'mall_photo' => ['required', 'image', 'max:2048'],
    ]);

    // Store mall photo
    $photoPath = null;
    if ($request->hasFile('mall_photo')) {
        $photoPath = $request->file('mall_photo')->store('mall_photos', 'public');
    }

    // ✅ PERBAIKAN: Gunakan field yang benar
    $user = User::create([
        'name' => $validated['name'],
        'email' => $validated['email'],
        'password' => Hash::make($validated['password']),
        'role' => 'customer', // Tetap customer dulu, nanti diubah saat approved
        'status' => 'aktif',  // Status user tetap aktif
        
        // Field pengajuan yang BENAR:
        'application_status' => 'pending',
        'requested_mall_name' => $validated['mall_name'],
        'requested_mall_location' => $validated['location'],
        'application_notes' => json_encode([
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'photo_path' => $photoPath,
        ]),
        'applied_at' => now(),
    ]);

    // TODO: Send notification to super admin
    // TODO: Send confirmation email to user

    if ($request->expectsJson()) {
        return response()->json([
            'success' => true,
            'message' => 'Registration request submitted successfully',
            'redirect' => route('success-signup')
        ]);
    }

    return redirect()->route('success-signup');
}
```

### 2. Perbaiki SuperAdminController Query

**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

```php
public function pengajuan()
{
    // ✅ PERBAIKAN: Query yang benar
    $requests = User::where('application_status', 'pending')
        ->orderBy('applied_at', 'desc')
        ->get();
    
    return view('superadmin.pengajuan', compact('requests'));
}
```

### 3. Update Model User Fillable

**File:** `qparkin_backend/app/Models/User.php`

Pastikan field sudah ada di `$fillable` (sudah benar):
```php
protected $fillable = [
    'name',
    'nomor_hp',
    'email',
    'password',
    'role',
    'saldo_poin',
    'status',
    'provider',
    'provider_id',
    'avatar',
    'application_status',        // ✅ Sudah ada
    'requested_mall_name',       // ✅ Sudah ada
    'requested_mall_location',   // ✅ Sudah ada
    'application_notes',         // ✅ Sudah ada
    'applied_at',               // ✅ Sudah ada
    'reviewed_at',              // ✅ Sudah ada
    'reviewed_by'               // ✅ Sudah ada
];
```

### 4. Update View Pengajuan (Jika Perlu)

**File:** `qparkin_backend/resources/views/superadmin/pengajuan.blade.php`

Pastikan view menggunakan field yang benar:
```blade
@foreach($requests as $request)
    <tr>
        <td>{{ $request->name }}</td>
        <td>{{ $request->email }}</td>
        <td>{{ $request->requested_mall_name }}</td>  <!-- Bukan mall_name -->
        <td>{{ $request->requested_mall_location }}</td>  <!-- Bukan mall_location -->
        <td>{{ $request->applied_at }}</td>
        <td>{{ $request->application_status }}</td>
    </tr>
@endforeach
```

### 5. Update Dashboard SuperAdmin

**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php` (Line 42)

```php
// ✅ PERBAIKAN: Query dashboard
$pendingRequests = User::where('application_status', 'pending')->count();
```

Dan di Line 83-91:
```php
// ✅ PERBAIKAN: Recent activities
$pendingUsers = User::where('application_status', 'pending')
    ->orderBy('applied_at', 'desc')
    ->limit(2)
    ->get()
    ->map(function($user) {
        return (object)[
            'time' => Carbon::parse($user->applied_at)->diffForHumans(),
            'description' => 'Pengajuan akun baru: ' . ($user->name ?? 'N/A'),
            'location' => $user->requested_mall_name ?? 'Menunggu verifikasi',
            'created_at' => $user->applied_at
        ];
    });
```

---

## 📋 CHECKLIST PERBAIKAN

- [ ] Update `AdminMallRegistrationController::store()` - gunakan field yang benar
- [ ] Update `SuperAdminController::pengajuan()` - query `application_status`
- [ ] Update `SuperAdminController::dashboard()` - query pending requests
- [ ] Update view `pengajuan.blade.php` - gunakan field yang benar
- [ ] Update sidebar counter - gunakan `application_status`
- [ ] Test registrasi baru
- [ ] Verifikasi data muncul di halaman pengajuan
- [ ] Test approve/reject pengajuan

---

## 🧪 CARA TESTING

### 1. Test Registrasi Baru
```bash
# Akses halaman registrasi
http://localhost:8000/signup

# Isi form dengan data lengkap
# Submit form
# Cek database:
```

```sql
SELECT id_user, name, email, application_status, requested_mall_name, 
       requested_mall_location, applied_at 
FROM user 
WHERE application_status = 'pending';
```

### 2. Test Halaman Pengajuan
```bash
# Login sebagai super admin
# Akses: http://localhost:8000/superadmin/pengajuan
# Verifikasi data muncul
```

### 3. Test Approve
```bash
# Klik approve pada salah satu pengajuan
# Verifikasi:
# - application_status berubah jadi 'approved'
# - role berubah jadi 'admin_mall'
# - Mall baru dibuat
# - AdminMall entry dibuat
```

---

## 📊 RINGKASAN

| Aspek | Status Sekarang | Seharusnya |
|-------|----------------|------------|
| Field penyimpanan | `mall_name`, `mall_location` (tidak ada) | `requested_mall_name`, `requested_mall_location` |
| Query pengajuan | `status = 'pending'` | `application_status = 'pending'` |
| Role saat daftar | `'admin'` (tidak valid) | `'customer'` atau tidak set |
| Status tracking | Menggunakan `status` | Menggunakan `application_status` |
| Koordinat & foto | Field terpisah (tidak ada) | Simpan di `application_notes` (JSON) |

---

## ⚠️ CATATAN PENTING

1. **Jangan ubah migration yang sudah jalan** - Field sudah benar di database
2. **Koordinat dan foto** sebaiknya disimpan di `application_notes` sebagai JSON
3. **Role** saat registrasi tetap `customer`, baru diubah ke `admin_mall` saat approved
4. **Status** user tetap `aktif`, tracking pengajuan pakai `application_status`
5. **Pastikan migration sudah dijalankan** dengan `php artisan migrate`

---

## 🎯 PRIORITAS PERBAIKAN

1. **CRITICAL:** Perbaiki `AdminMallRegistrationController::store()` - Data tidak tersimpan
2. **HIGH:** Perbaiki `SuperAdminController::pengajuan()` - Data tidak muncul
3. **MEDIUM:** Update dashboard counter dan recent activities
4. **LOW:** Update view jika ada field yang salah

---

**Kesimpulan:** Data tidak muncul karena:
1. Controller menyimpan ke field yang tidak ada di database
2. Query mencari di field yang salah (`status` vs `application_status`)
3. Perlu perbaikan di 2 controller utama untuk menyelesaikan masalah ini
