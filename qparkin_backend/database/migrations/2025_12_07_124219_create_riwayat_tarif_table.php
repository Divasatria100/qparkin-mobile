<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('riwayat_tarif', function (Blueprint $table) {
            $table->id('id_riwayat');
            $table->foreignId('id_tarif')->constrained('tarif_parkir', 'id_tarif')->onDelete('cascade');
            $table->foreignId('id_mall')->constrained('mall', 'id_mall')->onDelete('cascade');
            $table->unsignedBigInteger('id_user')->nullable();
            $table->string('jenis_kendaraan', 50);
            $table->decimal('tarif_lama_jam_pertama', 10, 2);
            $table->decimal('tarif_lama_per_jam', 10, 2);
            $table->decimal('tarif_baru_jam_pertama', 10, 2);
            $table->decimal('tarif_baru_per_jam', 10, 2);
            $table->text('keterangan')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('riwayat_tarif');
    }
};
