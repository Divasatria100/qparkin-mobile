# Panduan Implementasi End-to-End: Registrasi Admin Mall → Mobile App

## Executive Summary

**Tujuan:** Sinkronisasi penuh alur registrasi admin mall hingga mall muncul di aplikasi mobile dengan pendekatan minimal PBL.

**Scope:** 
1. ✅ Registrasi calon admin mall (form → backend)
2. ✅ Halaman pengajuan akun superadmin (display pending)
3. ✅ Proses approve (create mall + link admin)
4. ✅ API backend untuk mobile (return active malls)
5. ✅ Mobile app (display markers + navigasi Google Maps)

**Out of Scope:**
- ❌ Routing internal / polyline calculation
- ❌ Turn-by-turn navigation
- ❌ Traffic information

---

## 1. Alur Data End-to-End (Ringkas)

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: REGISTRASI CALON ADMIN MALL                            │
│ Form → AdminMallRegistrationController → Database (pending)    │
│ Data: name, email, password, mall_name, location, lat, lng     │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: HALAMAN PENGAJUAN SUPERADMIN                           │
│ Query: User where application_status = 'pending'                │
│ Display: List pengajuan dengan data lengkap                     │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: APPROVE SUPERADMIN (KRITIS)                            │
│ 1. Update user: application_status = 'approved', role = 'admin_mall' │
│ 2. Create mall: dengan lat, lng, google_maps_url, status='active'   │
│ 3. Create admin_mall: link user dengan mall                    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: API BACKEND                                            │
│ GET /api/mall → Return malls where status = 'active'           │
│ Response: id, name, address, lat, lng, google_maps_url         │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 5: MOBILE APP                                             │
│ MapProvider.loadMalls() → Fetch API                            │
│ map_page.dart → Display markers (lat, lng)                     │
│ User tap "Lihat Rute" → Open google_maps_url                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Komponen yang Perlu Diperbaiki/Ditambah

### 2.1 Database

**File yang Perlu Dimodifikasi:**
- ✅ Migration: Tambah field ke tabel `user` dan `mall`

**File yang Perlu Dibuat:**
- ✅ Migration baru untuk field koordinat

### 2.2 Backend

**File yang Perlu Dimodifikasi:**
- ✅ `routes/web.php` - Fix route registration
- ✅ `AdminMallRegistrationController.php` - Implementasi lengkap
- ✅ `SuperAdminController.php` - Fix approve flow
- ✅ `MallController.php` (API) - Implementasi lengkap
- ✅ `Mall.php` (Model) - Tambah field dan helper methods
- ✅ `User.php` (Model) - Tambah field application
- ✅ `pengajuan.blade.php` - Fix field names

**File yang Perlu Dibuat:**
- Tidak ada (semua sudah ada, hanya perlu dimodifikasi)

### 2.3 Mobile App

**File yang Perlu Dimodifikasi:**
- ✅ `map_provider.dart` - Konsumsi API real
- ✅ `mall_model.dart` - Tambah field google_maps_url
- ✅ `map_page.dart` - Ganti tombol "Rute" dengan "Lihat Rute"

**File yang Perlu Dibuat:**
- ✅ `mall_service.dart` - Service untuk fetch API

---

## 3. Implementasi Step-by-Step

### STEP 1: Database Setup (20 menit)

#### 1.1 Migration untuk Tabel User

**File:** `qparkin_backend/database/migrations/2025_12_22_000001_add_application_fields_to_user_table.php`

**SUDAH ADA**, tapi perlu ditambah field:

```php
public function up(): void
{
    Schema::table('user', function (Blueprint $table) {
        // Status pengajuan
        $table->enum('application_status', ['pending', 'approved', 'rejected'])->nullable()->after('status');
        
        // Informasi mall yang diajukan
        $table->string('requested_mall_name')->nullable()->after('application_status');
        $table->string('requested_mall_location')->nullable()->after('requested_mall_name');
        $table->decimal('requested_mall_latitude', 10, 8)->nullable()->after('requested_mall_location');  // ← TAMBAH
        $table->decimal('requested_mall_longitude', 11, 8)->nullable()->after('requested_mall_latitude'); // ← TAMBAH
        $table->string('requested_mall_photo')->nullable()->after('requested_mall_longitude');
        $table->text('application_notes')->nullable()->after('requested_mall_photo');
        
        // Tanggal pengajuan dan review
        $table->timestamp('applied_at')->nullable()->after('application_notes');
        $table->timestamp('reviewed_at')->nullable()->after('applied_at');
        $table->unsignedBigInteger('reviewed_by')->nullable()->after('reviewed_at');
        
        $table->foreign('reviewed_by')->references('id_user')->on('user')->onDelete('set null');
    });
}
```

