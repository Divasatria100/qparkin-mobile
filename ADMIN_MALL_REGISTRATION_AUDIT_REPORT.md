# Laporan Audit: Registrasi Admin Mall & Pengajuan Akun

## 1. Executive Summary

**Status Sistem: ⚠️ PERLU PERBAIKAN KRITIS**

Sistem registrasi admin mall dan halaman pengajuan akun memiliki **ketidaksesuaian data yang serius** antara frontend dan backend. Ditemukan beberapa masalah kritis yang menyebabkan alur data tidak sinkron:

1. **Controller yang salah digunakan** - Route menggunakan `RegisteredUserController` yang tidak mendukung field admin mall
2. **Struktur database tidak sesuai** - Field yang digunakan di controller berbeda dengan migration
3. **JavaScript AJAX tidak aktif** - Form menggunakan submit biasa, bukan AJAX
4. **Backend pengajuan tidak lengkap** - Method approve/reject hanya update status, tidak membuat akun admin mall

**Dampak:** Data registrasi admin mall tidak tersimpan dengan benar, dan pengajuan tidak dapat diproses dengan sempurna.

---

## 2. Audit Halaman Registrasi Admin Mall

### 2.1 Frontend (View & JavaScript)

#### ✅ **Sudah Berfungsi:**
- Form memiliki semua field yang diperlukan (name, email, mall_name, location, mall_photo, password)
- Validasi client-side sudah ada di JavaScript
- CSRF token sudah ada di form
- UI feedback untuk error sudah tersedia
- Google Maps integration untuk lokasi
- Photo upload dengan preview

#### ❌ **Masalah Ditemukan:**

**MASALAH #1: JavaScript AJAX Tidak Aktif**
- **Lokasi:** `qparkin_backend/public/js/signup-ajax.js`
- **Deskripsi:** File `signup-ajax.js` berisi fungsi `setupFormSubmissionWithAjax()` tetapi tidak dipanggil
- **Dampak:** Form menggunakan submit HTML biasa, bukan AJAX
- **Prioritas:** HIGH

**MASALAH #2: File JavaScript yang Salah Dimuat**
- **Lokasi:** `qparkin_backend/resources/views/auth/signup.blade.php` line 95
- **Deskripsi:** View memuat `signup.js` bukan `signup-ajax.js`
- **Dampak:** AJAX handler tidak ter-load
- **Prioritas:** HIGH


### 2.2 Backend (Controller & Route)

#### ❌ **Masalah Kritis:**

**MASALAH #3: Controller yang Salah Digunakan**
- **Lokasi:** `qparkin_backend/routes/web.php` line 27
- **Deskripsi:** Route `/register` menggunakan `RegisteredUserController::store` yang hanya menerima name, email, password
- **Dampak:** Field mall_name, location, latitude, longitude, mall_photo TIDAK TERSIMPAN
- **Prioritas:** CRITICAL

