<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CustomerSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('customer')->insert([
            'id_user' => '2',
            'no_hp' => '082284710929',
        ]);
    }
}
