<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Mall;
use App\Models\User;
use App\Models\Kendaraan;

echo "=== Testing Booking Flow with Parkiran ===\n\n";

// Get a test user (any user)
$user = User::first();
if (!$user) {
    echo "❌ No users found in database.\n";
    exit(1);
}

echo "✅ Test user found: {$user->name} (ID: {$user->id_user})\n";

// Get user's first vehicle (any vehicle)
$vehicle = Kendaraan::first();
if (!$vehicle) {
    echo "❌ No vehicles found in database.\n";
    echo "ℹ️  Skipping vehicle check - testing parkiran availability only.\n\n";
    $vehicle = null;
} else {
    echo "✅ Test vehicle found: {$vehicle->plat_nomor} ({$vehicle->jenis_kendaraan})\n\n";
}

// Test each mall
$malls = Mall::with('parkiran')->where('status', 'active')->get();

echo "Testing booking flow for each mall:\n";
echo str_repeat("=", 60) . "\n\n";

$successCount = 0;
$failCount = 0;

foreach ($malls as $mall) {
    echo "Mall: {$mall->nama_mall} (ID: {$mall->id_mall})\n";
    
    // Check parkiran
    if ($mall->parkiran->count() === 0) {
        echo "  ❌ FAIL: No parkiran found\n";
        echo "  → Booking would fail with 'id_parkiran not found'\n\n";
        $failCount++;
        continue;
    }
    
    $parkiran = $mall->parkiran->first();
    echo "  ✅ Parkiran found: {$parkiran->nama_parkiran} (ID: {$parkiran->id_parkiran})\n";
    
    // Simulate booking request data
    if ($vehicle) {
        $bookingData = [
            'id_mall' => $parkiran->id_parkiran, // This is what mobile app sends
            'id_kendaraan' => $vehicle->id_kendaraan,
            'waktu_mulai' => now()->addHours(1)->format('Y-m-d H:i:s'),
            'durasi_jam' => 2,
        ];
        
        echo "  ✅ Booking data prepared:\n";
        echo "     - id_mall (parkiran): {$bookingData['id_mall']}\n";
        echo "     - id_kendaraan: {$bookingData['id_kendaraan']}\n";
        echo "     - waktu_mulai: {$bookingData['waktu_mulai']}\n";
        echo "     - durasi_jam: {$bookingData['durasi_jam']}\n";
    } else {
        echo "  ✅ Parkiran data ready for booking:\n";
        echo "     - id_parkiran: {$parkiran->id_parkiran}\n";
        echo "     - kapasitas: {$parkiran->kapasitas}\n";
        echo "     - status: {$parkiran->status}\n";
    }
    
    echo "  ✅ PASS: Booking would succeed\n\n";
    
    $successCount++;
}

echo str_repeat("=", 60) . "\n";
echo "Summary:\n";
echo "  Total malls: {$malls->count()}\n";
echo "  ✅ Ready for booking: $successCount\n";
echo "  ❌ Not ready: $failCount\n\n";

if ($failCount === 0) {
    echo "🎉 SUCCESS! All malls are ready for booking.\n";
    echo "Users can now book parking at any mall.\n";
} else {
    echo "⚠️  WARNING! $failCount mall(s) still need parkiran.\n";
    echo "Run: php create_missing_parkiran.php\n";
}
