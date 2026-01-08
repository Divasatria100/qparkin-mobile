# Admin Mall Registration Redirect Fix

## 🔍 Analisis Masalah

### Penyebab Redirect ke success-signup.html

**Lokasi Masalah:** `qparkin_backend/public/js/signup.js` (baris 367-368)

```javascript
// Redirect to success page
window.location.href = 'success-signup.html';
```

### Root Cause Analysis

1. **JavaScript Hardcoded Redirect**
   - Form submit di-handle oleh JavaScript (preventDefault)
   - Setelah validasi client-side, JavaScript melakukan redirect manual ke `success-signup.html`
   - File `success-signup.html` adalah file static HTML yang tidak ada di Laravel routes

2. **Form Tidak Dikirim ke Backend**
   - Form memiliki `action="{{ route('register') }}"` dan `method="POST"`
   - Namun JavaScript mencegah submit default dengan `e.preventDefault()`
   - Data hanya di-log ke console, tidak dikirim ke server
   - Simulasi API call dengan `setTimeout()` 2 detik

3. **Controller Tidak Digunakan**
   - `RegisteredUserController::store()` sudah ada dan siap menerima data
   - Namun tidak pernah dipanggil karena form tidak di-submit
   - Controller hanya handle registrasi user biasa, bukan admin mall

### Alur Saat Ini (SALAH)
```
User Submit Form 
  → JavaScript preventDefault()
  → Validasi client-side
  → setTimeout 2 detik
  → Redirect ke success-signup.html (404 atau file static)
  ❌ Data tidak tersimpan ke database
```

### Alur Yang Seharusnya
```
User Submit Form
  → JavaScript preventDefault()
  → Validasi client-side
  → AJAX POST ke backend
  → Backend validasi & simpan data
  → Backend return success response
  → JavaScript redirect ke success-signup.blade.php (Laravel route)
  ✅ Data tersimpan, user dapat login setelah approval
```

---

## ✅ Solusi Perbaikan

### Opsi 1: Redirect ke Blade View (Recommended)

Ubah redirect ke Laravel route yang sudah ada:

**File:** `qparkin_backend/public/js/signup.js`

```javascript
// SEBELUM (baris 367-368):
// Redirect to success page
window.location.href = 'success-signup.html';

// SESUDAH:
// Redirect to success page (Laravel route)
window.location.href = '/success-signup';
```

**Tambahkan Route:**

**File:** `qparkin_backend/routes/web.php`

```php
// Tambahkan di dalam middleware guest group
Route::middleware('guest')->group(function () {
    // ... existing routes ...
    
    Route::get('/success-signup', function () {
        return view('auth.success-signup');
    })->name('success-signup');
});
```

### Opsi 2: Kirim Data ke Backend dengan AJAX (Best Practice)

Ubah form submission untuk benar-benar mengirim data ke backend:

**File:** `qparkin_backend/public/js/signup.js` (replace form submission handler)

```javascript
// Form submission
signupForm.addEventListener('submit', function(e) {
    e.preventDefault();
    
    // ... existing validation code ...
    
    if (!isValid) {
        showNotification('Harap perbaiki error dalam form', 'error');
        return;
    }
    
    // Show loading state
    submitBtn.classList.add('loading');
    submitBtn.querySelector('.btn-text').textContent = 'Mengirim...';
    submitBtn.querySelector('.btn-loader').classList.remove('hidden');
    submitBtn.disabled = true;
    
    // Prepare FormData
    const formData = new FormData(signupForm);
    
    // Add coordinates if marker exists
    if (marker && marker.getPosition()) {
        const position = marker.getPosition();
        formData.append('latitude', position.lat());
        formData.append('longitude', position.lng());
    }
    
    // Send AJAX request
    fetch('/register', {
        method: 'POST',
        body: formData,
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            return response.json().then(err => Promise.reject(err));
        }
        return response.json();
    })
    .then(data => {
        // Success - redirect to success page
        window.location.href = '/success-signup';
    })
    .catch(error => {
        console.error('Registration error:', error);
        
        // Reset button state
        submitBtn.classList.remove('loading');
        submitBtn.querySelector('.btn-text').textContent = 'Submit Request';
        submitBtn.querySelector('.btn-loader').classList.add('hidden');
        submitBtn.disabled = false;
        
        // Show error notification
        if (error.errors) {
            // Laravel validation errors
            Object.keys(error.errors).forEach(key => {
                showNotification(error.errors[key][0], 'error');
            });
        } else if (error.message) {
            showNotification(error.message, 'error');
        } else {
            showNotification('Terjadi kesalahan. Silakan coba lagi.', 'error');
        }
    });
});
```

