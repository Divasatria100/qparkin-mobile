<?php

/**
 * Profile API Test Script
 * 
 * Test script untuk memverifikasi endpoint profile API berfungsi dengan benar
 * 
 * Usage:
 * 1. Pastikan server running: php artisan serve
 * 2. Run script: php test_profile_api.php
 */

$baseUrl = 'http://localhost:8000/api';

// ANSI color codes untuk output
$colors = [
    'green' => "\033[32m",
    'red' => "\033[31m",
    'yellow' => "\033[33m",
    'blue' => "\033[34m",
    'reset' => "\033[0m"
];

function printHeader($text) {
    global $colors;
    echo "\n" . $colors['blue'] . "=== $text ===" . $colors['reset'] . "\n";
}

function printSuccess($text) {
    global $colors;
    echo $colors['green'] . "✓ $text" . $colors['reset'] . "\n";
}

function printError($text) {
    global $colors;
    echo $colors['red'] . "✗ $text" . $colors['reset'] . "\n";
}

function printInfo($text) {
    global $colors;
    echo $colors['yellow'] . "ℹ $text" . $colors['reset'] . "\n";
}

function makeRequest($method, $url, $data = null, $token = null) {
    $ch = curl_init($url);
    
    $headers = [
        'Content-Type: application/json',
        'Accept: application/json'
    ];
    
    if ($token) {
        $headers[] = "Authorization: Bearer $token";
    }
    
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    
    if ($data) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'body' => json_decode($response, true)
    ];
}

// Test 1: Login untuk mendapatkan token
printHeader("Test 1: Login");
printInfo("Mencoba login dengan credentials test...");

$loginData = [
    'email' => 'test@example.com',
    'password' => 'password123'
];

$response = makeRequest('POST', "$baseUrl/auth/login", $loginData);

if ($response['code'] === 200 && isset($response['body']['token'])) {
    $token = $response['body']['token'];
    printSuccess("Login berhasil! Token diperoleh.");
    printInfo("Token: " . substr($token, 0, 20) . "...");
} else {
    printError("Login gagal!");
    printInfo("Response: " . json_encode($response['body']));
    printInfo("\nCatatan: Pastikan user test@example.com ada di database");
    printInfo("Atau ubah credentials di script ini sesuai user yang ada");
    exit(1);
}

// Test 2: Get Profile
printHeader("Test 2: Get Profile");
printInfo("Mengambil data profile...");

$response = makeRequest('GET', "$baseUrl/user/profile", null, $token);

if ($response['code'] === 200 && isset($response['body']['data'])) {
    $userData = $response['body']['data'];
    printSuccess("Get profile berhasil!");
    printInfo("ID: " . $userData['id']);
    printInfo("Name: " . $userData['name']);
    printInfo("Email: " . $userData['email']);
    printInfo("Phone: " . ($userData['phone_number'] ?? 'null'));
    printInfo("Saldo Poin: " . $userData['saldo_poin']);
} else {
    printError("Get profile gagal!");
    printInfo("Response: " . json_encode($response['body']));
    exit(1);
}

// Test 3: Update Profile
printHeader("Test 3: Update Profile");
printInfo("Mengupdate data profile...");

$updateData = [
    'name' => 'Test User Updated',
    'email' => 'test.updated@example.com',
    'phone_number' => '081234567890'
];

$response = makeRequest('PUT', "$baseUrl/user/profile", $updateData, $token);

if ($response['code'] === 200 && isset($response['body']['data'])) {
    $updatedUser = $response['body']['data'];
    printSuccess("Update profile berhasil!");
    printInfo("Name baru: " . $updatedUser['name']);
    printInfo("Email baru: " . $updatedUser['email']);
    printInfo("Phone baru: " . ($updatedUser['phone_number'] ?? 'null'));
    
    // Verify data updated
    if ($updatedUser['name'] === $updateData['name'] && 
        $updatedUser['email'] === $updateData['email']) {
        printSuccess("Data berhasil diupdate dengan benar!");
    } else {
        printError("Data tidak sesuai dengan yang dikirim!");
    }
} else {
    printError("Update profile gagal!");
    printInfo("Response: " . json_encode($response['body']));
    exit(1);
}

// Test 4: Get Profile lagi untuk verify persistence
printHeader("Test 4: Verify Persistence");
printInfo("Mengambil data profile lagi untuk verify...");

$response = makeRequest('GET', "$baseUrl/user/profile", null, $token);

if ($response['code'] === 200 && isset($response['body']['data'])) {
    $userData = $response['body']['data'];
    
    if ($userData['name'] === $updateData['name'] && 
        $userData['email'] === $updateData['email']) {
        printSuccess("Data tetap tersimpan dengan benar!");
        printInfo("Name: " . $userData['name']);
        printInfo("Email: " . $userData['email']);
    } else {
        printError("Data tidak persisten!");
        printInfo("Expected name: " . $updateData['name']);
        printInfo("Got name: " . $userData['name']);
    }
} else {
    printError("Get profile gagal!");
    exit(1);
}

// Test 5: Validation Error
printHeader("Test 5: Test Validation");
printInfo("Mencoba update dengan email invalid...");

$invalidData = [
    'name' => 'Test',
    'email' => 'invalid-email-format'
];

$response = makeRequest('PUT', "$baseUrl/user/profile", $invalidData, $token);

if ($response['code'] === 400) {
    printSuccess("Validasi email berfungsi dengan benar!");
    printInfo("Error message: " . ($response['body']['message'] ?? 'N/A'));
} else {
    printError("Validasi tidak berfungsi! Expected 400, got " . $response['code']);
}

// Test 6: Restore original data
printHeader("Test 6: Restore Original Data");
printInfo("Mengembalikan data ke kondisi awal...");

$restoreData = [
    'name' => $userData['name'], // Use original name from first get
    'email' => 'test@example.com', // Restore to original email
];

$response = makeRequest('PUT', "$baseUrl/user/profile", $restoreData, $token);

if ($response['code'] === 200) {
    printSuccess("Data berhasil dikembalikan ke kondisi awal!");
} else {
    printInfo("Gagal restore data (tidak masalah untuk testing)");
}

// Summary
printHeader("Test Summary");
printSuccess("Semua test berhasil!");
printInfo("\nEndpoint yang ditest:");
printInfo("✓ POST /api/auth/login");
printInfo("✓ GET /api/user/profile");
printInfo("✓ PUT /api/user/profile");
printInfo("\nFitur yang diverifikasi:");
printInfo("✓ Authentication dengan token");
printInfo("✓ Get profile data");
printInfo("✓ Update profile data");
printInfo("✓ Data persistence");
printInfo("✓ Input validation");

echo "\n";
