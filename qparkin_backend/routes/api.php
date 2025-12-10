<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\ApiAuthController;
use App\Http\Controllers\PointController;

// Public routes
Route::post('/login', [ApiAuthController::class, 'login']);
Route::post('/register', [ApiAuthController::class, 'register']);
Route::post('/google-login', [ApiAuthController::class, 'googleLogin']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [ApiAuthController::class, 'logout']);
    Route::get('/user', [ApiAuthController::class, 'getUser']);
    
    // Point management endpoints
    Route::prefix('points')->group(function () {
        Route::get('/balance', [PointController::class, 'getBalance']);
        Route::get('/history', [PointController::class, 'getHistory']);
        Route::get('/statistics', [PointController::class, 'getStatistics']);
        Route::post('/use', [PointController::class, 'usePoints']);
    });
});

// Test route untuk cek API
Route::get('/test', function () {
    return response()->json([
        'message' => 'API QParkin is working!',
        'timestamp' => now()
    ]);
});
