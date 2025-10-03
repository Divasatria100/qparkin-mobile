<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\WebAuthController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\SuperAdminController; // Tambahkan ini
use App\Http\Controllers\AdminController; // Tambahkan ini

// Halaman root langsung ke login form
Route::get('/', function () {
    return redirect()->route('login');
});

// Halaman login
Route::get('/login', [WebAuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [WebAuthController::class, 'login']);
Route::post('/logout', [WebAuthController::class, 'logout'])->name('logout');

// Pengajuan/Registrasi akun (guest only)
Route::post('/register', [RegisteredUserController::class, 'store'])
    ->middleware('guest')
    ->name('register');

// Contoh dashboard role
Route::middleware(['auth'])->group(function () {
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])
        ->name('admin.dashboard');

    Route::get('/admin/profile', [AdminController::class, 'profile'])
        ->name('admin.profile');

    Route::post('/admin/profile/update', [AdminController::class, 'update'])
        ->name('admin.profile.update');

    Route::get('/superadmin/dashboard', [SuperAdminController::class, 'dashboard'])
        ->name('superadmin.dashboard');
});