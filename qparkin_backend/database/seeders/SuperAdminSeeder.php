<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('super_admin')->insert([
            'id_user' => 1,
            'hak_akses' => 'developer',
        ]);
    }
}
