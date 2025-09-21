<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\SuperAdminController;
use App\Models\User;
use App\Http\Controllers\TestErrorController;

// Testing routes (HANYA UNTUK DEVELOPMENT)
if (app()->environment('local')) {
    Route::get('/test/error/{code}', [TestErrorController::class, 'show'])
        ->where('code', '[0-9]+')
        ->name('test.error');
        
    Route::get('/test/maintenance', [TestErrorController::class, 'maintenance'])
        ->name('test.maintenance');
}

// Authentication Routes
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Protected Routes
Route::middleware('auth')->group(function () {
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
    Route::get('/superadmin/dashboard', [SuperAdminController::class, 'dashboard'])->name('superadmin.dashboard');
    
    // Redirect based on role after login
    Route::get('/', function () {
        /** @var User $user */
        $user = Auth::user();
        
        if ($user->isSuperAdmin()) {
            return redirect()->route('superadmin.dashboard');
        } elseif ($user->isAdminMall()) {
            return redirect()->route('admin.dashboard');
        }
        
        return redirect()->route('login');
    });
});