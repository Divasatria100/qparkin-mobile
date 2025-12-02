# QParkin Laravel Blade Views

Struktur view Laravel Blade yang telah dikonversi dari folder `visual`.

## Struktur Folder

```
resources/views/
├── layouts/
│   ├── app.blade.php           # Layout dasar untuk auth pages
│   ├── admin.blade.php         # Layout untuk admin mall
│   └── superadmin.blade.php    # Layout untuk super admin
├── partials/
│   ├── admin/
│   │   ├── header.blade.php
│   │   ├── sidebar.blade.php
│   │   └── footer.blade.php
│   └── superadmin/
│       ├── header.blade.php
│       ├── sidebar.blade.php
│       └── footer.blade.php
├── auth/
│   ├── signin.blade.php
│   ├── signup.blade.php
│   ├── forgot-password.blade.php
│   ├── success-signup.blade.php
│   └── error-signup.blade.php
├── admin/
│   ├── dashboard.blade.php
│   ├── profile.blade.php
│   ├── notifikasi.blade.php
│   ├── tiket.blade.php
│   ├── tarif.blade.php
│   └── parkiran.blade.php
└── superadmin/
    ├── dashboard.blade.php
    ├── profile.blade.php
    ├── mall.blade.php
    ├── pengajuan.blade.php
    └── laporan.blade.php
```

## Assets

### CSS
Semua file CSS dari `visual/styles/` telah disalin ke `public/css/`

### JavaScript
Semua file JS dari `visual/scripts/` telah disalin ke `public/js/`

## Routes

Routes telah dikonfigurasi di `routes/web.php`:

### Auth Routes
- `GET /login` - Halaman login
- `POST /login` - Proses login
- `GET /register` - Halaman registrasi
- `POST /register` - Proses registrasi
- `GET /forgot-password` - Halaman lupa password
- `POST /logout` - Logout

### Admin Routes (prefix: /admin)
- `GET /admin/dashboard` - Dashboard admin
- `GET /admin/profile` - Profile admin
- `GET /admin/notifikasi` - Notifikasi
- `GET /admin/tiket` - Daftar tiket
- `GET /admin/tarif` - Pengaturan tarif
- `GET /admin/parkiran` - Manajemen area parkir

### Super Admin Routes (prefix: /superadmin)
- `GET /superadmin/dashboard` - Dashboard super admin
- `GET /superadmin/profile` - Profile super admin
- `GET /superadmin/mall` - Manajemen mall
- `GET /superadmin/pengajuan` - Pengajuan akun
- `GET /superadmin/laporan` - Laporan & analitik

## Controllers

### AdminController
Menangani semua fungsi admin mall:
- Dashboard dengan statistik
- Profile management
- Tiket parkir
- Tarif parkir
- Area parkir

### SuperAdminController
Menangani semua fungsi super admin:
- Dashboard sistem
- Manajemen mall
- Approval pengajuan akun
- Laporan dan analitik

## Middleware

### CheckRole
Middleware untuk validasi role user:
- `role:admin` - Untuk admin mall
- `role:superadmin` - Untuk super admin

## Penggunaan

### Menampilkan View
```php
return view('admin.dashboard', compact('data'));
```

### Menggunakan Layout
```blade
@extends('layouts.admin')

@section('title', 'Page Title')

@section('breadcrumb')
<span>Breadcrumb</span>
@endsection

@section('content')
<!-- Content here -->
@endsection

@push('styles')
<link rel="stylesheet" href="{{ asset('css/custom.css') }}">
@endpush

@push('scripts')
<script src="{{ asset('js/custom.js') }}"></script>
@endpush
```

## Catatan

1. Semua asset (CSS/JS) sudah disalin ke folder `public/`
2. Routes sudah dikonfigurasi dengan middleware auth dan role
3. Controllers sudah dibuat dengan method dasar
4. Blade templates menggunakan Laravel helpers seperti `route()`, `asset()`, `auth()`
5. Pagination dan form validation sudah terintegrasi dengan Laravel