**MASALAH #4: AdminMallRegistrationController Tidak Digunakan**
- **Lokasi:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`
- **Deskripsi:** Controller sudah dibuat dengan validasi lengkap, tetapi tidak terhubung ke route
- **Dampak:** Logika registrasi admin mall tidak berjalan
- **Prioritas:** CRITICAL

**MASALAH #5: Struktur Data Tidak Konsisten**
- **Lokasi:** `AdminMallRegistrationController.php` vs Migration
- **Deskripsi:** 
  - Controller menggunakan: `mall_name`, `mall_location`, `mall_latitude`, `mall_longitude`, `mall_photo`
  - Migration menggunakan: `requested_mall_name`, `requested_mall_location`
  - Migration TIDAK memiliki field: `mall_latitude`, `mall_longitude`, `mall_photo`
- **Dampak:** Data tidak dapat disimpan karena field tidak ada di database
- **Prioritas:** CRITICAL

### 2.3 Database (Migration & Model)

#### ⚠️ **Perlu Perbaikan:**

**MASALAH #6: Field Database Tidak Lengkap**
- **Lokasi:** `qparkin_backend/database/migrations/2025_12_22_000001_add_application_fields_to_user_table.php`
- **Deskripsi:** Migration hanya memiliki:
  - `application_status`
  - `requested_mall_name`
  - `requested_mall_location`
  - `application_notes`
  - `applied_at`, `reviewed_at`, `reviewed_by`
- **Yang Kurang:**
  - `mall_latitude` (untuk koordinat)
  - `mall_longitude` (untuk koordinat)
  - `mall_photo` (untuk foto mall)
  - `requested_password` (untuk password yang diajukan)
- **Prioritas:** HIGH

**MASALAH #7: Model User Tidak Lengkap**
- **Lokasi:** `qparkin_backend/app/Models/User.php` line 35-48
- **Deskripsi:** Fillable sudah ada untuk application fields, tapi tidak ada untuk latitude, longitude, photo
- **Prioritas:** HIGH


---

## 3. Audit Halaman Pengajuan Akun (Super Admin)

### 3.1 Frontend (View & JavaScript)

#### ✅ **Sudah Berfungsi:**
- View menampilkan tabel pengajuan dengan baik
- Filter berdasarkan status (pending/approved/rejected)
- Search functionality
- Bulk actions (approve/reject multiple)
- UI responsive dan user-friendly

#### ⚠️ **Perlu Perbaikan:**

**MASALAH #8: Data Tidak Sesuai dengan Form Registrasi**
- **Lokasi:** `qparkin_backend/resources/views/superadmin/pengajuan.blade.php` line 82-95
- **Deskripsi:** View menampilkan `$request->mall_name` dan `$request->location`, tetapi field ini tidak ada di database
- **Seharusnya:** `$request->requested_mall_name` dan `$request->requested_mall_location`
- **Prioritas:** HIGH

**MASALAH #9: JavaScript Hanya Simulasi**
- **Lokasi:** `qparkin_backend/public/js/super-pengajuan-akun.js` line 200-250
- **Deskripsi:** Fungsi approve/reject hanya update UI, tidak ada AJAX call ke backend
- **Dampak:** Perubahan tidak tersimpan ke database
- **Prioritas:** CRITICAL

### 3.2 Backend (Controller & Route)

#### ⚠️ **Perlu Perbaikan:**

**MASALAH #10: Method Approve Tidak Lengkap**
- **Lokasi:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php` line 348-354
- **Deskripsi:** Method `approvePengajuan()` hanya update status menjadi 'approved'
- **Yang Kurang:**
  - Tidak membuat akun admin_mall di tabel `admin_mall`
  - Tidak membuat mall baru di tabel `mall`
  - Tidak update `reviewed_at` dan `reviewed_by`
  - Tidak kirim email notifikasi
- **Prioritas:** CRITICAL

**MASALAH #11: Method Reject Tidak Lengkap**
- **Lokasi:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php` line 356-362
- **Deskripsi:** Method `rejectPengajuan()` hanya update status
- **Yang Kurang:**
  - Tidak update `reviewed_at` dan `reviewed_by`
  - Tidak ada field untuk alasan penolakan
  - Tidak kirim email notifikasi
- **Prioritas:** HIGH

**MASALAH #12: Method Pengajuan Mengambil Data yang Salah**
- **Lokasi:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php` line 342-346
- **Deskripsi:** Query `User::where('status', 'pending')` tidak sesuai
- **Seharusnya:** `User::where('application_status', 'pending')`
- **Prioritas:** CRITICAL


---

## 4. Audit Alur Data End-to-End

### 4.1 Sinkronisasi Data

❌ **TIDAK SINKRON** - Alur data terputus di beberapa titik:

1. **Form → Database:**
   - Form mengirim: `mall_name`, `location`, `latitude`, `longitude`, `mall_photo`
   - Controller menerima: `mall_name`, `mall_location`, `mall_latitude`, `mall_longitude`, `mall_photo`
   - Database memiliki: `requested_mall_name`, `requested_mall_location` (tanpa latitude, longitude, photo)
   - **Result:** Data koordinat dan foto HILANG

2. **Database → View Pengajuan:**
   - Database: `requested_mall_name`, `requested_mall_location`
   - View mengakses: `$request->mall_name`, `$request->location`
   - **Result:** Data TIDAK MUNCUL di halaman pengajuan

