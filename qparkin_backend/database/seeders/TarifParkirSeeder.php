<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Mall;

class TarifParkirSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $malls = Mall::all();

        foreach ($malls as $mall) {
            $tarifs = [
                [
                    'id_mall' => $mall->id_mall,
                    'jenis_kendaraan' => 'Roda Dua',
                    'satu_jam_pertama' => 2000,
                    'tarif_parkir_per_jam' => 1000,
                ],
                [
                    'id_mall' => $mall->id_mall,
                    'jenis_kendaraan' => 'Roda Tiga',
                    'satu_jam_pertama' => 3000,
                    'tarif_parkir_per_jam' => 2000,
                ],
                [
                    'id_mall' => $mall->id_mall,
                    'jenis_kendaraan' => 'Roda Empat',
                    'satu_jam_pertama' => 5000,
                    'tarif_parkir_per_jam' => 3000,
                ],
                [
                    'id_mall' => $mall->id_mall,
                    'jenis_kendaraan' => 'Lebih dari Enam',
                    'satu_jam_pertama' => 15000,
                    'tarif_parkir_per_jam' => 8000,
                ],
            ];

            foreach ($tarifs as $tarif) {
                // Check if tarif already exists
                $exists = DB::table('tarif_parkir')
                    ->where('id_mall', $tarif['id_mall'])
                    ->where('jenis_kendaraan', $tarif['jenis_kendaraan'])
                    ->exists();

                if (!$exists) {
                    DB::table('tarif_parkir')->insert($tarif);
                }
            }
        }
    }
}
