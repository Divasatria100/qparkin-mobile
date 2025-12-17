# Database Connection - Admin Dashboard & Profile

## Overview
Dokumentasi koneksi data dashboard dan profile admin dengan database qparkin.

## Database Structure

### Table: `user`
Primary Key: `id_user`

**Columns:**
- `id_user` (int) - Primary key
- `name` (string) - Nama lengkap user
- `email` (string) - Email user
- `nomor_hp` (string) - Nomor telepon
- `password` (string) - Password (hashed)
- `role` (enum) - Role: 'super_admin', 'admin_mall', 'customer'
- `status` (enum) - Status: 'aktif', 'nonaktif'
- `saldo_poin` (int) - Saldo poin user
- `provider` (string) - OAuth provider (google, etc)
- `provider_id` (string) - OAuth provider ID
- `created_at` (timestamp)
- `updated_at` (timestamp)

### Table: `admin_mall`
Primary Key: `id_user`

**Columns:**
- `id_user` (int) - Foreign key to user table
- `id_mall` (int) - Foreign key to mall table
- `hak_akses` (string) - Access rights

**Relations:**
- `belongsTo(User)` - User yang menjadi admin
- `belongsTo(Mall)` - Mall yang dikelola

### Table: `mall`
Primary Key: `id_mall`

**Columns:**
- `id_mall` (int) - Primary key
- `nama_mall` (string) - Nama mall
- `alamat` (text) - Alamat lengkap mall
- `kode_mall` (string) - Kode unik mall
- `created_at` (timestamp)
- `updated_at` (timestamp)

## Model Relations

### User Model
```php
// app/Models/User.php

public function adminMall()
{
    return $this->hasOne(AdminMall::class, 'id_user', 'id_user');
}

public function isAdminMall()
{
    return $this->role === 'admin_mall';
}
```

### AdminMall Model
```php
// app/Models/AdminMall.php

public function user()
{
    return $this->belongsTo(User::class, 'id_user', 'id_user');
}

public function mall()
{
    return $this->belongsTo(Mall::class, 'id_mall', 'id_mall');
}
```

## Controller Implementation

### AdminController - Profile Methods

#### 1. Profile Display
```php
public function profile()
{
    $user = Auth::user();
    
    // Load relasi adminMall dan mall
    if (!isset($user->adminMall)) {
        $user->load('adminMall.mall');
    }
    
    return view('admin.profile', compact('user'));
}
```

**Data yang ditampilkan:**
- `$user->name` - Nama lengkap
- `$user->email` - Email
- `$user->nomor_hp` - Nomor telepon
- `$user->role` - Role (admin_mall)
- `$user->status` - Status akun (aktif/nonaktif)
- `$user->adminMall->mall->nama_mall` - Nama mall yang dikelola
- `$user->id_user` - ID user
- `$user->created_at` - Tanggal bergabung

#### 2. Edit Profile
```php
public function editProfile()
{
    $user = Auth::user();
    
    // Load relasi adminMall dan mall
    if (!isset($user->adminMall)) {
        $user->load('adminMall.mall');
    }
    
    return view('admin.edit-informasi', compact('user'));
}
```

#### 3. Update Profile
```php
public function updateProfile(Request $request)
{
    $user = Auth::user();
    $userId = $user->id_user ?? $user->id;
    
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|max:255|unique:user,email,' . $userId . ',id_user',
        'nomor_hp' => 'nullable|string|max:20',
        'status' => 'nullable|in:aktif,nonaktif',
        'current_password' => 'nullable|required_with:password',
        'password' => 'nullable|min:8|confirmed',
    ]);

    // Update fields
    $user->name = $validated['name'];
    $user->email = $validated['email'];
    
    if (isset($validated['nomor_hp'])) {
        $user->nomor_hp = $validated['nomor_hp'];
    }
    
    if (isset($validated['status'])) {
        $user->status = $validated['status'];
    }

    // Update password if provided
    if ($request->filled('password')) {
        if (!\Hash::check($request->current_password, $user->password)) {
            return back()->withErrors(['current_password' => 'Kata sandi saat ini tidak sesuai']);
        }
        $user->password = \Hash::make($validated['password']);
    }

    $user->save();

    return redirect()->route('admin.profile')->with('success', 'Profil berhasil diperbarui');
}
```

### AdminController - Dashboard Methods

