<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Super Admin Account
        DB::table('user')->insert([
            'id_user' => 1,
            'name' => 'qparkin',
            'nomor_hp' => null,
            'email' => null,
            'email_verified_at' => null,
            'password' => bcrypt('superadmin123'),
            'provider' => null,
            'provider_id' => null,
            'role' => 'super_admin',
            'saldo_poin' => 999999,
            'status' => 'aktif',
            'remember_token' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Customer Account
        DB::table('user')->insert([
            'id_user' => 2,
            'name' => 'berkat',
            'nomor_hp' => '082284710929',
            'email' => null,
            'email_verified_at' => null,
            'password' => '$2y$10$0sSLBbUcAVyYLCCj6FhUROrJZnqx2blRTC8HYCBoVQe3jO2CNhERm',
            'provider' => null,
            'provider_id' => null,
            'role' => 'customer',
            'saldo_poin' => 0,
            'status' => 'aktif',
            'remember_token' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Admin Mall Account
        DB::table('user')->insert([
            'id_user' => 3,
            'name' => 'adminmall',
            'nomor_hp' => '081234567890',
            'email' => 'admin@qparkin.com',
            'email_verified_at' => now(),
            'password' => bcrypt('admin123'),
            'provider' => null,
            'provider_id' => null,
            'role' => 'admin_mall',
            'saldo_poin' => 0,
            'status' => 'aktif',
            'remember_token' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
