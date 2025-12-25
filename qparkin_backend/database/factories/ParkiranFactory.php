<?php

namespace Database\Factories;

use App\Models\Parkiran;
use App\Models\Mall;
use Illuminate\Database\Eloquent\Factories\Factory;

class ParkiranFactory extends Factory
{
    protected $model = Parkiran::class;

    public function definition(): array
    {
        return [
            'id_mall' => Mall::factory(),
            'jenis_kendaraan' => $this->faker->randomElement(['Roda Dua', 'Roda Empat']),
            'kapasitas' => rand(50, 200),
            'status' => 'Tersedia',
        ];
    }
}
