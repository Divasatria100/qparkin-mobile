<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('kendaraan', function (Blueprint $table) {
            $table->id('id_kendaraan');
            $table->foreignId('id_user')->nullable()->constrained('user', 'id_user');
            $table->string('plat', 20)->unique()->nullable();
            $table->enum('jenis', ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'])->nullable();
            $table->string('merk', 50)->nullable();
            $table->string('tipe', 50)->nullable();
        });
    }

    public function down()
    {
        Schema::dropIfExists('kendaraan');
    }
};