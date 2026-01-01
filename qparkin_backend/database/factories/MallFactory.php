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
            'lokasi' => $this->faker->city(),
            'kapasitas' => rand(100, 500),
            'alamat_gmaps' => $this->faker->address(),
        ];
    }
}
