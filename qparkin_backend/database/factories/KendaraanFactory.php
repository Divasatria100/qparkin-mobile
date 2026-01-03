<?php

namespace Database\Factories;

use App\Models\Kendaraan;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class KendaraanFactory extends Factory
{
    protected $model = Kendaraan::class;

    public function definition(): array
    {
        return [
            'id_user' => User::factory(),
            'plat' => strtoupper($this->faker->bothify('? #### ??')),
            'jenis' => $this->faker->randomElement(['Roda Dua', 'Roda Empat']),
            'merk' => $this->faker->randomElement(['Honda', 'Toyota', 'Yamaha', 'Suzuki', 'Daihatsu']),
            'tipe' => $this->faker->word(),
        ];
    }
}