3. **Approve → Akun Admin Mall:**
   - Approve hanya update status
   - Tidak membuat entry di tabel `admin_mall`
   - Tidak membuat entry di tabel `mall`
   - **Result:** Admin mall tidak bisa login, mall tidak terdaftar

### 4.2 Status Management

⚠️ **TIDAK KONSISTEN:**

- Form registrasi set: `status = 'pending'` (di controller yang tidak terpakai)
- Migration menggunakan: `application_status` enum('pending', 'approved', 'rejected')
- SuperAdmin query: `where('status', 'pending')` ← SALAH
- Approve/Reject update: `status = 'approved'` ← SALAH, seharusnya `application_status`

### 4.3 User Creation Flow

❌ **TIDAK BERFUNGSI:**

Saat approve pengajuan, yang seharusnya terjadi:
1. ✅ Update `application_status` = 'approved'
2. ❌ Update `reviewed_at` = now()
3. ❌ Update `reviewed_by` = super_admin_id
4. ❌ Update `role` = 'admin_mall'
5. ❌ Update `status` = 'active'
6. ❌ Buat entry di tabel `mall` dengan data dari `requested_mall_*`
7. ❌ Buat entry di tabel `admin_mall` linking user ke mall
8. ❌ Kirim email notifikasi ke user

**Yang terjadi sekarang:** Hanya step 1 (dan itu pun salah field)


---

## 5. Masalah yang Ditemukan - Ringkasan

### Critical Priority (Harus Diperbaiki Segera)

| # | Masalah | Lokasi | Dampak |
|---|---------|--------|--------|
| 3 | Route menggunakan controller yang salah | `routes/web.php:27` | Data mall tidak tersimpan |
| 4 | AdminMallRegistrationController tidak terpakai | Controller | Validasi tidak berjalan |
| 5 | Field database tidak sesuai dengan controller | Migration vs Controller | Data tidak bisa disimpan |
| 9 | JavaScript approve/reject hanya simulasi | `super-pengajuan-akun.js` | Perubahan tidak tersimpan |
| 10 | Approve tidak membuat akun admin mall | `SuperAdminController:348` | Admin tidak bisa login |
| 12 | Query pengajuan menggunakan field yang salah | `SuperAdminController:342` | Data tidak muncul |

### High Priority

| # | Masalah | Lokasi | Dampak |
|---|---------|--------|--------|
| 1 | AJAX handler tidak aktif | `signup-ajax.js` | Tidak ada feedback real-time |
| 2 | File JS yang salah dimuat | `signup.blade.php:95` | AJAX tidak ter-load |
| 6 | Field latitude, longitude, photo tidak ada | Migration | Data lokasi hilang |
| 7 | Model User fillable tidak lengkap | `User.php` | Data tidak bisa mass-assign |
| 8 | View mengakses field yang salah | `pengajuan.blade.php` | Data tidak tampil |
| 11 | Reject tidak lengkap | `SuperAdminController:356` | Tidak ada audit trail |


---

## 6. Rekomendasi Perbaikan

### FASE 1: Perbaikan Database (CRITICAL)

#### Step 1.1: Update Migration - Tambah Field yang Kurang

**File:** `qparkin_backend/database/migrations/2025_12_22_000001_add_application_fields_to_user_table.php`

```php
public function up(): void
{
    Schema::table('user', function (Blueprint $table) {
        // Status pengajuan untuk admin mall
        $table->enum('application_status', ['pending', 'approved', 'rejected'])->nullable()->after('status');
        
        // Informasi mall yang diajukan
        $table->string('requested_mall_name')->nullable()->after('application_status');
        $table->string('requested_mall_location')->nullable()->after('requested_mall_name');
        $table->decimal('requested_mall_latitude', 10, 8)->nullable()->after('requested_mall_location');
        $table->decimal('requested_mall_longitude', 11, 8)->nullable()->after('requested_mall_latitude');
        $table->string('requested_mall_photo')->nullable()->after('requested_mall_longitude');
        $table->text('application_notes')->nullable()->after('requested_mall_photo');
        
        // Password yang diajukan (encrypted)
        $table->string('requested_password')->nullable()->after('application_notes');
        
        // Tanggal pengajuan dan review
        $table->timestamp('applied_at')->nullable()->after('requested_password');
        $table->timestamp('reviewed_at')->nullable()->after('applied_at');
        $table->unsignedBigInteger('reviewed_by')->nullable()->after('reviewed_at');
        
        // Foreign key untuk reviewer (super admin)
        $table->foreign('reviewed_by')->references('id_user')->on('user')->onDelete('set null');
    });
}
```

