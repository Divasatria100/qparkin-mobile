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
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

    Route::get('/admin/dashboard', function () {
        return view('admin.dashboard');
    })->name('admin.dashboard');

    // PERBAIKI INI: Gunakan Controller, bukan Closure
    Route::get('/superadmin/dashboard', [SuperAdminController::class, 'dashboard'])
        ->name('superadmin.dashboard');
});