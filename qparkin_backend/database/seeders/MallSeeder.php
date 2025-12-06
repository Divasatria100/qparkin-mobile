<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MallSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * Seed mall data with slot reservation feature flag enabled for testing.
     */
    public function run(): void
    {
        $malls = [
            [
                'nama_mall' => 'Mega Mall Batam Centre',
                'lokasi' => 'Batam Centre',
                'kapasitas' => 200,
                'alamat_gmaps' => 'Jl. Engku Putri no.1, Batam Centre',
                'has_slot_reservation_enabled' => true, // Enable slot reservation
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama_mall' => 'One Batam Mall',
                'lokasi' => 'Batam Center',
                'kapasitas' => 150,
                'alamat_gmaps' => 'Jl. Raja H. Fisabilillah No. 9, Batam Center',
                'has_slot_reservation_enabled' => true, // Enable slot reservation
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama_mall' => 'SNL Food Bengkong',
                'lokasi' => 'Bengkong',
                'kapasitas' => 100,
                'alamat_gmaps' => 'Garden Avenue Square, Bengkong, Batam',
                'has_slot_reservation_enabled' => false, // Disable for testing gradual rollout
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('mall')->insert($malls);
    }
}
