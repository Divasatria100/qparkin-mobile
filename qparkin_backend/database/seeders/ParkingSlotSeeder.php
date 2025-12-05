<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ParkingSlot;
use App\Models\ParkingFloor;

class ParkingSlotSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $floors = ParkingFloor::all();

        foreach ($floors as $floor) {
            $jenisKendaraan = $floor->parkiran->jenis_kendaraan;
            $totalSlots = $floor->total_slots;
            
            // Generate slot codes based on floor
            $prefix = $this->getSlotPrefix($floor->floor_number);
            
            // Create slots in grid layout
            $slotsPerRow = 10;
            $rows = ceil($totalSlots / $slotsPerRow);
            
            $slotNumber = 1;
            for ($row = 0; $row < $rows; $row++) {
                for ($col = 0; $col < $slotsPerRow && $slotNumber <= $totalSlots; $col++) {
                    $slotCode = sprintf('%s-%03d', $prefix, $slotNumber);
                    
                    ParkingSlot::create([
                        'id_floor' => $floor->id_floor,
                        'slot_code' => $slotCode,
                        'jenis_kendaraan' => $jenisKendaraan,
                        'status' => 'available',
                        'position_x' => $col,
                        'position_y' => $row,
                    ]);
                    
                    $slotNumber++;
                }
            }
        }
    }

    /**
     * Get slot prefix based on floor number
     */
    private function getSlotPrefix(int $floorNumber): string
    {
        if ($floorNumber < 0) {
            return 'B' . abs($floorNumber); // B1, B2 for basement
        }
        
        // A, B, C, D for floors 1, 2, 3, 4
        $letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
        return $letters[$floorNumber - 1] ?? 'Z';
    }
}
