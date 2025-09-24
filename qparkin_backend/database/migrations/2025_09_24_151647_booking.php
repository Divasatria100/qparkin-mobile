<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('booking', function (Blueprint $table) {
            $table->foreignId('id_transaksi')->primary()->constrained('transaksi_parkir', 'id_transaksi');
            $table->dateTime('waktu_mulai')->nullable();
            $table->dateTime('waktu_selesai')->nullable();
            $table->integer('durasi_booking')->nullable();
            $table->enum('status', ['aktif', 'selesai', 'expired'])->default('aktif');
            $table->dateTime('dibooking_pada')->useCurrent();
        });
    }

    public function down()
    {
        Schema::dropIfExists('booking');
    }
};