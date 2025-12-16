<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AdminMallSeeder extends Seeder
{
    public function run(): void
    {
        // Link user id_user=3 (Admin Mall) dengan mall id_mall=1
        DB::table('admin_mall')->insert([
            'id_user' => 3,
            'id_mall' => 1, // Pastikan mall dengan id=1 sudah ada dari MallSeeder
        ]);
    }
}
