<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\ApiAuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\KendaraanController;
use App\Http\Controllers\Api\MallController;
use App\Http\Controllers\Api\ParkiranController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\UserController;

/*
|--------------------------------------------------------------------------
| API Routes - QParkin Mobile App
|--------------------------------------------------------------------------
*/

// Health Check
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'QParkin API is running',
        'timestamp' => now()
    ]);
});

// Authentication Routes
Route::prefix('auth')->group(function () {
    Route::post('/register', [ApiAuthController::class, 'register']);
    Route::post('/login', [ApiAuthController::class, 'login']);
    Route::post('/google-login', [ApiAuthController::class, 'googleLogin']);
});

// Protected Routes - Require Authentication
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [ApiAuthController::class, 'logout']);
        Route::get('/me', [ApiAuthController::class, 'getUser']);
    });

    // User Profile & Settings
    Route::prefix('user')->group(function () {
        Route::get('/profile', [UserController::class, 'profile']);
        Route::put('/profile', [UserController::class, 'updateProfile']);
        Route::put('/pin', [UserController::class, 'updatePin']);
        Route::get('/poin', [UserController::class, 'getPoin']);
        Route::get('/riwayat-poin', [UserController::class, 'getRiwayatPoin']);
    });

    // Vehicle Management
    Route::prefix('kendaraan')->group(function () {
        Route::get('/', [KendaraanController::class, 'index']);
        Route::post('/', [KendaraanController::class, 'store']);
        Route::get('/{id}', [KendaraanController::class, 'show']);
        Route::put('/{id}', [KendaraanController::class, 'update']);
        Route::delete('/{id}', [KendaraanController::class, 'destroy']);
    });

    // Mall Information
    Route::prefix('mall')->group(function () {
        Route::get('/', [MallController::class, 'index']);
        Route::get('/{id}', [MallController::class, 'show']);
        Route::get('/{id}/parkiran', [MallController::class, 'getParkiran']);
        Route::get('/{id}/tarif', [MallController::class, 'getTarif']);
    });

    // Parking Slot Availability
    Route::prefix('parkiran')->group(function () {
        Route::get('/{id}/ketersediaan', [ParkiranController::class, 'checkAvailability']);
    });

    // Booking Management
    Route::prefix('booking')->group(function () {
        Route::get('/', [BookingController::class, 'index']);
        Route::post('/', [BookingController::class, 'store']);
        Route::get('/{id}', [BookingController::class, 'show']);
        Route::put('/{id}/cancel', [BookingController::class, 'cancel']);
        Route::get('/active', [BookingController::class, 'getActive']);
    });

    // Parking Transactions
    Route::prefix('transaksi')->group(function () {
        Route::get('/', [TransaksiController::class, 'index']);
        Route::post('/masuk', [TransaksiController::class, 'masuk']);
        Route::post('/keluar', [TransaksiController::class, 'keluar']);
        Route::get('/{id}', [TransaksiController::class, 'show']);
        Route::get('/active', [TransaksiController::class, 'getActive']);
    });
});
