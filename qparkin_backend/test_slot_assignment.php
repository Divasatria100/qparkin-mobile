<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Services\SlotAutoAssignmentService;
use App\Models\Kendaraan;
use Carbon\Carbon;

echo "=== Testing Slot Auto Assignment ===\n\n";

// Test parameters from error log
$idParkiran = 1;
$idKendaraan = 2;
$idUser = 5; // Assuming user ID 5
$waktuMulai = '2026-01-15 18:30:00';
$durasiBooking = 1;

echo "Test Parameters:\n";
echo "  - Parkiran ID: {$idParkiran}\n";
echo "  - Kendaraan ID: {$idKendaraan}\n";
echo "  - User ID: {$idUser}\n";
echo "  - Waktu Mulai: {$waktuMulai}\n";
echo "  - Durasi: {$durasiBooking} jam\n\n";

// Get vehicle info
$kendaraan = Kendaraan::find($idKendaraan);
if (!$kendaraan) {
    echo "❌ Vehicle not found!\n";
    exit(1);
}

echo "Vehicle Info:\n";
echo "  - Plat: {$kendaraan->plat}\n";
echo "  - Jenis: {$kendaraan->jenis}\n\n";

// Try to assign slot
echo "Attempting slot assignment...\n";
$service = new SlotAutoAssignmentService();

try {
    $slotId = $service->assignSlot(
        $idParkiran,
        $idKendaraan,
        $idUser,
        $waktuMulai,
        $durasiBooking
    );
    
    if ($slotId) {
        echo "✅ SUCCESS! Assigned slot ID: {$slotId}\n";
    } else {
        echo "❌ FAILED! No slot assigned (returned null)\n";
        echo "\nPossible reasons:\n";
        echo "1. No floors found for parkiran\n";
        echo "2. No slots match vehicle type\n";
        echo "3. All matching slots are reserved\n";
        echo "4. Vehicle type mismatch between kendaraan.jenis and parking_slots.jenis_kendaraan\n";
    }
} catch (\Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
