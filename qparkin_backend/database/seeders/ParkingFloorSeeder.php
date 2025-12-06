<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ParkingFloor;
use App\Models\Parkiran;

class ParkingFloorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * 
     * Creates parking floors for all parkiran (parking areas).
     * 
     * For malls with slot reservation enabled (multi-level parking):
     * - Creates multiple floors with descriptive names
     * - Each floor has specific slot allocation
     * 
     * For malls with slot reservation disabled (simple parking):
     * - Creates single "Parkiran" floor (generic ground level)
     * - Slots will be auto-assigned during booking
     * - User doesn't see floor selection in UI
     */
    public function run(): void
    {
        // Get all parkiran
        $parkirans = Parkiran::with('mall')->get();

        foreach ($parkirans as $parkiran) {
            $mall = $parkiran->mall;
            
            // Check if mall has slot reservation enabled
            $hasSlotReservation = $mall && $mall->has_slot_reservation_enabled;
            
            if ($hasSlotReservation) {
                // MULTI-LEVEL PARKING: Create multiple floors with descriptive names
                // User can see and select floors in UI
                
                if ($parkiran->jenis_kendaraan === 'Roda Dua') {
                    // Lantai untuk motor
                    $floors = [
                        ['floor_name' => 'Lantai 1 Motor', 'floor_number' => 1, 'total_slots' => 50],
                        ['floor_name' => 'Lantai 2 Motor', 'floor_number' => 2, 'total_slots' => 50],
                    ];
                } elseif ($parkiran->jenis_kendaraan === 'Roda Empat') {
                    // Lantai untuk mobil
                    $floors = [
                        ['floor_name' => 'Basement 1', 'floor_number' => -1, 'total_slots' => 40],
                        ['floor_name' => 'Lantai 1 Mobil', 'floor_number' => 1, 'total_slots' => 40],
                        ['floor_name' => 'Lantai 2 Mobil', 'floor_number' => 2, 'total_slots' => 40],
                    ];
                } else {
                    // Default untuk jenis lain
                    $floors = [
                        ['floor_name' => 'Lantai 1', 'floor_number' => 1, 'total_slots' => 30],
                    ];
                }
            } else {
                // SIMPLE PARKING: Create single generic floor
                // User doesn't see floor selection (auto-assigned)
                // But backend still uses slot reservation to prevent overbooking
                
                if ($parkiran->jenis_kendaraan === 'Roda Dua') {
                    $floors = [
                        ['floor_name' => 'Parkiran Motor', 'floor_number' => 1, 'total_slots' => 50],
                    ];
                } elseif ($parkiran->jenis_kendaraan === 'Roda Empat') {
                    $floors = [
                        ['floor_name' => 'Parkiran Mobil', 'floor_number' => 1, 'total_slots' => 40],
                    ];
                } else {
                    $floors = [
                        ['floor_name' => 'Parkiran', 'floor_number' => 1, 'total_slots' => 30],
                    ];
                }
            }

            foreach ($floors as $floorData) {
                ParkingFloor::create([
                    'id_parkiran' => $parkiran->id_parkiran,
                    'floor_name' => $floorData['floor_name'],
                    'floor_number' => $floorData['floor_number'],
                    'total_slots' => $floorData['total_slots'],
                    'available_slots' => $floorData['total_slots'], // Initially all available
                    'status' => 'active',
                ]);
            }
        }
    }
}
