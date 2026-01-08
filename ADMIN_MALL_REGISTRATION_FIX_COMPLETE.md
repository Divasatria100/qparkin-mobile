# Fix: Data Request Admin Mall Tidak Muncul di Halaman Pengajuan Akun

## 📋 RINGKASAN MASALAH

Setelah pemeriksaan menyeluruh, ditemukan **3 MASALAH UTAMA**:

### 1. **Controller Registrasi Menyimpan ke Field yang Salah**
- Menyimpan ke `mall_name`, `mall_location`, `mall_latitude`, `mall_longitude`, `mall_photo`
- Field-field tersebut **TIDAK ADA** di tabel `user`
- Seharusnya: `requested_mall_name`, `requested_mall_location`, `application_notes`

### 2. **Query SuperAdmin Mencari di Field yang Salah**
- Query: `User::where('status', 'pending')`
- Field `status` adalah enum('aktif', 'non-aktif') untuk status user
- Seharusnya: `User::where('application_status', 'pending')`

### 3. **View Menggunakan Field yang Salah**
- View menggunakan `$request->mall_name` dan `$request->location`
- Seharusnya: `$request->requested_mall_name` dan `$request->requested_mall_location`

---

## ✅ SOLUSI LENGKAP

### File 1: AdminMallRegistrationController.php

**Lokasi:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`

**Ganti seluruh isi method `store()`:**

```php
public function store(Request $request)
{
    $validated = $request->validate([
        'name' => ['required', 'string', 'max:255'],
        'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:user,email'],
        'password' => ['required', 'confirmed', Rules\Password::defaults()],
        'mall_name' => ['required', 'string', 'max:255'],
        'location' => ['required', 'string', 'max:500'],
        'latitude' => ['nullable', 'numeric', 'between:-90,90'],
        'longitude' => ['nullable', 'numeric', 'between:-180,180'],
        'mall_photo' => ['required', 'image', 'mimes:jpeg,png,jpg', 'max:2048'],
    ]);

    // Store mall photo
    $photoPath = null;
    if ($request->hasFile('mall_photo')) {
        $photoPath = $request->file('mall_photo')->store('mall_photos', 'public');
    }

    // Create user with pending application status
    $user = User::create([
        'name' => $validated['name'],
        'email' => $validated['email'],
        'password' => Hash::make($validated['password']),
        'role' => 'customer', // Tetap customer dulu, nanti diubah saat approved
        'status' => 'aktif',  // Status user aktif
        
        // Application fields (FIELD YANG BENAR):
        'application_status' => 'pending',
        'requested_mall_name' => $validated['mall_name'],
        'requested_mall_location' => $validated['location'],
        'application_notes' => json_encode([
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'photo_path' => $photoPath,
            'submitted_from' => 'web_registration',
        ]),
        'applied_at' => now(),
    ]);

    // Log untuk debugging
    \Log::info('Admin mall registration submitted', [
        'user_id' => $user->id_user,
        'email' => $user->email,
        'mall_name' => $user->requested_mall_name,
        'application_status' => $user->application_status,
    ]);

    // TODO: Send notification to super admin
    // TODO: Send confirmation email to user

    if ($request->expectsJson()) {
        return response()->json([
            'success' => true,
            'message' => 'Pengajuan registrasi berhasil dikirim. Silakan tunggu verifikasi dari admin.',
            'redirect' => route('success-signup')
        ]);
    }

    return redirect()->route('success-signup')
        ->with('success', 'Pengajuan registrasi berhasil dikirim. Silakan tunggu verifikasi dari admin.');
}
```

---

### File 2: SuperAdminController.php

**Lokasi:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

**Perbaikan 1 - Method `dashboard()` (Line 42):**

```php
// SEBELUM:
$pendingRequests = User::where('status', 'pending')->count();

// SESUDAH:
$pendingRequests = User::where('application_status', 'pending')->count();
```

**Perbaikan 2 - Method `dashboard()` (Line 83-91):**

```php
// SEBELUM:
$pendingUsers = User::where('status', 'pending')
    ->where('role', 'admin')
    ->orderBy('created_at', 'desc')
    ->limit(2)
    ->get()
    ->map(function($user) {
        return (object)[
            'time' => Carbon::parse($user->created_at)->diffForHumans(),
            'description' => 'Pengajuan akun baru: ' . ($user->name ?? 'N/A'),
            'location' => 'Menunggu verifikasi',
            'created_at' => $user->created_at
        ];
    });

