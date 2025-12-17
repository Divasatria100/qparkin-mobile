<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ParkingSlot;
use App\Models\ParkingFloor;

class ParkingSlotSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * 
     * Creates parking slots for all floors.
     * 
     * For malls with slot reservation enabled (multi-level parking):
     * - Creates slots with descriptive codes (A-001, B-001, etc.)
     * - Slots are visible in UI for user selection
     * 
     * For malls with slot reservation disabled (simple parking):
     * - Creates slots with generic codes (SLOT-001, SLOT-002, etc.)
     * - Slots are NOT visible in UI (auto-assigned by system)
     * - But still used internally to prevent overbooking
     */
    public function run(): void
    {
        $floors = ParkingFloor::with('parkiran.mall')->get();

        foreach ($floors as $floor) {
            $jenisKendaraan = $floor->parkiran->jenis_kendaraan;
            $totalSlots = $floor->total_slots;
            $mall = $floor->parkiran->mall;
            
            // Check if mall has slot reservation enabled
            $hasSlotReservation = $mall && $mall->has_slot_reservation_enabled;
            
            if ($hasSlotReservation) {
                // MULTI-LEVEL PARKING: Descriptive slot codes
                // User can see these codes in UI (A-001, B-015, etc.)
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
            } else {
                // SIMPLE PARKING: Generic slot codes
                // User doesn't see these codes (auto-assigned)
                // Format: SLOT-001, SLOT-002, etc.
                
                for ($i = 1; $i <= $totalSlots; $i++) {
                    $slotCode = sprintf('SLOT-%03d', $i);
                    
                    ParkingSlot::create([
                        'id_floor' => $floor->id_floor,
                        'slot_code' => $slotCode,
                        'jenis_kendaraan' => $jenisKendaraan,
                        'status' => 'available',
                        'position_x' => null, // No grid position needed
                        'position_y' => null, // No grid position needed
                    ]);
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
