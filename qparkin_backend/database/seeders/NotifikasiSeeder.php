<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class NotifikasiSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('notifikasi')->insert([
            'id_notifikasi' => 1,
            'id_user' => 1,
            'pesan' => 'Selamat datang, qparkin! Akun Anda berhasil dibuat.',
            'waktu_kirim' => '2025-09-24 23:06:59',
            'status' => 'belum',
        ]);
    }
}