### Opsi 3: Update Controller untuk Admin Mall Registration

Buat controller khusus untuk registrasi admin mall:

**File:** `qparkin_backend/app/Http/Controllers/Auth/AdminMallRegistrationController.php` (NEW)

```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Mall;
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
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'mall_name' => ['required', 'string', 'max:255'],
            'location' => ['required', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'mall_photo' => ['required', 'image', 'max:2048'], // 2MB max
        ]);

        // Store mall photo
        $photoPath = null;
        if ($request->hasFile('mall_photo')) {
            $photoPath = $request->file('mall_photo')->store('mall_photos', 'public');
        }

        // Create user with pending status
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'admin', // Admin mall role
            'status' => 'pending', // Pending approval
        ]);

        // Create mall record (pending)
        Mall::create([
            'user_id' => $user->id,
            'nama_mall' => $validated['mall_name'],
            'lokasi' => $validated['location'],
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'foto' => $photoPath,
            'status' => 'pending',
        ]);

        // TODO: Send notification to super admin
        // TODO: Send confirmation email to user

        return response()->json([
            'success' => true,
            'message' => 'Registration request submitted successfully',
            'redirect' => route('success-signup')
        ]);
    }
}
```

**Update Route:**

```php
// File: qparkin_backend/routes/web.php
use App\Http\Controllers\Auth\AdminMallRegistrationController;

Route::middleware('guest')->group(function () {
    // ... existing routes ...
    
    // Admin mall registration
    Route::post('/register', [AdminMallRegistrationController::class, 'store']);
    
    Route::get('/success-signup', function () {
        return view('auth.success-signup');
    })->name('success-signup');
});
```

---

## 📋 Checklist Implementasi

### Quick Fix (5 menit)
- [ ] Ubah `window.location.href = 'success-signup.html'` menjadi `'/success-signup'`
- [ ] Tambahkan route `/success-signup` di `web.php`
- [ ] Test redirect berfungsi

### Proper Fix (30 menit)
- [ ] Implementasi AJAX submission di `signup.js`
- [ ] Buat `AdminMallRegistrationController`
- [ ] Update route untuk menggunakan controller baru
- [ ] Tambahkan kolom `status` di tabel `users` (migration)
- [ ] Tambahkan tabel `malls` jika belum ada
- [ ] Test full flow: submit → save → redirect

### Complete Solution (2 jam)
- [ ] Semua dari Proper Fix
- [ ] Kirim email notifikasi ke super admin
- [ ] Kirim email konfirmasi ke user
- [ ] Buat halaman approval di super admin dashboard
- [ ] Implementasi approve/reject functionality
- [ ] Update user status setelah approval
- [ ] Test end-to-end flow

---

## 🧪 Testing

### Test Redirect
```bash
# 1. Buka form registrasi
http://localhost:8000/register

# 2. Isi form dan submit
# 3. Pastikan redirect ke:
http://localhost:8000/success-signup
# BUKAN ke:
http://localhost:8000/success-signup.html (404)
```

### Test Data Tersimpan
```sql
-- Check user created
SELECT * FROM users WHERE email = 'test@mall.com';

-- Check mall created
SELECT * FROM malls WHERE user_id = [user_id_from_above];
```

---

## 📝 Rekomendasi

**Untuk Development Cepat:** Gunakan **Opsi 1** (Quick Fix)
- Minimal changes
- Redirect langsung berfungsi
- Data belum tersimpan (masih simulasi)

**Untuk Production:** Gunakan **Opsi 2 + Opsi 3** (Complete Solution)
- Data benar-benar tersimpan
- Proper validation
- Email notifications
- Approval workflow

---

## 🔗 File Terkait

- `qparkin_backend/public/js/signup.js` - JavaScript form handler
- `qparkin_backend/resources/views/auth/signup.blade.php` - Form view
- `qparkin_backend/resources/views/auth/success-signup.blade.php` - Success page
- `qparkin_backend/routes/web.php` - Routes
- `qparkin_backend/app/Http/Controllers/Auth/RegisteredUserController.php` - Current controller
