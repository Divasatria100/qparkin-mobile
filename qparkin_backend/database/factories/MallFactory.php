<?php

namespace Database\Factories;

use App\Models\Mall;
use Illuminate\Database\Eloquent\Factories\Factory;

class MallFactory extends Factory
{
    protected $model = Mall::class;

    public function definition(): array
    {
        return [
            'nama_mall' => $this->faker->company() . ' Mall',
            'alamat_lengkap' => $this->faker->address(),
            'latitude' => $this->faker->latitude(-6.5, -6.0),
            'longitude' => $this->faker->longitude(106.5, 107.0),
            'kapasitas' => rand(100, 500),
            'status' => 'active',
            'has_slot_reservation_enabled' => false,
        ];
    }
}
