<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Parkiran;
use App\Models\ParkingFloor;
use App\Models\ParkingSlot;

echo "=== DEBUGGING PARKING FLOORS FOR MALL ID = 4 ===\n\n";

// Check parkiran for mall_id = 4
echo "1. Checking Parkiran for mall_id = 4:\n";
$parkiranList = Parkiran::where('id_mall', 4)->get();

if ($parkiranList->isEmpty()) {
    echo "   ❌ NO PARKIRAN FOUND for mall_id = 4\n";
    echo "   This mall has no parking areas configured.\n\n";
    exit(1);
}

foreach ($parkiranList as $parkiran) {
    echo "   ✅ Found Parkiran:\n";
    echo "      - ID: {$parkiran->id_parkiran}\n";
    echo "      - Nama: {$parkiran->nama_parkiran}\n";
    echo "      - Status: {$parkiran->status}\n";
    echo "      - Jumlah Lantai: {$parkiran->jumlah_lantai}\n";
    echo "      - Kapasitas: {$parkiran->kapasitas}\n\n";
    
    // Check floors for this parkiran
    echo "2. Checking ParkingFloors for parkiran ID = {$parkiran->id_parkiran}:\n";
    $floors = ParkingFloor::where('id_parkiran', $parkiran->id_parkiran)->get();
    
    if ($floors->isEmpty()) {
        echo "   ❌ NO FLOORS FOUND for this parkiran\n";
        echo "   This is the ROOT CAUSE of HTTP 500 error!\n\n";
        
        // Auto-generate floors based on jumlah_lantai
        echo "3. Auto-generating floors...\n";
        \DB::beginTransaction();
        try {
            $slotsPerFloor = (int)($parkiran->kapasitas / $parkiran->jumlah_lantai);
            
            for ($i = 1; $i <= $parkiran->jumlah_lantai; $i++) {
                $floor = ParkingFloor::create([
                    'id_parkiran' => $parkiran->id_parkiran,
                    'floor_name' => "Lantai {$i}",
                    'floor_number' => $i,
                    'total_slots' => $slotsPerFloor,
                    'available_slots' => $slotsPerFloor,
                    'status' => 'active',
                ]);
                
                echo "   ✅ Created Floor: {$floor->floor_name} (ID: {$floor->id_floor})\n";
                
                // Create slots for this floor
                for ($j = 1; $j <= $slotsPerFloor; $j++) {
                    ParkingSlot::create([
                        'id_floor' => $floor->id_floor,
                        'slot_code' => $parkiran->kode_parkiran . '-L' . $i . '-' . str_pad($j, 3, '0', STR_PAD_LEFT),
                        'jenis_kendaraan' => 'Roda Empat',
                        'status' => 'available',
                        'position_x' => $j,
                        'position_y' => $i,
                    ]);
                }
                echo "      - Created {$slotsPerFloor} slots\n";
            }
            
            \DB::commit();
            echo "\n   ✅ SUCCESS: Floors and slots auto-generated!\n\n";
            
            // Verify
            echo "4. Verification - Floors now available:\n";
            $floorsVerify = ParkingFloor::where('id_parkiran', $parkiran->id_parkiran)->get();
            foreach ($floorsVerify as $floor) {
                echo "   - {$floor->floor_name}: {$floor->total_slots} slots (Status: {$floor->status})\n";
            }
            
        } catch (\Exception $e) {
            \DB::rollBack();
            echo "   ❌ ERROR: " . $e->getMessage() . "\n";
        }
        
    } else {
        echo "   ✅ Found {$floors->count()} floors:\n";
        foreach ($floors as $floor) {
            $slotCount = ParkingSlot::where('id_floor', $floor->id_floor)->count();
            echo "      - {$floor->floor_name} (Floor #{$floor->floor_number})\n";
            echo "        Status: {$floor->status}\n";
            echo "        Total Slots: {$floor->total_slots}\n";
            echo "        Available Slots: {$floor->available_slots}\n";
            echo "        Actual Slot Records: {$slotCount}\n\n";
        }
    }
}

echo "\n=== DEBUG COMPLETE ===\n";