**Jalankan:**
```bash
php artisan migrate:rollback --step=1
php artisan migrate
```

#### Step 1.2: Update Model User

**File:** `qparkin_backend/app/Models/User.php`

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
    'application_status',
    'requested_mall_name',
    'requested_mall_location',
    'requested_mall_latitude',
    'requested_mall_longitude',
    'requested_mall_photo',
    'requested_password',
    'application_notes',
    'applied_at',
    'reviewed_at',
    'reviewed_by'
];
```


### FASE 2: Perbaikan Backend Registration (CRITICAL)

#### Step 2.1: Update AdminMallRegistrationController

**File:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`

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
        'mall_photo' => ['required', 'image', 'max:2048'],
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
        'requested_password' => Hash::make($validated['password']), // Store for later
        'role' => 'customer', // Default role until approved
        'status' => 'inactive', // Inactive until approved
        'application_status' => 'pending',
        'requested_mall_name' => $validated['mall_name'],
        'requested_mall_location' => $validated['location'],
        'requested_mall_latitude' => $validated['latitude'] ?? null,
        'requested_mall_longitude' => $validated['longitude'] ?? null,
        'requested_mall_photo' => $photoPath,
        'applied_at' => now(),
    ]);

    // TODO: Send notification to super admin
    // TODO: Send confirmation email to user

    if ($request->expectsJson()) {
        return response()->json([
            'success' => true,
            'message' => 'Pengajuan registrasi berhasil dikirim. Silakan tunggu persetujuan dari administrator.',
            'redirect' => route('success-signup')
        ]);
    }

    return redirect()->route('success-signup')
        ->with('success', 'Pengajuan registrasi berhasil dikirim.');
}
```

#### Step 2.2: Update Route

**File:** `qparkin_backend/routes/web.php`

```php
use App\Http\Controllers\Auth\AdminMallRegistrationController;

Route::middleware('guest')->group(function () {
    // ... existing routes ...
    
    Route::get('/register', function () { 
        return view('auth.signup'); 
    })->name('register');
    
    // GANTI INI - gunakan AdminMallRegistrationController
    Route::post('/register', [AdminMallRegistrationController::class, 'store']);
    
    // ... existing routes ...
});
```


### FASE 3: Perbaikan Frontend Registration (HIGH)

#### Step 3.1: Update View untuk Load AJAX Script

**File:** `qparkin_backend/resources/views/auth/signup.blade.php`

Ganti line 95 dari:
```php
<script src="{{ asset('js/signup.js') }}"></script>
```

Menjadi:
```php
<script src="{{ asset('js/signup-ajax.js') }}"></script>
<script>
    // Initialize AJAX form submission
    document.addEventListener('DOMContentLoaded', function() {
        setupFormSubmissionWithAjax();
    });
