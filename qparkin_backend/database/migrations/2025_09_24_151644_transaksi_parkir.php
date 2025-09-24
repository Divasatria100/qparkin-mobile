<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('transaksi_parkir', function (Blueprint $table) {
            $table->id('id_transaksi');
            $table->foreignId('id_user')->nullable()->constrained('user', 'id_user');
            $table->foreignId('id_kendaraan')->nullable()->constrained('kendaraan', 'id_kendaraan');
            $table->foreignId('id_mall')->nullable()->constrained('mall', 'id_mall');
            $table->foreignId('id_parkiran')->nullable()->constrained('parkiran', 'id_parkiran');
            $table->enum('jenis_transaksi', ['umum', 'booking'])->nullable();
            $table->dateTime('waktu_masuk')->nullable();
            $table->dateTime('waktu_keluar')->nullable();
            $table->integer('durasi')->nullable();
            $table->decimal('biaya', 10, 2)->nullable();
            $table->decimal('penalty', 10, 2)->default('0.00');
        });
    }

    public function down()
    {
        Schema::dropIfExists('transaksi_parkir');
    }
};