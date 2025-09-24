<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('riwayat_gerbang', function (Blueprint $table) {
            $table->id('id_riwayat_gerbang');
            $table->foreignId('id_gerbang')->constrained('gerbang', 'id_gerbang');
            $table->enum('aksi', ['terbuka', 'tertutup'])->default('tertutup');
            $table->enum('status_sebelum', ['terbuka', 'tertutup'])->default('tertutup');
            $table->enum('status_sesudah', ['terbuka', 'tertutup'])->default('tertutup');
            $table->timestamp('dibuat_pada')->useCurrent();
        });
    }

    public function down()
    {
        Schema::dropIfExists('riwayat_gerbang');
    }
};