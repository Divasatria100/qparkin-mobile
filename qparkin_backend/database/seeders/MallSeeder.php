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
                'alamat_lengkap' => 'Jl. Engku Putri no.1, Batam Centre',
                'latitude' => 1.11910000,
                'longitude' => 104.04510000,
                'kapasitas' => 200,
                'alamat_gmaps' => 'Jl. Engku Putri no.1, Batam Centre',
                'status' => 'active',
                'has_slot_reservation_enabled' => true,
            ],
            [
                'nama_mall' => 'One Batam Mall',
                'alamat_lengkap' => 'Jl. Raja H. Fisabilillah No. 9, Batam Center',
                'latitude' => 1.12050000,
                'longitude' => 104.04380000,
                'kapasitas' => 150,
                'alamat_gmaps' => 'Jl. Raja H. Fisabilillah No. 9, Batam Center',
                'status' => 'active',
                'has_slot_reservation_enabled' => true,
            ],
            [
                'nama_mall' => 'SNL Food Bengkong',
                'alamat_lengkap' => 'Garden Avenue Square, Bengkong, Batam',
                'latitude' => 1.13200000,
                'longitude' => 104.01500000,
                'kapasitas' => 100,
                'alamat_gmaps' => 'Garden Avenue Square, Bengkong, Batam',
                'status' => 'active',
                'has_slot_reservation_enabled' => false,
            ],
        ];

        DB::table('mall')->insert($malls);
    }
}