**Jalankan:**
```bash
# Jika migration sudah pernah dijalankan, rollback dulu
php artisan migrate:rollback --step=1

# Edit migration file, tambah field latitude & longitude

# Jalankan lagi
php artisan migrate
```

#### 1.2 Migration untuk Tabel Mall

**File:** `qparkin_backend/database/migrations/2026_01_XX_add_coordinates_to_mall_table.php` (BUAT BARU)

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            // Koordinat untuk marker di peta
            $table->decimal('latitude', 10, 8)->nullable()->after('lokasi');
            $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
            
            // URL untuk navigasi eksternal
            $table->string('google_maps_url', 500)->nullable()->after('longitude');
            
            // Status mall
            $table->enum('status', ['active', 'inactive'])->default('active')->after('google_maps_url');
        });
    }

    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude', 'google_maps_url', 'status']);
        });
    }
};
```

**Jalankan:**
```bash
php artisan make:migration add_coordinates_to_mall_table
# Copy kode di atas ke file migration yang dibuat
php artisan migrate
```



### STEP 2: Update Models (15 menit)

#### 2.1 Update Model User

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
    'requested_mall_latitude',      // ← TAMBAH
    'requested_mall_longitude',     // ← TAMBAH
    'requested_mall_photo',
    'application_notes',
    'applied_at',
    'reviewed_at',
    'reviewed_by'
];
```

#### 2.2 Update Model Mall

**File:** `qparkin_backend/app/Models/Mall.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mall extends Model
{
    use HasFactory;

    protected $table = 'mall';
    protected $primaryKey = 'id_mall';
    public $timestamps = true;

    protected $fillable = [
        'nama_mall',
        'lokasi',
        'latitude',              // ← TAMBAH
        'longitude',             // ← TAMBAH
        'google_maps_url',       // ← TAMBAH
        'status',                // ← TAMBAH
        'kapasitas',
        'alamat_gmaps',
        'has_slot_reservation_enabled'
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'has_slot_reservation_enabled' => 'boolean',
    ];

    // Helper: Generate Google Maps URL
    public static function generateGoogleMapsUrl($latitude, $longitude)
    {
        if ($latitude && $longitude) {
            return "https://www.google.com/maps/dir/?api=1&destination={$latitude},{$longitude}";
        }
        return null;
    }

    // Helper: Validasi koordinat
    public function hasValidCoordinates()
    {
        return $this->latitude !== null 
            && $this->longitude !== null
            && $this->latitude >= -90 
            && $this->latitude <= 90
            && $this->longitude >= -180 
            && $this->longitude <= 180;
    }

    // Relationships
    public function adminMall()
    {
        return $this->hasMany(AdminMall::class, 'id_mall', 'id_mall');
    }

    public function parkiran()
    {
        return $this->hasMany(Parkiran::class, 'id_mall', 'id_mall');
    }

    public function tarifParkir()
    {
        return $this->hasMany(TarifParkir::class, 'id_mall', 'id_mall');
    }

    public function transaksiParkir()
    {
        return $this->hasMany(TransaksiParkir::class, 'id_mall', 'id_mall');
    }
}
```

### STEP 3: Fix Route Registration (5 menit)

**File:** `qparkin_backend/routes/web.php`

**GANTI baris ini:**
```php
Route::post('/register', [RegisteredUserController::class, 'store']);
```

**DENGAN:**
```php
use App\Http\Controllers\Auth\AdminMallRegistrationController;

Route::post('/register', [AdminMallRegistrationController::class, 'store']);
```

### STEP 4: Implementasi AdminMallRegistrationController (15 menit)

**File:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php`

**GANTI seluruh isi dengan:**

```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules;

class AdminMallRegistrationController extends Controller
{
    /**
     * Handle admin mall registration request
     */
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