#### Dashboard Data
```php
public function dashboard()
{
    $user = Auth::user();
    $adminMall = $user->adminMall;
    $mall = $adminMall->mall;
    $mallId = $mall->id_mall;

    // Pendapatan
    $pendapatanHarian = TransaksiParkir::where('id_mall', $mallId)
        ->whereDate('waktu_keluar', today())
        ->sum('biaya');

    $pendapatanMingguan = TransaksiParkir::where('id_mall', $mallId)
        ->whereBetween('waktu_keluar', [now()->startOfWeek(), now()->endOfWeek()])
        ->sum('biaya');

    $pendapatanBulanan = TransaksiParkir::where('id_mall', $mallId)
        ->whereMonth('waktu_keluar', now()->month)
        ->whereYear('waktu_keluar', now()->year)
        ->sum('biaya');

    // Kendaraan
    $masuk = TransaksiParkir::where('id_mall', $mallId)
        ->whereDate('waktu_masuk', today())
        ->count();

    $keluar = TransaksiParkir::where('id_mall', $mallId)
        ->whereDate('waktu_keluar', today())
        ->count();

    $aktif = TransaksiParkir::where('id_mall', $mallId)
        ->whereNull('waktu_keluar')
        ->count();

    // Kapasitas
    $parkiranTersedia = Parkiran::where('id_mall', $mallId)->sum('kapasitas');

    // Transaksi terbaru
    $transaksiTerbaru = TransaksiParkir::with('kendaraan')
        ->where('id_mall', $mallId)
        ->orderBy('id_transaksi', 'DESC')
        ->limit(5)
        ->get();

    return view('admin.dashboard', compact(...));
}
```

## View Implementation

### Profile View (`admin/profile.blade.php`)

**Display Data:**
```blade
<h2>{{ $user->name ?? 'Admin Mall' }}</h2>
<p>{{ $user->email ?? 'admin@mall.com' }}</p>

<span class="status-badge {{ $user->status === 'aktif' ? 'active' : '' }}">
    {{ ucfirst($user->status ?? 'Aktif') }}
</span>

<span class="join-date">
    Bergabung sejak: {{ $user->created_at ? $user->created_at->translatedFormat('d F Y') : '-' }}
</span>

<!-- Info Grid -->
<p>{{ $user->name ?? '-' }}</p>
<p>{{ $user->email ?? '-' }}</p>
<p>{{ $user->nomor_hp ?? '-' }}</p>
<p>{{ ucwords(str_replace('_', ' ', $user->role ?? 'Admin Mall')) }}</p>
<p>{{ $user->adminMall->mall->nama_mall ?? '-' }}</p>
<p>{{ $user->id_user ?? '-' }}</p>
```

### Edit Profile View (`admin/edit-informasi.blade.php`)

**Form Fields:**
```blade
<input type="text" name="name" value="{{ old('name', $user->name ?? '') }}" required>
<input type="email" name="email" value="{{ old('email', $user->email ?? '') }}" required>
<input type="text" name="username" value="{{ $user->email }}" readonly>
<input type="text" name="id_admin" value="{{ $user->id_user ?? '-' }}" readonly>

<input type="tel" name="nomor_hp" value="{{ old('nomor_hp', $user->nomor_hp ?? '') }}">
<input type="text" name="role" value="{{ ucwords(str_replace('_', ' ', $user->role ?? 'Admin Mall')) }}" readonly>

<select name="status">
    <option value="aktif" {{ ($user->status ?? 'aktif') === 'aktif' ? 'selected' : '' }}>Aktif</option>
    <option value="nonaktif" {{ ($user->status ?? '') === 'nonaktif' ? 'selected' : '' }}>Nonaktif</option>
</select>

<!-- Mall Info (readonly) -->
<input type="text" name="mall_name" value="{{ $user->adminMall->mall->nama_mall ?? 'Mall' }}" readonly>
<input type="text" name="mall_code" value="{{ $user->adminMall->mall->kode_mall ?? 'ML' }}" readonly>
<textarea name="alamat_mall" readonly>{{ $user->adminMall->mall->alamat ?? '-' }}</textarea>
```

## Testing

### Test Profile Display
1. Login sebagai admin mall
2. Navigate ke `/admin/profile`
3. Verify data ditampilkan dari database:
   - Nama, email, nomor HP
   - Status akun
   - Nama mall yang dikelola
   - Tanggal bergabung

### Test Edit Profile
1. Navigate ke `/admin/profile/edit`
2. Update nama, email, atau nomor HP
3. Submit form
4. Verify data tersimpan di database
5. Check redirect ke profile page dengan success message

### Test Update Password
1. Navigate ke `/admin/profile/security`
2. Input current password, new password, confirm password
3. Submit form
4. Verify password berhasil diupdate
5. Test login dengan password baru

## Notes

- Primary key menggunakan `id_user` bukan `id`
- Table name: `user` bukan `users`
- Nomor telepon field: `nomor_hp` bukan `phone`
- Role format: `admin_mall` dengan underscore
- Status: `aktif` atau `nonaktif` (lowercase)
- Relasi eager loading untuk performa: `$user->load('adminMall.mall')`
- Validation menggunakan table name `user` dan primary key `id_user`

## Future Enhancements

- [ ] Add photo upload functionality
- [ ] Add 2FA implementation
- [ ] Add session management
- [ ] Add login activity tracking
- [ ] Add email verification for profile changes
- [ ] Add audit log for profile updates
