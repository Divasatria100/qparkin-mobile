<?php

echo "=== TESTING HTTP REQUEST TO /api/parking/floors/4 ===\n\n";

// First, login to get token
echo "Step 1: Getting authentication token...\n";

$loginUrl = 'http://192.168.0.101:8000/api/login';
$loginData = [
    'email' => 'user@example.com',
    'password' => 'password123'
];

$ch = curl_init($loginUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$loginResponse = curl_exec($ch);
$loginHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($loginHttpCode !== 200) {
    echo "❌ Login failed with HTTP {$loginHttpCode}\n";
    echo "Response: {$loginResponse}\n";
    echo "\nNote: Make sure the backend server is running:\n";
    echo "  php artisan serve --host=192.168.0.101\n";
    exit(1);
}

$loginData = json_decode($loginResponse, true);
if (!isset($loginData['token'])) {
    echo "❌ No token in login response\n";
    echo "Response: {$loginResponse}\n";
    exit(1);
}

$token = $loginData['token'];
echo "✅ Login successful, token obtained\n\n";

// Now test the floors endpoint
echo "Step 2: Testing GET /api/parking/floors/4...\n";

$floorsUrl = 'http://192.168.0.101:8000/api/parking/floors/4';

$ch = curl_init($floorsUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Accept: application/json'
]);

$floorsResponse = curl_exec($ch);
$floorsHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status Code: {$floorsHttpCode}\n";
echo "Response:\n";
echo $floorsResponse . "\n\n";

if ($floorsHttpCode === 200) {
    $floorsData = json_decode($floorsResponse, true);
    
    if (isset($floorsData['success']) && $floorsData['success']) {
        echo "✅ SUCCESS: Endpoint working correctly!\n";
        echo "   Floors returned: " . count($floorsData['data']) . "\n\n";
        
        if (!empty($floorsData['data'])) {
            echo "   Floor details:\n";
            foreach ($floorsData['data'] as $floor) {
                echo "   - {$floor['floor_name']} (ID: {$floor['id_floor']})\n";
                echo "     Mall ID: {$floor['id_mall']}\n";
                echo "     Slots: {$floor['available_slots']}/{$floor['total_slots']} available\n";
                echo "     Status: Available={$floor['available_slots']}, Occupied={$floor['occupied_slots']}, Reserved={$floor['reserved_slots']}\n\n";
            }
        }
        
        echo "✅ VERIFICATION COMPLETE: HTTP 500 error is FIXED!\n";
    } else {
        echo "❌ Unexpected response format\n";
    }
} else if ($floorsHttpCode === 500) {
    echo "❌ HTTP 500 ERROR: The issue is NOT fixed yet\n";
    echo "   Check storage/logs/laravel.log for details\n";
} else {
    echo "❌ Unexpected HTTP status code: {$floorsHttpCode}\n";
}

echo "\n=== TEST COMPLETE ===\n";