        // Create user with pending application
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'customer',  // Default role until approved
            'status' => 'inactive',  // Inactive until approved
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
}
```

### STEP 5: Update SuperAdminController - Pengajuan (20 menit)

**File:** `qparkin_backend/app/Http/Controllers/SuperAdminController.php`

#### 5.1 Update method pengajuan()

**GANTI method ini:**
```php
public function pengajuan()
{
    $requests = User::where('status', 'pending')->get();  // ❌ SALAH
    return view('superadmin.pengajuan', compact('requests'));
}
```

**DENGAN:**
```php
public function pengajuan()
{
    // Query user dengan application_status = 'pending'
    $requests = User::where('application_status', 'pending')
        ->orderBy('applied_at', 'desc')
        ->get();
    
    return view('superadmin.pengajuan', compact('requests'));
}
```

#### 5.2 Update method approvePengajuan() (KRITIS)

**GANTI method ini dengan implementasi lengkap:**

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
        
        // Generate Google Maps URL
        $googleMapsUrl = null;
        if ($user->requested_mall_latitude && $user->requested_mall_longitude) {
            $googleMapsUrl = Mall::generateGoogleMapsUrl(
                $user->requested_mall_latitude,
                $user->requested_mall_longitude
            );
        }
        
        // 1. Buat Mall baru dengan koordinat lengkap
        $mall = Mall::create([
            'nama_mall' => $user->requested_mall_name,
            'lokasi' => $user->requested_mall_location,
            'latitude' => $user->requested_mall_latitude,
            'longitude' => $user->requested_mall_longitude,
            'google_maps_url' => $googleMapsUrl,
            'status' => 'active',  // ← PENTING: Mall langsung aktif
            'kapasitas' => 100,  // Default capacity
            'has_slot_reservation_enabled' => false,
        ]);
        
        // Validasi koordinat
        if (!$mall->hasValidCoordinates()) {
            throw new \Exception('Koordinat mall tidak valid. Latitude: ' . $mall->latitude . ', Longitude: ' . $mall->longitude);
        }
        
        // 2. Update user menjadi admin_mall
        $user->update([
            'role' => 'admin_mall',
            'status' => 'active',
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
        
        // 4. TODO: Kirim email notifikasi (optional)
        
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



### STEP 6: Update View Pengajuan (10 menit)

**File:** `qparkin_backend/resources/views/superadmin/pengajuan.blade.php`

**GANTI field names yang salah:**

Cari baris ini (sekitar line 82-95):
```php
<td>{{ $request->mall_name ?? 'N/A' }}</td>
<td>{{ $request->location ?? 'N/A' }}</td>
```

**GANTI dengan:**
```php
<td>{{ $request->requested_mall_name ?? 'N/A' }}</td>
<td>{{ $request->requested_mall_location ?? 'N/A' }}</td>
```

**Opsional - Tambah kolom foto mall:**
```php
<td>
    @if($request->requested_mall_photo)
        <img src="{{ asset('storage/' . $request->requested_mall_photo) }}" 
             alt="Mall Photo" 
             style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
    @else
        <span class="text-muted">No photo</span>
    @endif