// SESUDAH:
$pendingUsers = User::where('application_status', 'pending')
    ->whereNotNull('applied_at')
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

**Perbaikan 3 - Method `pengajuan()` (Line 397-400):**

```php
// SEBELUM:
public function pengajuan()
{
    $requests = User::where('status', 'pending')->get();
    return view('superadmin.pengajuan', compact('requests'));
}

// SESUDAH:
public function pengajuan()
{
    $requests = User::where('application_status', 'pending')
        ->whereNotNull('applied_at')
        ->orderBy('applied_at', 'desc')
        ->get();
    
    return view('superadmin.pengajuan', compact('requests'));
}
```

**Perbaikan 4 - Method `approvePengajuan()` (Line 410):**

Sudah benar, tapi tambahkan field koordinat:

```php
public function approvePengajuan(Request $request, $id)
{
    DB::beginTransaction();
    try {
        $user = User::findOrFail($id);
        
        // Validasi status pending
        if ($user->application_status !== 'pending') {
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengajuan ini sudah diproses sebelumnya.'
                ], 400);
            }
            return back()->withErrors(['error' => 'Pengajuan ini sudah diproses sebelumnya.']);
        }
        
        // Parse application notes untuk mendapatkan koordinat dan foto
        $applicationNotes = json_decode($user->application_notes, true) ?? [];
        $latitude = $applicationNotes['latitude'] ?? null;
        $longitude = $applicationNotes['longitude'] ?? null;
        $photoPath = $applicationNotes['photo_path'] ?? null;
        
        // Generate Google Maps URL
        $googleMapsUrl = null;
        if ($latitude && $longitude) {
            $googleMapsUrl = Mall::generateGoogleMapsUrl($latitude, $longitude);
        }
        
        // 1. Buat Mall baru dengan koordinat lengkap
        $mall = Mall::create([
            'nama_mall' => $user->requested_mall_name,
            'lokasi' => $user->requested_mall_location,
            'latitude' => $latitude,
            'longitude' => $longitude,
            'google_maps_url' => $googleMapsUrl,
            'status' => 'active',
            'kapasitas' => 100,  // Default capacity
            'has_slot_reservation_enabled' => false,
            'mall_photo' => $photoPath, // Simpan path foto jika ada
        ]);
        
        // Validasi koordinat jika ada method hasValidCoordinates
        if (method_exists($mall, 'hasValidCoordinates') && !$mall->hasValidCoordinates()) {
            throw new \Exception('Koordinat mall tidak valid. Latitude: ' . $mall->latitude . ', Longitude: ' . $mall->longitude);
        }
        
        // 2. Update user menjadi admin_mall
        $user->update([
            'role' => 'admin_mall',
            'status' => 'aktif',
            'application_status' => 'approved',
            'reviewed_at' => now(),
            'reviewed_by' => Auth::id(),
        ]);
        
        // 3. Buat entry di admin_mall (link user dengan mall)
        AdminMall::create([
            'id_user' => $user->id_user,
            'id_mall' => $mall->id_mall,
            'hak_akses' => 'full',
        ]);
        
        DB::commit();
        
        \Log::info('Mall approved successfully', [
            'mall_id' => $mall->id_mall,
            'mall_name' => $mall->nama_mall,
            'user_id' => $user->id_user,
            'coordinates' => [
                'lat' => $mall->latitude,
                'lng' => $mall->longitude
            ]
        ]);
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Pengajuan berhasil disetujui',
                'data' => [
                    'mall_id' => $mall->id_mall,
                    'mall_name' => $mall->nama_mall,
                    'status' => $mall->status,
                    'google_maps_url' => $mall->google_maps_url
                ]
            ]);
        }
        
        return redirect()->route('superadmin.pengajuan')
            ->with('success', 'Pengajuan berhasil disetujui. Mall telah ditambahkan dan siap digunakan di aplikasi mobile.');
            
    } catch (\Exception $e) {
        DB::rollBack();
        \Log::error('Error approving application', [
            'error' => $e->getMessage(),
            'user_id' => $id,
            'trace' => $e->getTraceAsString()
        ]);
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
        
        return back()->withErrors(['error' => 'Gagal menyetujui pengajuan: ' . $e->getMessage()]);
    }
}
```

