<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('parkiran', function (Blueprint $table) {
            $table->id('id_parkiran');
            $table->foreignId('id_mall')->nullable()->constrained('mall', 'id_mall');
            $table->enum('jenis_kendaraan', ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'])->nullable();
            $table->integer('kapasitas')->nullable();
            $table->enum('status', ['Tersedia', 'Ditutup'])->default('Tersedia');
        });
    }

    public function down()
    {
        Schema::dropIfExists('parkiran');
    }
};