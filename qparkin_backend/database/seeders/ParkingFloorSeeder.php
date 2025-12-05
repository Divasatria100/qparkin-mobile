<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ParkingFloor;
use App\Models\Parkiran;

class ParkingFloorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get all parkiran
        $parkirans = Parkiran::all();

        foreach ($parkirans as $parkiran) {
            // Create floors based on vehicle type
            // Untuk contoh, kita buat 3 lantai per parkiran
            
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