---

### File 3: pengajuan.blade.php

**Lokasi:** `qparkin_backend/resources/views/superadmin/pengajuan.blade.php`

**Perbaikan di bagian tbody (Line 119-127):**

```blade
<td>{{ $request->email }}</td>
<!-- SEBELUM: -->
<td>{{ $request->mall_name ?? 'N/A' }}</td>
<td>{{ $request->location ?? 'N/A' }}</td>
<td>{{ $request->created_at ? $request->created_at->format('d M Y') : 'N/A' }}</td>
<td>
    <span class="status-badge {{ $request->status == 'pending' ? 'pending' : ($request->status == 'approved' ? 'approved' : 'rejected') }}">
        {{ $request->status == 'pending' ? 'Menunggu' : ($request->status == 'approved' ? 'Disetujui' : 'Ditolak') }}
    </span>
</td>

<!-- SESUDAH: -->
<td>{{ $request->requested_mall_name ?? 'N/A' }}</td>
<td>{{ $request->requested_mall_location ?? 'N/A' }}</td>
<td>{{ $request->applied_at ? \Carbon\Carbon::parse($request->applied_at)->format('d M Y H:i') : 'N/A' }}</td>
<td>
    <span class="status-badge {{ $request->application_status == 'pending' ? 'pending' : ($request->application_status == 'approved' ? 'approved' : 'rejected') }}">
        {{ $request->application_status == 'pending' ? 'Menunggu' : ($request->application_status == 'approved' ? 'Disetujui' : 'Ditolak') }}
    </span>
</td>
```

**Perbaikan di bagian action buttons (Line 135):**

```blade
<!-- SEBELUM: -->
@if($request->status == 'pending')

<!-- SESUDAH: -->
@if($request->application_status == 'pending')
```

---

### File 4: Sidebar SuperAdmin

**Lokasi:** `qparkin_backend/resources/views/partials/superadmin/sidebar.blade.php`

**Perbaikan counter pengajuan (Line 35-37):**

```blade
<!-- SEBELUM: -->
@php
    $pendingCount = \App\Models\User::where('status', 'pending')->count();
@endphp

<!-- SESUDAH: -->
@php
    $pendingCount = \App\Models\User::where('application_status', 'pending')->count();
@endphp
```

---

### File 5: Dashboard SuperAdmin View

**Lokasi:** `qparkin_backend/resources/views/superadmin/dashboard.blade.php`

**Perbaikan card pengajuan akun (Line 47-51):**

Pastikan menggunakan variabel `$pendingRequests` yang sudah diperbaiki di controller.

---

## 🧪 TESTING SETELAH PERBAIKAN

### 1. Test Database Migration

```bash
cd qparkin_backend
php artisan migrate:status
```

Pastikan migration `2025_12_22_000001_add_application_fields_to_user_table` sudah dijalankan.

### 2. Test Registrasi Baru

```bash
# Akses halaman registrasi
http://localhost:8000/signup

# Isi form dengan data:
- Nama: Test Admin Mall
- Email: testadmin@mall.com
- Password: password123
- Nama Mall: Test Mall Plaza
- Lokasi: Jl. Test No. 123, Jakarta
- Latitude: -6.200000
- Longitude: 106.816666
- Upload foto mall
```

### 3. Cek Database

```sql
-- Cek data yang baru disimpan
SELECT 
    id_user,
    name,
    email,
    role,
    status,
    application_status,
    requested_mall_name,
    requested_mall_location,
    application_notes,
    applied_at
FROM user
WHERE application_status = 'pending'
ORDER BY applied_at DESC;
```

**Expected Result:**
```
id_user | name              | email                  | role     | status | application_status | requested_mall_name | requested_mall_location      | applied_at
--------|-------------------|------------------------|----------|--------|-------------------|---------------------|------------------------------|------------
1       | Test Admin Mall   | testadmin@mall.com     | customer | aktif  | pending           | Test Mall Plaza     | Jl. Test No. 123, Jakarta    | 2025-01-08...
```

