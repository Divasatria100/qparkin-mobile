<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('user')->insert([
            'id_user' => 1,
            'name' => 'qparkin',
            'no_hp' => null,
            'email' => null,
            'email_verified_at' => null,
            'password' => '$2y$10$O.DkqvyLWbPzWpWQTWKko./hjUib7gdCHntOfEy4JvzuFppXcuQYu', // sudah hash bcrypt
            'provider' => null,
            'provider_id' => null,
            'role' => 'super_admin',
            'saldo_poin' => 999999,
            'status' => 'aktif',
            'remember_token' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