</script>
```

#### Step 3.2: Update signup-ajax.js

**File:** `qparkin_backend/public/js/signup-ajax.js`

Tambahkan di akhir file:
```javascript
// Auto-initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    setupFormSubmissionWithAjax();
});
```

### FASE 4: Perbaikan Backend Pengajuan (CRITICAL)

#### Step 4.1: Update SuperAdminController - Method pengajuan()

**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

```php
public function pengajuan()
{
    // PERBAIKAN: Gunakan application_status, bukan status
    $requests = User::where('application_status', 'pending')
        ->orderBy('applied_at', 'desc')
        ->get();
    
    return view('superadmin.pengajuan', compact('requests'));
}
```

#### Step 4.2: Update Method approvePengajuan()

```php
public function approvePengajuan($id)
{
    DB::beginTransaction();
    try {
        $user = User::findOrFail($id);
        
        // Validasi bahwa ini adalah pengajuan pending
        if ($user->application_status !== 'pending') {
            return back()->withErrors(['error' => 'Pengajuan ini sudah diproses sebelumnya.']);
        }
        
        // 1. Buat Mall baru
        $mall = Mall::create([
            'nama_mall' => $user->requested_mall_name,
            'lokasi' => $user->requested_mall_location,
            'alamat_gmaps' => $user->requested_mall_latitude && $user->requested_mall_longitude 
                ? "https://maps.google.com/?q={$user->requested_mall_latitude},{$user->requested_mall_longitude}"
                : null,
            'kapasitas' => 100, // Default capacity, bisa diubah nanti
            'has_slot_reservation_enabled' => false,
        ]);
        
        // 2. Update user menjadi admin_mall
        $user->update([
            'role' => 'admin_mall',
            'status' => 'active',
            'application_status' => 'approved',
            'reviewed_at' => now(),
            'reviewed_by' => Auth::id(),
        ]);
        
        // 3. Buat entry di admin_mall
        AdminMall::create([
            'id_user' => $user->id_user,
            'id_mall' => $mall->id_mall,
            'hak_akses' => 'full',
        ]);
        
        // 4. TODO: Kirim email notifikasi approval
        // Mail::to($user->email)->send(new AdminMallApproved($user, $mall));
        
        DB::commit();
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Pengajuan berhasil disetujui'
            ]);
        }
        
        return redirect()->route('superadmin.pengajuan')
            ->with('success', 'Pengajuan berhasil disetujui. Akun admin mall telah dibuat.');
            
    } catch (\Exception $e) {
        DB::rollBack();
        \Log::error('Error approving application: ' . $e->getMessage());
        
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


#### Step 4.3: Update Method rejectPengajuan()

```php
public function rejectPengajuan(Request $request, $id)
{
    $validated = $request->validate([
        'rejection_reason' => 'nullable|string|max:500'
    ]);
    
    DB::beginTransaction();
    try {
        $user = User::findOrFail($id);
        
        // Validasi bahwa ini adalah pengajuan pending
        if ($user->application_status !== 'pending') {
            return back()->withErrors(['error' => 'Pengajuan ini sudah diproses sebelumnya.']);
        }
        
        // Update status
        $user->update([
            'application_status' => 'rejected',
            'application_notes' => $validated['rejection_reason'] ?? 'Pengajuan ditolak oleh administrator',
            'reviewed_at' => now(),
            'reviewed_by' => Auth::id(),
        ]);
        
        // Hapus foto mall jika ada
        if ($user->requested_mall_photo && Storage::disk('public')->exists($user->requested_mall_photo)) {
            Storage::disk('public')->delete($user->requested_mall_photo);
        }
        
        // TODO: Kirim email notifikasi rejection
        // Mail::to($user->email)->send(new AdminMallRejected($user, $validated['rejection_reason']));
        
        DB::commit();
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Pengajuan berhasil ditolak'
            ]);
        }
        
        return redirect()->route('superadmin.pengajuan')
            ->with('success', 'Pengajuan berhasil ditolak.');
            
    } catch (\Exception $e) {
        DB::rollBack();
        \Log::error('Error rejecting application: ' . $e->getMessage());
        
        if ($request->expectsJson()) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
        
        return back()->withErrors(['error' => 'Gagal menolak pengajuan: ' . $e->getMessage()]);
    }
}
```

### FASE 5: Perbaikan Frontend Pengajuan (CRITICAL)

#### Step 5.1: Update View Pengajuan

**File:** `qparkin_backend/resources/views/superadmin/pengajuan.blade.php`

Ganti line 82-95, ubah dari:
```php
<td>{{ $request->mall_name ?? 'N/A' }}</td>
<td>{{ $request->location ?? 'N/A' }}</td>
```

Menjadi:
```php
<td>{{ $request->requested_mall_name ?? 'N/A' }}</td>
<td>{{ $request->requested_mall_location ?? 'N/A' }}</td>
```

Dan tambahkan kolom foto mall (opsional):
```php
<td>
    @if($request->requested_mall_photo)
        <img src="{{ asset('storage/' . $request->requested_mall_photo) }}" 
             alt="Mall Photo" 
             class="mall-photo-thumbnail"
             style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
    @else
        <span class="text-muted">No photo</span>
    @endif
</td>
```


#### Step 5.2: Update JavaScript untuk AJAX Real

**File:** `qparkin_backend/public/js/super-pengajuan-akun.js`

Ganti fungsi `approveApplications()` (line ~200):

```javascript
function approveApplications(applicationIds) {
    if (applicationIds.length === 0) return;
    
    const message = applicationIds.length === 1 
        ? 'Apakah Anda yakin ingin menyetujui pengajuan akun ini?'
        : `Apakah Anda yakin ingin menyetujui ${applicationIds.length} pengajuan akun?`;
    
    if (confirm(message)) {
        // Get CSRF token
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        
        // Process each application
        applicationIds.forEach(id => {
            fetch(`/superadmin/pengajuan/${id}/approve`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken,
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update UI
                    const row = document.querySelector(`.btn-action[data-id="${id}"]`).closest('tr');
                    const statusBadge = row.querySelector('.status-badge');
                    statusBadge.textContent = 'Disetujui';
                    statusBadge.className = 'status-badge approved';
                    
                    // Disable action buttons
                    row.querySelectorAll('.btn-action.approve, .btn-action.reject').forEach(btn => {
                        btn.disabled = true;
                        btn.style.opacity = '0.5';
                        btn.style.cursor = 'not-allowed';
                    });
                    
                    // Uncheck the row
                    const checkbox = row.querySelector('.row-checkbox');
                    if (checkbox) checkbox.checked = false;
                    
                    showNotification(data.message || 'Pengajuan berhasil disetujui', 'success');
                } else {
                    showNotification(data.message || 'Gagal menyetujui pengajuan', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('Terjadi kesalahan saat menyetujui pengajuan', 'error');
            });
        });
        
        // Update counts and UI
        setTimeout(() => {
            updateSelectAllCheckbox();
            updateBulkActions();
            updateNotificationCount();
        }, 500);
    }
}
```

Ganti fungsi `rejectApplications()` (line ~250):

```javascript
function rejectApplications(applicationIds) {
    if (applicationIds.length === 0) return;
    
    const message = applicationIds.length === 1 
        ? 'Apakah Anda yakin ingin menolak pengajuan akun ini?'
        : `Apakah Anda yakin ingin menolak ${applicationIds.length} pengajuan akun?`;
    
    const reason = prompt('Alasan penolakan (opsional):');
    
    if (confirm(message)) {
        // Get CSRF token
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        
        // Process each application
        applicationIds.forEach(id => {
            fetch(`/superadmin/pengajuan/${id}/reject`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken,
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({
                    rejection_reason: reason
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update UI
                    const row = document.querySelector(`.btn-action[data-id="${id}"]`).closest('tr');
                    const statusBadge = row.querySelector('.status-badge');
                    statusBadge.textContent = 'Ditolak';
                    statusBadge.className = 'status-badge rejected';
                    
                    // Disable action buttons
                    row.querySelectorAll('.btn-action.approve, .btn-action.reject').forEach(btn => {
                        btn.disabled = true;
                        btn.style.opacity = '0.5';
                        btn.style.cursor = 'not-allowed';
                    });
                    
                    // Uncheck the row
                    const checkbox = row.querySelector('.row-checkbox');
                    if (checkbox) checkbox.checked = false;
                    
                    showNotification(data.message || 'Pengajuan berhasil ditolak', 'success');
                } else {
                    showNotification(data.message || 'Gagal menolak pengajuan', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('Terjadi kesalahan saat menolak pengajuan', 'error');
            });
        });
        
        // Update counts and UI
        setTimeout(() => {
            updateSelectAllCheckbox();
            updateBulkActions();
            updateNotificationCount();
        }, 500);
    }
}
```


---

## 7. Checklist Implementasi

### Phase 1: Database & Model (30 menit)
- [ ] Rollback migration terakhir
- [ ] Update migration file dengan field baru (latitude, longitude, photo, requested_password)
- [ ] Jalankan migration
- [ ] Update Model User - tambah field ke $fillable
- [ ] Test: `php artisan tinker` → cek struktur tabel `user`

### Phase 2: Backend Registration (45 menit)
- [ ] Update `AdminMallRegistrationController::store()` dengan logika lengkap
- [ ] Update `routes/web.php` - ganti controller untuk POST /register
- [ ] Test manual: Submit form registrasi
- [ ] Verifikasi: Cek database apakah data tersimpan dengan benar
- [ ] Verifikasi: Cek foto tersimpan di `storage/app/public/mall_photos/`

### Phase 3: Frontend Registration (15 menit)
- [ ] Update `signup.blade.php` - load `signup-ajax.js`
- [ ] Update `signup-ajax.js` - tambah auto-initialize
- [ ] Test: Submit form dan lihat console untuk AJAX request
- [ ] Verifikasi: Cek response JSON dari backend

### Phase 4: Backend Pengajuan (60 menit)
- [ ] Update `SuperAdminController::pengajuan()` - fix query
- [ ] Update `SuperAdminController::approvePengajuan()` - implementasi lengkap
- [ ] Update `SuperAdminController::rejectPengajuan()` - implementasi lengkap
- [ ] Tambah `use DB;` dan `use Storage;` di controller
- [ ] Test: Approve pengajuan
- [ ] Verifikasi: Cek tabel `mall`, `admin_mall`, dan `user` setelah approve
- [ ] Test: Reject pengajuan
- [ ] Verifikasi: Cek field `application_status` dan `application_notes`

### Phase 5: Frontend Pengajuan (30 menit)
- [ ] Update `pengajuan.blade.php` - fix field names
- [ ] Update `super-pengajuan-akun.js` - implementasi AJAX real
- [ ] Test: Klik tombol Approve di UI
- [ ] Verifikasi: Cek network tab untuk AJAX request
- [ ] Verifikasi: Cek database apakah data ter-update
- [ ] Test: Klik tombol Reject di UI
- [ ] Verifikasi: Status berubah di UI dan database

### Phase 6: Testing End-to-End (30 menit)
- [ ] Test complete flow: Register → Pending → Approve → Login
- [ ] Test complete flow: Register → Pending → Reject
- [ ] Test edge cases: Duplicate email, invalid photo, missing fields
- [ ] Test bulk actions: Approve multiple, Reject multiple
- [ ] Test filters: Status filter, date filter, search

### Phase 7: Polish & Documentation (30 menit)
- [ ] Tambah email notification (opsional)
- [ ] Tambah logging untuk audit trail
- [ ] Update dokumentasi API
- [ ] Buat user guide untuk super admin
- [ ] Buat FAQ untuk calon admin mall

**Total Estimasi Waktu: 3.5 - 4 jam**


---

## 8. Testing Plan

### 8.1 Unit Testing

**Test Registration Controller:**
```bash
php artisan make:test AdminMallRegistrationTest
```

```php
public function test_registration_stores_data_correctly()
{
    Storage::fake('public');
    
    $response = $this->post('/register', [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'mall_name' => 'Grand Mall',
        'location' => 'Jakarta Selatan',
        'latitude' => -6.2088,
        'longitude' => 106.8456,
        'mall_photo' => UploadedFile::fake()->image('mall.jpg')
    ]);
    
    $this->assertDatabaseHas('user', [
        'email' => 'john@example.com',
        'application_status' => 'pending',
        'requested_mall_name' => 'Grand Mall'
    ]);
    
    Storage::disk('public')->assertExists('mall_photos/mall.jpg');
}
```

**Test Approval Process:**
```php
public function test_approval_creates_mall_and_admin()
{
    $user = User::factory()->create([
        'application_status' => 'pending',
        'requested_mall_name' => 'Test Mall',
        'requested_mall_location' => 'Test Location'
    ]);
    
    $superAdmin = User::factory()->create(['role' => 'super_admin']);
    
    $response = $this->actingAs($superAdmin)
        ->post("/superadmin/pengajuan/{$user->id_user}/approve");
    
    $this->assertDatabaseHas('user', [
        'id_user' => $user->id_user,
        'application_status' => 'approved',
        'role' => 'admin_mall',
        'status' => 'active'
    ]);
    
    $this->assertDatabaseHas('mall', [
        'nama_mall' => 'Test Mall'
    ]);
    
    $this->assertDatabaseHas('admin_mall', [
        'id_user' => $user->id_user
    ]);
}
```

### 8.2 Integration Testing

**Test Complete Registration Flow:**
1. Buka halaman `/register`
2. Isi semua field dengan data valid
3. Upload foto mall
4. Submit form
5. Verifikasi redirect ke `/success-signup`
6. Login sebagai super admin
7. Buka halaman `/superadmin/pengajuan`
8. Verifikasi data muncul di tabel
9. Klik tombol Approve
10. Verifikasi status berubah
11. Logout dan login dengan email yang baru diapprove
12. Verifikasi redirect ke dashboard admin mall

**Test Rejection Flow:**
1. Submit registrasi baru
2. Login sebagai super admin
3. Klik tombol Reject
4. Masukkan alasan penolakan
5. Verifikasi status berubah menjadi 'rejected'
6. Verifikasi foto mall terhapus dari storage
7. Coba login dengan email yang ditolak → harus gagal

### 8.3 Manual Testing Checklist

**Registration Form:**
- [ ] Semua field required berfungsi
- [ ] Validasi email format
- [ ] Validasi password minimal 6 karakter
- [ ] Password confirmation match
- [ ] Upload foto max 2MB
- [ ] Google Maps location picker berfungsi
- [ ] Error message muncul dengan jelas
- [ ] Success message dan redirect

**Pengajuan Page:**
- [ ] Data muncul dengan benar
- [ ] Filter status berfungsi
- [ ] Search berfungsi
- [ ] Pagination berfungsi (jika ada banyak data)
- [ ] Tombol Approve berfungsi
- [ ] Tombol Reject berfungsi
- [ ] Bulk actions berfungsi
- [ ] Refresh data berfungsi

**Post-Approval:**
- [ ] Admin mall bisa login
- [ ] Redirect ke dashboard admin mall
- [ ] Mall muncul di list mall
- [ ] Admin mall bisa akses fitur admin

---

## 9. Catatan Tambahan

### Security Considerations
1. **Password Storage:** Password disimpan 2x (hashed) - di `password` dan `requested_password`. Setelah approve, `requested_password` bisa dihapus.
2. **File Upload:** Validasi tipe file dan ukuran sudah ada. Pertimbangkan tambahan: virus scan, image optimization.
3. **CSRF Protection:** Sudah ada di form dan AJAX request.
4. **Authorization:** Pastikan hanya super admin yang bisa approve/reject.

### Performance Considerations
1. **Image Optimization:** Resize foto mall sebelum disimpan (max 1024x1024px).
2. **Pagination:** Tambahkan pagination di halaman pengajuan jika data > 50.
3. **Caching:** Cache list pengajuan pending untuk dashboard super admin.

### Future Enhancements
1. **Email Notifications:** Kirim email saat pengajuan diterima, diapprove, atau ditolak.
2. **Audit Log:** Log semua aktivitas approve/reject untuk audit trail.
3. **Bulk Upload:** Allow super admin upload multiple malls via Excel.
4. **Application Detail Page:** Halaman detail untuk melihat semua info pengajuan sebelum approve.
5. **Rejection Reason Template:** Dropdown alasan penolakan yang umum.

---

## 10. Kesimpulan

Sistem registrasi admin mall dan pengajuan akun memiliki **masalah kritis** yang menyebabkan data tidak tersimpan dan tidak dapat diproses dengan benar. Perbaikan yang direkomendasikan mencakup:

1. **Database:** Tambah field yang kurang (latitude, longitude, photo)
2. **Backend Registration:** Gunakan controller yang benar dengan validasi lengkap
3. **Backend Approval:** Implementasi lengkap untuk membuat mall dan admin_mall
4. **Frontend:** Fix field names dan implementasi AJAX real

Dengan mengikuti checklist implementasi di atas, sistem dapat berfungsi dengan baik dalam waktu **3.5 - 4 jam**.

**Prioritas Tertinggi:**
- Fix route registration (5 menit)
- Fix query pengajuan (5 menit)
- Implementasi approve lengkap (30 menit)
- Update view field names (10 menit)

**Total waktu untuk fix critical issues: ~50 menit**

Setelah perbaikan, sistem akan dapat:
✅ Menerima registrasi admin mall dengan lengkap
✅ Menampilkan pengajuan di dashboard super admin
✅ Approve pengajuan dan membuat akun admin mall + mall
✅ Reject pengajuan dengan alasan
✅ Admin mall yang diapprove dapat login dan mengelola mall
