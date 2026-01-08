<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

echo "=== Creating Test Pending Application ===\n\n";

// Create test user with pending application
$user = User::create([
    'name' => 'Test Admin Mall',
    'email' => 'testadmin' . time() . '@mall.com',
    'password' => Hash::make('password123'),
    'role' => 'customer',
    'status' => 'aktif',
    'application_status' => 'pending',
    'requested_mall_name' => 'Test Mall Plaza',
    'requested_mall_location' => 'Jl. Test No. 123, Jakarta',
    'application_notes' => json_encode([
        'latitude' => -6.200000,
        'longitude' => 106.816666,
        'photo_path' => 'mall_photos/test.jpg',
        'submitted_from' => 'test_script',
    ]),
    'applied_at' => now(),
]);

echo "✓ Test user created successfully!\n";
echo "ID: {$user->id_user}\n";
echo "Name: {$user->name}\n";
echo "Email: {$user->email}\n";
echo "Application Status: {$user->application_status}\n";
echo "Mall Name: {$user->requested_mall_name}\n";
echo "Applied At: {$user->applied_at}\n\n";

echo "Now check: http://localhost:8000/superadmin/pengajuan\n";