</td>
```

### STEP 7: Update JavaScript Pengajuan (15 menit)

**File:** `qparkin_backend/public/js/super-pengajuan-akun.js`

**GANTI fungsi approve dan reject dengan AJAX real:**

Cari fungsi `approveApplications()` (sekitar line 200) dan **GANTI dengan:**

```javascript
function approveApplications(applicationIds) {
    if (applicationIds.length === 0) return;
    
    const message = applicationIds.length === 1 
        ? 'Apakah Anda yakin ingin menyetujui pengajuan akun ini?'
        : `Apakah Anda yakin ingin menyetujui ${applicationIds.length} pengajuan akun?`;
    
    if (confirm(message)) {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        
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
                    const row = document.querySelector(`.btn-action[data-id="${id}"]`).closest('tr');
                    const statusBadge = row.querySelector('.status-badge');
                    statusBadge.textContent = 'Disetujui';
                    statusBadge.className = 'status-badge approved';
                    
                    row.querySelectorAll('.btn-action.approve, .btn-action.reject').forEach(btn => {
                        btn.disabled = true;
                        btn.style.opacity = '0.5';
                    });
                    
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
        
        setTimeout(() => {
            updateSelectAllCheckbox();
            updateBulkActions();
        }, 500);
    }
}
```

Cari fungsi `rejectApplications()` dan **GANTI dengan:**

```javascript
function rejectApplications(applicationIds) {
    if (applicationIds.length === 0) return;
    
    const reason = prompt('Alasan penolakan (opsional):');
    const message = applicationIds.length === 1 
        ? 'Apakah Anda yakin ingin menolak pengajuan akun ini?'
        : `Apakah Anda yakin ingin menolak ${applicationIds.length} pengajuan akun?`;
    
    if (confirm(message)) {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        
        applicationIds.forEach(id => {
            fetch(`/superadmin/pengajuan/${id}/reject`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken,
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({ rejection_reason: reason })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const row = document.querySelector(`.btn-action[data-id="${id}"]`).closest('tr');
                    const statusBadge = row.querySelector('.status-badge');
                    statusBadge.textContent = 'Ditolak';
                    statusBadge.className = 'status-badge rejected';
                    
                    row.querySelectorAll('.btn-action.approve, .btn-action.reject').forEach(btn => {
                        btn.disabled = true;
                        btn.style.opacity = '0.5';
                    });
                    
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
        
        setTimeout(() => {
            updateSelectAllCheckbox();
            updateBulkActions();
        }, 500);
    }
}
```

### STEP 8: Implementasi API MallController (20 menit)

**File:** `qparkin_backend/app/Http/Controllers/Api/MallController.php`

**GANTI seluruh isi dengan:**

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mall;
use Illuminate\Http\Request;

class MallController extends Controller
{
    /**
     * Get all active malls with parking availability
     * 
     * Returns only malls with status = 'active'
     */
    public function index()
    {
        try {
            $malls = Mall::where('status', 'active')
                ->select([
                    'mall.id_mall',
                    'mall.nama_mall',
                    'mall.lokasi',
                    'mall.latitude',
                    'mall.longitude',
                    'mall.google_maps_url',
                    'mall.status',
                    'mall.kapasitas',
                    'mall.has_slot_reservation_enabled'
                ])
                ->leftJoin('parkiran', 'mall.id_mall', '=', 'parkiran.id_mall')
                ->selectRaw('COUNT(CASE WHEN parkiran.status = "tersedia" THEN 1 END) as available_slots')
                ->groupBy(
                    'mall.id_mall',
                    'mall.nama_mall',
                    'mall.lokasi',
                    'mall.latitude',
                    'mall.longitude',
                    'mall.google_maps_url',
                    'mall.status',
                    'mall.kapasitas',
                    'mall.has_slot_reservation_enabled'
                )
                ->get()
                ->map(function ($mall) {
                    return [
                        'id_mall' => $mall->id_mall,
                        'nama_mall' => $mall->nama_mall,
                        'lokasi' => $mall->lokasi,
                        'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                        'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                        'google_maps_url' => $mall->google_maps_url,
                        'status' => $mall->status,
                        'kapasitas' => $mall->kapasitas,
                        'available_slots' => $mall->available_slots ?? 0,
                        'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                    ];
                });

            return response()->json([
                'success' => true,
                'message' => 'Malls retrieved successfully',
                'data' => $malls
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching malls: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch malls',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get single mall details
     */
    public function show($id)
    {
        try {
            $mall = Mall::where('status', 'active')
                ->with(['parkiran', 'tarifParkir'])
                ->findOrFail($id);

            $availableSlots = $mall->parkiran()
                ->where('status', 'tersedia')
                ->count();

            return response()->json([
                'success' => true,
                'message' => 'Mall details retrieved successfully',
                'data' => [
                    'id_mall' => $mall->id_mall,
                    'nama_mall' => $mall->nama_mall,
                    'lokasi' => $mall->lokasi,
                    'latitude' => $mall->latitude ? (float) $mall->latitude : null,
                    'longitude' => $mall->longitude ? (float) $mall->longitude : null,
                    'google_maps_url' => $mall->google_maps_url,
                    'status' => $mall->status,
                    'kapasitas' => $mall->kapasitas,
                    'available_slots' => $availableSlots,
                    'has_slot_reservation_enabled' => (bool) $mall->has_slot_reservation_enabled,
                    'parkiran' => $mall->parkiran,
                    'tarif' => $mall->tarifParkir,
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching mall details: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Mall not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Get parking areas for a mall
     */
    public function getParkiran($id)
    {
        try {
            $mall = Mall::where('status', 'active')->findOrFail($id);
            $parkiran = $mall->parkiran()
                ->select(['id_parkiran', 'nama_parkiran', 'lantai', 'kapasitas', 'status'])
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Parking areas retrieved successfully',
                'data' => $parkiran
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching parking areas: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch parking areas',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get parking rates for a mall
     */
    public function getTarif($id)
    {
        try {
            $mall = Mall::where('status', 'active')->findOrFail($id);
            $tarif = $mall->tarifParkir()
                ->select(['id_tarif', 'jenis_kendaraan', 'tarif_per_jam', 'tarif_maksimal'])
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Parking rates retrieved successfully',
                'data' => $tarif
            ]);
        } catch (\Exception $e) {
            \Log::error('Error fetching parking rates: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch parking rates',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
```

### STEP 9: Mobile App - Buat MallService (15 menit)

**File:** `qparkin_app/lib/data/services/mall_service.dart` (BUAT BARU)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mall_model.dart';

class MallService {
  final String baseUrl;
  
  MallService({required this.baseUrl});
  
  /// Fetch all active malls from API
  Future<List<MallModel>> fetchMalls() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mall'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final mallsData = jsonData['data'] as List<dynamic>;
          
          return mallsData
              .map((json) => MallModel.fromJson(json))
              .where((mall) => mall.validate())
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load malls: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching malls: $e');
    }
  }
}
```

### STEP 10: Mobile App - Update MallModel (10 menit)

**File:** `qparkin_app/lib/data/models/mall_model.dart`

**TAMBAH field googleMapsUrl:**

```dart
class MallModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availableSlots;
  final String distance;
  final bool hasSlotReservationEnabled;
  final String? googleMapsUrl;  // ← TAMBAH

  MallModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availableSlots,
    this.distance = '',
    this.hasSlotReservationEnabled = false,
    this.googleMapsUrl,  // ← TAMBAH
  });

  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      id: json['id']?.toString() ?? json['id_mall']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama_mall']?.toString() ?? '',
      address: json['address']?.toString() ?? json['lokasi']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      availableSlots: _parseInt(json['available_slots'] ?? json['kapasitas']),
      distance: json['distance']?.toString() ?? '',
      hasSlotReservationEnabled: json['has_slot_reservation_enabled'] == true ||
          json['has_slot_reservation_enabled'] == 1,
      googleMapsUrl: json['google_maps_url']?.toString(),  // ← TAMBAH
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'available_slots': availableSlots,
      'distance': distance,
      'has_slot_reservation_enabled': hasSlotReservationEnabled,
      'google_maps_url': googleMapsUrl,  // ← TAMBAH
    };
  }

  MallModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? availableSlots,
    String? distance,
    bool? hasSlotReservationEnabled,
    String? googleMapsUrl,  // ← TAMBAH
  }) {
    return MallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availableSlots: availableSlots ?? this.availableSlots,
      distance: distance ?? this.distance,
      hasSlotReservationEnabled:
          hasSlotReservationEnabled ?? this.hasSlotReservationEnabled,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,  // ← TAMBAH
    );
  }

  // ... existing helper methods tetap sama ...
}
```



### STEP 11: Mobile App - Update MapProvider (15 menit)

**File:** `qparkin_app/lib/logic/providers/map_provider.dart`

**TAMBAH import:**
```dart
import '../../data/services/mall_service.dart';
```

**TAMBAH field:**
```dart
class MapProvider extends ChangeNotifier {
  final LocationService _locationService;
  final RouteService _routeService;
  final search.SearchService _searchService;
  final MallService _mallService;  // ← TAMBAH

