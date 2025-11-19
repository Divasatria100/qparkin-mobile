<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\ApiAuthController;

// Public routes
Route::post('/login', [ApiAuthController::class, 'login']);
Route::post('/register', [ApiAuthController::class, 'register']);
Route::post('/google-login', [ApiAuthController::class, 'googleLogin']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [ApiAuthController::class, 'logout']);
    Route::get('/user', [ApiAuthController::class, 'getUser']);
});

// Test route untuk cek API
Route::get('/test', function () {
    return response()->json([
        'message' => 'API QParkin is working!',
        'timestamp' => now()
    ]);
});
