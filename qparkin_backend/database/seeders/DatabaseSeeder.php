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
            
            // MallSeeder & AdminMallSeeder DISABLED
            // Mall data now created via Admin Mall Registration flow:
            // 1. Admin Mall registers via /signup
            // 2. SuperAdmin approves via /super/pengajuan-akun
            // 3. Mall + AdminMall records created automatically
            // MallSeeder::class,
            // AdminMallSeeder::class,
            
            TarifParkirSeeder::class,
            NotifikasiSeeder::class,
        ]);
    }
}
