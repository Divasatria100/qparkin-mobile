<?php

namespace Database\Factories;

use App\Models\TransaksiParkir;
use App\Models\User;
use App\Models\Kendaraan;
use App\Models\Mall;
use App\Models\Parkiran;
use Illuminate\Database\Eloquent\Factories\Factory;

class TransaksiParkirFactory extends Factory
{
    protected $model = TransaksiParkir::class;

    public function definition(): array
    {
        $waktuMasuk = $this->faker->dateTimeBetween('-1 month', '-1 hour');
        $waktuKeluar = $this->faker->dateTimeBetween($waktuMasuk, 'now');
        $durasi = rand(30, 300);

        return [
            'id_user' => User::factory(),
            'id_kendaraan' => Kendaraan::factory(),
            'id_mall' => Mall::factory()->state(['kapasitas' => 500]),
            'id_parkiran' => Parkiran::factory()->state(['kapasitas' => 100]),
            'id_slot' => null,
            'jenis_transaksi' => $this->faker->randomElement(['umum', 'booking']),
            'waktu_masuk' => $waktuMasuk,
            'waktu_keluar' => $waktuKeluar,
            'durasi' => $durasi,
            'biaya' => rand(5000, 50000),
            'penalty' => $this->faker->optional(0.3)->randomFloat(2, 0, 10000) ?? 0,
        ];
    }

    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'waktu_keluar' => null,
            'durasi' => null,
            'biaya' => null,
        ]);
    }

    public function completed(): static
    {
        return $this->state(fn (array $attributes) => [
            'waktu_keluar' => now(),
            'durasi' => rand(30, 300),
            'biaya' => rand(5000, 50000),
        ]);
    }
}
