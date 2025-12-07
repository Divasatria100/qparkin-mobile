# Admin Profile Integration

## Overview
Profile admin Laravel telah disesuaikan dengan desain native HTML/CSS/JS dari folder `visual`.

## Files Created/Updated

### Views (Blade Templates)
- `resources/views/admin/profile.blade.php` - Halaman profile utama
- `resources/views/admin/edit-informasi.blade.php` - Form edit informasi pribadi
- `resources/views/admin/ubah-foto.blade.php` - Upload foto profil
- `resources/views/admin/ubah-keamanan.blade.php` - Pengaturan keamanan & password
- `resources/views/layouts/admin.blade.php` - Layout utama (updated)

### CSS Files (Copied from visual/styles)
- `public/css/admin-profile.css` - Style utama profile
- `public/css/edit-informasi.css` - Style form edit informasi
- `public/css/ubah-foto.css` - Style upload foto
- `public/css/ubah-keamanan.css` - Style keamanan

### JavaScript Files (Copied from visual/scripts)
- `public/js/admin-profile.js` - Sidebar toggle & modal functionality
- `public/js/admin-dashboard.js` - Dashboard utilities
- `public/js/edit-informasi.js` - Form validation edit informasi
- `public/js/ubah-foto.js` - Upload & crop foto
- `public/js/ubah-keamanan.js` - Password strength & validation

### Controller Updates
- `app/Http/Controllers/AdminController.php`
  - Updated `profile()` method - load user with relations
  - Updated `editProfile()` method - pass user data
  - Updated `updateProfile()` method - handle form submission with validation
  - Updated `editPhoto()` method - pass user data
  - Updated `editSecurity()` method - pass user data

## Routes
Routes sudah terdefinisi di `routes/web.php`:
```php
Route::get('/profile', [AdminController::class, 'profile'])->name('admin.profile');
Route::get('/profile/edit', [AdminController::class, 'editProfile'])->name('admin.profile.edit');
Route::post('/profile/update', [AdminController::class, 'updateProfile'])->name('admin.profile.update');
Route::get('/profile/photo', [AdminController::class, 'editPhoto'])->name('admin.profile.photo');
Route::get('/profile/security', [AdminController::class, 'editSecurity'])->name('admin.profile.security');
```

## Features

### Profile Page
- Display user information (nama, email, telepon, alamat)
- Display mall information
- Display security status (password, 2FA, active sessions)
- Links to edit pages

### Edit Information
- Form validation (client-side & server-side)
- Real-time field validation
- Reset form functionality
- Unsaved changes warning
- Success/error notifications

### Change Photo
- Drag & drop upload
- File type & size validation (max 2MB)
- Image preview
- Rotate & crop functionality
- Remove preview option

### Security Settings
- Change password with strength indicator
- Password requirements validation
- Toggle password visibility
- 2FA setup (UI ready, backend TBD)
- Active sessions management
- Login activity log

## Usage

### Accessing Profile
```
http://localhost:8000/admin/profile
```

### Testing
1. Login sebagai admin
2. Navigate ke Profile dari sidebar
3. Test edit informasi, ubah foto, dan ubah keamanan

## Notes
- Semua CSS & JS menggunakan vanilla JavaScript (no dependencies)
- Responsive design (mobile-friendly)
- Sidebar toggle functionality included
- Form validation menggunakan HTML5 + custom JS
- Password hashing menggunakan Laravel Hash facade

## Future Enhancements
- Implement actual photo upload to storage
- Add 2FA backend implementation
- Add session management backend
- Add login activity tracking
- Add email verification for profile changes
