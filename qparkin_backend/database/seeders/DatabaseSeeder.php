<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Jalankan seeder-seeder lain
        $this->call([
            UserSeeder::class,
            SuperAdminSeeder::class,
            MallSeeder::class,
            NotifikasiSeeder::class,
        ]);
    }
}
