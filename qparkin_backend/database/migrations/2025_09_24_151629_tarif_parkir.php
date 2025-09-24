<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('tarif_parkir', function (Blueprint $table) {
            $table->id('id_tarif');
            $table->foreignId('id_mall')->nullable()->constrained('mall', 'id_mall');
            $table->enum('jenis_kendaraan', ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'])->nullable();
            $table->decimal('satu_jam_pertama', 10, 2)->nullable();
            $table->decimal('tarif_parkir_per_jam', 10, 2)->nullable();
        });
    }

    public function down()
    {
        Schema::dropIfExists('tarif_parkir');
    }
};