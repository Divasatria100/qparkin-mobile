<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AdminMallSeeder extends Seeder
{
    public function run(): void
    {
        // Get first available mall
        $firstMall = \App\Models\Mall::first();
        
        if (!$firstMall) {
            $this->command->warn('No mall found. Please run MallSeeder first.');
            return;
        }
        
        // Link user id_user=3 (Admin Mall) dengan mall pertama yang tersedia
        DB::table('admin_mall')->insert([
            'id_user' => 3,
            'id_mall' => $firstMall->id_mall,
        ]);
        
        $this->command->info("Admin Mall linked to: {$firstMall->nama_mall} (ID: {$firstMall->id_mall})");
    }
}