### 4. Test Halaman Pengajuan SuperAdmin

```bash
# Login sebagai super admin
# Akses: http://localhost:8000/superadmin/pengajuan
```

**Expected Result:**
- Data muncul di tabel
- Nama mall: "Test Mall Plaza"
- Lokasi: "Jl. Test No. 123, Jakarta"
- Status: "Menunggu"
- Tombol Approve dan Reject muncul

### 5. Test Approve Pengajuan

```bash
# Klik tombol Approve pada pengajuan
```

**Expected Result:**
```sql
-- Cek perubahan di database
SELECT 
    u.id_user,
    u.name,
    u.role,
    u.application_status,
    m.id_mall,
    m.nama_mall,
    m.lokasi,
    am.id_admin_mall
FROM user u
LEFT JOIN admin_mall am ON u.id_user = am.id_user
LEFT JOIN mall m ON am.id_mall = m.id_mall
WHERE u.email = 'testadmin@mall.com';
```

**Expected:**
- `role` berubah jadi `admin_mall`
- `application_status` berubah jadi `approved`
- Mall baru dibuat di tabel `mall`
- Entry baru di tabel `admin_mall`

---

## 📊 CHECKLIST PERBAIKAN

### Controller
- [x] ✅ `AdminMallRegistrationController::store()` - Gunakan field yang benar
- [x] ✅ `SuperAdminController::dashboard()` - Query pending requests
- [x] ✅ `SuperAdminController::dashboard()` - Recent activities
- [x] ✅ `SuperAdminController::pengajuan()` - Query application_status
- [x] ✅ `SuperAdminController::approvePengajuan()` - Parse application_notes

### View
- [x] ✅ `pengajuan.blade.php` - Gunakan `requested_mall_name`
- [x] ✅ `pengajuan.blade.php` - Gunakan `requested_mall_location`
- [x] ✅ `pengajuan.blade.php` - Gunakan `application_status`
- [x] ✅ `pengajuan.blade.php` - Gunakan `applied_at`
- [x] ✅ `sidebar.blade.php` - Counter pengajuan

### Testing
- [ ] Test registrasi baru
- [ ] Verifikasi data tersimpan di database
- [ ] Verifikasi data muncul di halaman pengajuan
- [ ] Test approve pengajuan
- [ ] Test reject pengajuan
- [ ] Test counter di sidebar
- [ ] Test recent activities di dashboard

---

## 🎯 RINGKASAN PERUBAHAN

| File | Perubahan | Alasan |
|------|-----------|--------|
| `AdminMallRegistrationController.php` | Ganti field `mall_name` → `requested_mall_name`, dll | Field yang benar sesuai migration |
| `SuperAdminController.php` (dashboard) | Query `status` → `application_status` | Field yang benar untuk tracking pengajuan |
| `SuperAdminController.php` (pengajuan) | Query `status` → `application_status` | Field yang benar untuk tracking pengajuan |
| `pengajuan.blade.php` | Field `mall_name` → `requested_mall_name` | Sesuaikan dengan field di database |
| `sidebar.blade.php` | Counter `status` → `application_status` | Hitung pengajuan yang benar |

---

## ⚠️ CATATAN PENTING

1. **Backup database** sebelum melakukan perubahan
2. **Jalankan migration** jika belum: `php artisan migrate`
3. **Clear cache** setelah perubahan: `php artisan config:clear && php artisan cache:clear`
4. **Test di environment development** dulu sebelum production
5. **Koordinat dan foto** disimpan di `application_notes` sebagai JSON
6. **Role** saat registrasi tetap `customer`, baru diubah ke `admin_mall` saat approved

---

## 🚀 LANGKAH IMPLEMENTASI

1. Backup database
2. Update `AdminMallRegistrationController.php`
3. Update `SuperAdminController.php`
4. Update `pengajuan.blade.php`
5. Update `sidebar.blade.php`
6. Clear cache: `php artisan config:clear`
7. Test registrasi baru
8. Verifikasi data muncul di halaman pengajuan
9. Test approve/reject

---

**Status:** ✅ Siap diimplementasikan
**Estimasi:** 15-20 menit
**Risk Level:** Low (hanya perubahan field mapping)
