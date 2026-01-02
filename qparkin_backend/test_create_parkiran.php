<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\AdminMall;
use App\Models\Parkiran;
use App\Models\ParkingFloor;
use App\Models\ParkingSlot;

echo "=== Testing Parkiran Creation ===\n\n";

// Check if admin mall exists
$adminMall = AdminMall::first();
if (!$adminMall) {
    echo "❌ No admin mall found. Please create admin mall first.\n";
    exit(1);
}

echo "✅ Admin Mall found:\n";
echo "   - ID: {$adminMall->id_admin_mall}\n";
echo "   - Mall ID: {$adminMall->id_mall}\n\n";

// Test data
$testData = [
    'nama_parkiran' => 'Parkiran Test Mawar',
    'kode_parkiran' => 'TST',
    'status' => 'Tersedia',
    'jumlah_lantai' => 2,
    'lantai' => [
        ['nama' => 'Lantai 1', 'jumlah_slot' => 10],
        ['nama' => 'Lantai 2', 'jumlah_slot' => 8],
    ]
];

echo "📝 Creating parkiran with data:\n";
echo "   - Nama: {$testData['nama_parkiran']}\n";
echo "   - Kode: {$testData['kode_parkiran']}\n";
echo "   - Lantai: {$testData['jumlah_lantai']}\n";
echo "   - Total Slots: " . array_sum(array_column($testData['lantai'], 'jumlah_slot')) . "\n\n";

DB::beginTransaction();
try {
    // Calculate total capacity
    $totalKapasitas = collect($testData['lantai'])->sum('jumlah_slot');

    // Create parkiran
    $parkiran = Parkiran::create([
        'id_mall' => $adminMall->id_mall,
        'nama_parkiran' => $testData['nama_parkiran'],
        'kode_parkiran' => $testData['kode_parkiran'],
        'status' => $testData['status'],
        'jumlah_lantai' => $testData['jumlah_lantai'],
        'kapasitas' => $totalKapasitas,
    ]);

    echo "✅ Parkiran created: ID {$parkiran->id_parkiran}\n\n";

    // Create floors and slots
    foreach ($testData['lantai'] as $index => $lantaiData) {
        $floor = ParkingFloor::create([
            'id_parkiran' => $parkiran->id_parkiran,
            'floor_name' => $lantaiData['nama'],
            'floor_number' => $index + 1,
            'total_slots' => $lantaiData['jumlah_slot'],
            'available_slots' => $lantaiData['jumlah_slot'],
            'status' => 'active',
        ]);

        echo "✅ Floor created: {$floor->floor_name} (ID: {$floor->id_floor})\n";

        // Create slots for this floor
        $slotCodes = [];
        for ($i = 1; $i <= $lantaiData['jumlah_slot']; $i++) {
            $slotCode = $testData['kode_parkiran'] . '-L' . ($index + 1) . '-' . str_pad($i, 3, '0', STR_PAD_LEFT);
            ParkingSlot::create([
                'id_floor' => $floor->id_floor,
                'slot_code' => $slotCode,
                'jenis_kendaraan' => 'Roda Empat',
                'status' => 'available',
                'position_x' => $i,
                'position_y' => $index + 1,
            ]);
            $slotCodes[] = $slotCode;
        }

        echo "   - Created {$lantaiData['jumlah_slot']} slots: {$slotCodes[0]} to {$slotCodes[count($slotCodes)-1]}\n";
    }

    DB::commit();
    echo "\n✅ SUCCESS! Parkiran created successfully.\n\n";

    // Verify data
    echo "=== Verification ===\n";
    $parkiran = Parkiran::with('floors.slots')->find($parkiran->id_parkiran);
    echo "Parkiran: {$parkiran->nama_parkiran} ({$parkiran->kode_parkiran})\n";
    echo "Total Floors: {$parkiran->floors->count()}\n";
    $totalSlots = 0;
    foreach ($parkiran->floors as $f) {
        $totalSlots += $f->slots->count();
    }
    echo "Total Slots: {$totalSlots}\n\n";

    foreach ($parkiran->floors as $floor) {
        echo "Floor: {$floor->floor_name}\n";
        echo "  - Total Slots: {$floor->total_slots}\n";
        echo "  - Available: {$floor->available_slots}\n";
        echo "  - Sample Codes: ";
        $sampleSlots = $floor->slots->take(3)->pluck('slot_code')->toArray();
        echo implode(', ', $sampleSlots) . "\n";
    }

} catch (\Exception $e) {
    DB::rollBack();
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . "\n";
    echo "Line: " . $e->getLine() . "\n";
    exit(1);
}

echo "\n✅ All tests passed!\n";