  // ... existing code ...
```

**UPDATE constructor:**
```dart
MapProvider({
  LocationService? locationService,
  RouteService? routeService,
  search.SearchService? searchService,
  MallService? mallService,  // ← TAMBAH
})  : _locationService = locationService ?? LocationService(),
      _routeService = routeService ?? RouteService(),
      _searchService = searchService ?? search.SearchService(),
      _mallService = mallService ?? MallService(
        baseUrl: const String.fromEnvironment('API_URL', 
          defaultValue: 'http://192.168.1.100:8000')
      );
```

**GANTI method loadMalls():**
```dart
/// Load mall data from backend API
Future<void> loadMalls() async {
  debugPrint('[MapProvider] Loading malls from API...');

  try {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Fetch from API
    _malls = await _mallService.fetchMalls();

    debugPrint('[MapProvider] Loaded ${_malls.length} malls from API');

    // Validate all malls have coordinates
    final invalidMalls = _malls.where((m) => !m.validate()).toList();
    if (invalidMalls.isNotEmpty) {
      debugPrint('[MapProvider] Warning: ${invalidMalls.length} malls have invalid data');
      _malls.removeWhere((m) => !m.validate());
    }

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    debugPrint('[MapProvider] Error loading malls from API: $e');
    
    // Fallback to dummy data for development
    debugPrint('[MapProvider] Falling back to dummy data');
    _malls = getDummyMalls();
    
    _isLoading = false;
    _errorMessage = 'Menggunakan data demo. Koneksi ke server gagal.';
    
    _logger.logError(
      'MALL_LOAD_ERROR',
      e.toString(),
      'MapProvider.loadMalls',
    );
    
    notifyListeners();
  }
}
```

### STEP 12: Mobile App - Update map_page.dart (20 menit)

**File:** `qparkin_app/lib/presentation/screens/map_page.dart`

#### 12.1 Tambah import url_launcher

```dart
import 'package:url_launcher/url_launcher.dart';
```

#### 12.2 Tambah method untuk buka Google Maps

**TAMBAH method baru di class _MapPageState:**

```dart
/// Open Google Maps for navigation to mall
Future<void> _openGoogleMapsNavigation(MallModel mall) async {
  if (mall.googleMapsUrl == null || mall.googleMapsUrl!.isEmpty) {
    // Fallback: generate URL from coordinates
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${mall.latitude},${mall.longitude}';
    await _launchUrl(url);
  } else {
    await _launchUrl(mall.googleMapsUrl!);
  }
}

/// Launch URL helper
Future<void> _launchUrl(String urlString) async {
  try {
    final url = Uri.parse(urlString);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint('[MapPage] Error launching URL: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

#### 12.3 HAPUS method _selectMallAndShowMap()

**HAPUS method ini** (tidak perlu lagi karena tidak ada route calculation):

```dart
// ❌ HAPUS method ini
// Future<void> _selectMallAndShowMap(int index, MapProvider mapProvider) async {
//   ... kode lama ...
// }
```

#### 12.4 Update tombol "Rute" di _buildMallCard()

Cari bagian tombol "Rute" dalam method `_buildMallCard()` (sekitar line 600-610):

**GANTI dari:**
```dart
TextButton.icon(
  onPressed: () => _selectMallAndShowMap(index, mapProvider),
  icon: const Icon(Icons.navigation, size: 16),
  label: const Text('Rute'),
  // ...
),
```

**DENGAN:**
```dart
TextButton.icon(
  onPressed: () => _openGoogleMapsNavigation(mapProvider.malls[index]),
  icon: const Icon(Icons.map, size: 16),
  label: const Text('Lihat Rute'),
  style: TextButton.styleFrom(
    foregroundColor: const Color(0xFF573ED1),
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
  ),
),
```

#### 12.5 Tambah dependency url_launcher

**File:** `qparkin_app/pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... existing dependencies ...
  url_launcher: ^6.2.0  # ← TAMBAH
```

**Jalankan:**
```bash
cd qparkin_app
flutter pub get
```

---

## 4. Checklist Implementasi Lengkap

### Backend (90 menit)

#### Database & Models (35 menit)
- [ ] **Migration User** - Tambah latitude & longitude ke application fields
  - [ ] Edit migration file
  - [ ] Rollback: `php artisan migrate:rollback --step=1`
  - [ ] Migrate: `php artisan migrate`
  - [ ] Verify: `php artisan tinker` → `Schema::getColumnListing('user')`

- [ ] **Migration Mall** - Tambah latitude, longitude, google_maps_url, status
  - [ ] Buat: `php artisan make:migration add_coordinates_to_mall_table`
  - [ ] Edit migration file
  - [ ] Migrate: `php artisan migrate`
  - [ ] Verify: `Schema::getColumnListing('mall')`

- [ ] **Update Model User** - Tambah field ke $fillable
  - [ ] Edit `User.php`
  - [ ] Test: `php artisan tinker` → `User::first()->fillable`

- [ ] **Update Model Mall** - Tambah field, helper methods
  - [ ] Edit `Mall.php`
  - [ ] Test helper: `Mall::generateGoogleMapsUrl(1.1191, 104.0538)`

#### Controllers & Routes (35 menit)
- [ ] **Fix Route** - Ganti RegisteredUserController dengan AdminMallRegistrationController
  - [ ] Edit `routes/web.php`
  - [ ] Test: `php artisan route:list | grep register`

- [ ] **AdminMallRegistrationController** - Implementasi store()
  - [ ] Edit controller
  - [ ] Test: Submit form registrasi
  - [ ] Verify: Data tersimpan dengan status pending

- [ ] **SuperAdminController::pengajuan()** - Fix query
  - [ ] Edit method
  - [ ] Test: Akses `/superadmin/pengajuan`
  - [ ] Verify: Data pending muncul

- [ ] **SuperAdminController::approvePengajuan()** - Implementasi lengkap
  - [ ] Edit method
  - [ ] Test: Approve pengajuan
  - [ ] Verify: Mall created, admin_mall created, user updated

- [ ] **MallController (API)** - Implementasi index(), show()
  - [ ] Edit controller
  - [ ] Test: `curl http://localhost:8000/api/mall`
  - [ ] Verify: Return active malls dengan koordinat

#### Views & JavaScript (20 menit)
- [ ] **pengajuan.blade.php** - Fix field names
  - [ ] Edit view
  - [ ] Test: Refresh halaman pengajuan
  - [ ] Verify: Data muncul dengan benar

- [ ] **super-pengajuan-akun.js** - Implementasi AJAX real
  - [ ] Edit JavaScript
  - [ ] Test: Klik approve/reject
  - [ ] Verify: AJAX call ke backend, UI update

### Mobile App (60 menit)

#### Services & Models (25 menit)
- [ ] **MallService** - Buat service baru
  - [ ] Buat file `mall_service.dart`
  - [ ] Implementasi `fetchMalls()`
  - [ ] Test: Run dengan mock data

- [ ] **MallModel** - Tambah googleMapsUrl
  - [ ] Edit `mall_model.dart`
  - [ ] Update `fromJson()`, `toJson()`, `copyWith()`
  - [ ] Test: Parse sample JSON

#### Providers (15 menit)
- [ ] **MapProvider** - Update untuk konsumsi API
  - [ ] Tambah `MallService` dependency
  - [ ] Update constructor
  - [ ] Update `loadMalls()` method
  - [ ] Test: Run app, verify API call

#### UI (20 menit)
- [ ] **map_page.dart** - Update untuk Google Maps navigation
  - [ ] Tambah import `url_launcher`
  - [ ] Tambah method `_openGoogleMapsNavigation()`
  - [ ] Tambah helper `_launchUrl()`
  - [ ] Hapus method `_selectMallAndShowMap()`
  - [ ] Update tombol "Rute" → "Lihat Rute"
  - [ ] Test: Tap tombol, Google Maps terbuka

- [ ] **pubspec.yaml** - Tambah dependency
  - [ ] Tambah `url_launcher: ^6.2.0`
  - [ ] Run: `flutter pub get`

### Testing End-to-End (30 menit)

#### Backend Testing
- [ ] **Registrasi** - Submit form dengan koordinat
  - [ ] Isi form registrasi
  - [ ] Submit
  - [ ] Verify: Data di database dengan status pending

- [ ] **Pengajuan** - Lihat di dashboard superadmin
  - [ ] Login sebagai superadmin
  - [ ] Akses halaman pengajuan
  - [ ] Verify: Data muncul dengan lengkap

- [ ] **Approve** - Approve pengajuan
  - [ ] Klik tombol approve
  - [ ] Verify: Mall created di database
  - [ ] Verify: admin_mall created
  - [ ] Verify: User role = admin_mall, status = active

- [ ] **API** - Test endpoint
  - [ ] `curl http://localhost:8000/api/mall`
  - [ ] Verify: Mall baru muncul dengan koordinat
  - [ ] Verify: google_maps_url ter-generate

#### Mobile App Testing
- [ ] **Launch** - Run app
  - [ ] `flutter run --dart-define=API_URL=http://192.168.1.100:8000`
  - [ ] Verify: Malls load dari API
  - [ ] Verify: No errors in console

- [ ] **Map Display** - Lihat peta
  - [ ] Buka tab "Peta"
  - [ ] Verify: Markers muncul di koordinat yang benar
  - [ ] Verify: Jumlah markers sesuai dengan API

- [ ] **Mall List** - Lihat daftar mall
  - [ ] Buka tab "Daftar Mall"
  - [ ] Verify: List muncul dengan data dari API
  - [ ] Verify: Available slots count akurat

- [ ] **Navigation** - Test tombol "Lihat Rute"
  - [ ] Tap mall card
  - [ ] Tap tombol "Lihat Rute"
  - [ ] Verify: Google Maps terbuka
  - [ ] Verify: Destination benar

#### Integration Testing
- [ ] **Complete Flow** - End-to-end
  - [ ] Registrasi admin mall baru
  - [ ] Approve di dashboard superadmin
  - [ ] Refresh mobile app
  - [ ] Verify: Mall baru muncul
  - [ ] Tap "Lihat Rute"
  - [ ] Verify: Navigasi ke mall baru

---

## 5. Troubleshooting

### Backend Issues

**Problem:** Migration error "column already exists"
```bash
# Solution: Rollback dan migrate ulang
php artisan migrate:rollback --step=1
php artisan migrate
```

**Problem:** Approve gagal "Koordinat tidak valid"
```bash
# Check: Apakah form registrasi mengirim latitude & longitude?
# Check: Apakah field ada di database?
# Check: Apakah validasi koordinat benar?
```

**Problem:** API return empty array
```bash
# Check: Apakah ada mall dengan status='active'?
# Check: Query di MallController benar?
# Test: php artisan tinker
Mall::where('status', 'active')->get()
```

### Mobile App Issues

**Problem:** Mall tidak load dari API
```bash
# Check: API URL benar?
# Check: Backend running?
# Check: Network connectivity?
# Check: Console errors?
```

**Problem:** "Lihat Rute" tidak buka Google Maps
```bash
# Check: url_launcher dependency installed?
# Check: google_maps_url tidak null?
# Check: Google Maps app installed?
```

**Problem:** Markers tidak muncul di peta
```bash
# Check: Koordinat valid?
# Check: MallModel.validate() return true?
# Check: MapProvider.malls tidak kosong?
```

---

## 6. Testing Commands

### Backend
```bash
# Test API
curl -X GET http://localhost:8000/api/mall \
  -H "Accept: application/json"

# Test database
php artisan tinker
>>> Mall::where('status', 'active')->count()
>>> User::where('application_status', 'pending')->count()

# Clear cache
php artisan config:clear
php artisan cache:clear
```

### Mobile App
```bash
# Run with API URL
cd qparkin_app
flutter run --dart-define=API_URL=http://192.168.1.100:8000

# Check for errors
flutter analyze

# Run tests
flutter test
```

---

## 7. Kesimpulan

### Alur Data Final (Ringkas)

```
1. User submit form registrasi
   ↓
2. Data tersimpan: application_status='pending'
   ↓
3. Superadmin lihat di halaman pengajuan
   ↓
4. Superadmin approve
   ↓
5. Mall created: status='active', dengan koordinat & google_maps_url
   ↓
6. Mobile app fetch: GET /api/mall
   ↓
7. MapProvider load malls
   ↓
8. map_page.dart display markers
   ↓
9. User tap "Lihat Rute"
   ↓
10. Google Maps opens dengan destination
```

### File yang Dimodifikasi (Summary)

**Backend (10 files):**
1. Migration user (edit existing)
2. Migration mall (create new)
3. Model User
4. Model Mall
5. routes/web.php
6. AdminMallRegistrationController
7. SuperAdminController
8. MallController (API)
9. pengajuan.blade.php
10. super-pengajuan-akun.js

**Mobile App (4 files + 1 new):**
1. mall_service.dart (NEW)
2. mall_model.dart
3. map_provider.dart
4. map_page.dart
5. pubspec.yaml

**Total: 15 files modified/created**

### Estimasi Waktu Total: **3 jam**
- Backend: 90 menit
- Mobile App: 60 menit
- Testing: 30 menit

---

**Panduan Implementasi End-to-End Selesai**

Ikuti checklist di atas secara berurutan untuk memastikan seluruh alur berjalan dengan sinkron dari registrasi hingga mobile app.
