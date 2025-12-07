<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\WebAuthController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\SuperAdminController;
use App\Http\Controllers\AdminController;

// Redirect root to signin - FIX TYPO
Route::get('/', function () {
    return redirect()->route('signin'); // ← HAPUS SPASI
});

// Auth Routes
Route::middleware('guest')->group(function () {
    Route::get('/signin', [WebAuthController::class, 'showLoginForm'])->name('signin');
    Route::post('/signin', [WebAuthController::class, 'login']);
    Route::get('/register', function () { 
        return view('auth.signup'); 
    })->name('register');
    Route::post('/register', [RegisteredUserController::class, 'store']);
    Route::get('/forgot-password', function () { 
        return view('auth.forgot-password'); 
    })->name('password.request');
    Route::post('/forgot-password', [WebAuthController::class, 'sendResetLink'])->name('password.email');
});

Route::post('/logout', [WebAuthController::class, 'logout'])->name('logout')->middleware('auth');

// Admin Routes
Route::middleware(['auth', 'role:admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard');
    Route::get('/profile', [AdminController::class, 'profile'])->name('profile');
    Route::get('/profile/edit', [AdminController::class, 'editProfile'])->name('profile.edit');
    Route::post('/profile/update', [AdminController::class, 'updateProfile'])->name('profile.update');
    Route::get('/profile/photo', [AdminController::class, 'editPhoto'])->name('profile.photo');
    Route::get('/profile/security', [AdminController::class, 'editSecurity'])->name('profile.security');
    
    Route::get('/notifikasi', [AdminController::class, 'notifikasi'])->name('notifikasi');
    Route::post('/notifikasi/{id}/read', [AdminController::class, 'markNotificationAsRead'])->name('notifikasi.read');
    Route::post('/notifikasi/read-all', [AdminController::class, 'markAllNotificationsAsRead'])->name('notifikasi.readAll');
    Route::delete('/notifikasi/{id}', [AdminController::class, 'deleteNotification'])->name('notifikasi.delete');
    Route::delete('/notifikasi/clear-all', [AdminController::class, 'clearAllNotifications'])->name('notifikasi.clearAll');
    
    Route::get('/tiket', [AdminController::class, 'tiket'])->name('tiket');
    Route::get('/tiket/{id}', [AdminController::class, 'tiketDetail'])->name('tiket.detail');
    Route::get('/tiket/{id}/print', [AdminController::class, 'printTicket'])->name('tiket.print');
    
    Route::get('/tarif', [AdminController::class, 'tarif'])->name('tarif');
    Route::get('/tarif/{id}/edit', [AdminController::class, 'editTarif'])->name('tarif.edit');
    Route::post('/tarif/{id}', [AdminController::class, 'updateTarif'])->name('tarif.update');
    
    Route::get('/parkiran', [AdminController::class, 'parkiran'])->name('parkiran');
    Route::get('/parkiran/create', [AdminController::class, 'createParkiran'])->name('parkiran.create');
    Route::post('/parkiran/store', [AdminController::class, 'storeParkiran'])->name('parkiran.store');
    Route::get('/parkiran/{id}', [AdminController::class, 'detailParkiran'])->name('parkiran.detail');
    Route::get('/parkiran/{id}/edit', [AdminController::class, 'editParkiran'])->name('parkiran.edit');
    Route::post('/parkiran/{id}/update', [AdminController::class, 'updateParkiran'])->name('parkiran.update');
    Route::delete('/parkiran/{id}', [AdminController::class, 'deleteParkiran'])->name('parkiran.delete');
});

// Super Admin Routes
Route::middleware(['auth', 'role:superadmin'])->prefix('superadmin')->name('superadmin.')->group(function () {
    Route::get('/dashboard', [SuperAdminController::class, 'dashboard'])->name('dashboard');
    Route::get('/profile', [SuperAdminController::class, 'profile'])->name('profile');
    Route::get('/profile/edit', [SuperAdminController::class, 'editProfile'])->name('profile.edit');
    Route::get('/profile/photo', [SuperAdminController::class, 'editPhoto'])->name('profile.photo');
    Route::get('/profile/security', [SuperAdminController::class, 'editSecurity'])->name('profile.security');
    
    Route::get('/mall', [SuperAdminController::class, 'mall'])->name('mall');
    Route::get('/mall/create', [SuperAdminController::class, 'createMall'])->name('mall.create');
    Route::get('/mall/{id}', [SuperAdminController::class, 'detailMall'])->name('mall.detail');
    Route::get('/mall/{id}/edit', [SuperAdminController::class, 'editMall'])->name('mall.edit');
    
    Route::get('/pengajuan', [SuperAdminController::class, 'pengajuan'])->name('pengajuan');
    Route::get('/pengajuan/{id}', [SuperAdminController::class, 'detailPengajuan'])->name('pengajuan.detail');
    Route::post('/pengajuan/{id}/approve', [SuperAdminController::class, 'approvePengajuan'])->name('pengajuan.approve');
    Route::post('/pengajuan/{id}/reject', [SuperAdminController::class, 'rejectPengajuan'])->name('pengajuan.reject');
    
    Route::get('/laporan', [SuperAdminController::class, 'laporan'])->name('laporan');
});