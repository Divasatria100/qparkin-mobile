<?php

namespace Database\Factories;

use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class NotifikasiFactory extends Factory
{
    protected $model = Notifikasi::class;

    public function definition(): array
    {
        return [
            'id_user' => User::factory(),
            'pesan' => $this->faker->paragraph(),
            'waktu_kirim' => $this->faker->dateTimeBetween('-1 week', 'now'),
            'status' => $this->faker->randomElement(['belum', 'terbaca']),
        ];
    }

    public function unread(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'belum',
        ]);
    }

    public function read(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'terbaca',
        ]);
    }
}
