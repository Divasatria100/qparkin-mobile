<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('pembayaran', function (Blueprint $table) {
            $table->id('id_pembayaran');
            $table->foreignId('id_transaksi')->nullable()->constrained('transaksi_parkir', 'id_transaksi');
            $table->foreignId('id_gerbang')->constrained('gerbang', 'id_gerbang');
            $table->enum('metode', ['qris', 'tapcash', 'poin'])->nullable();
            $table->decimal('nominal', 10, 2)->nullable();
            $table->enum('status', ['pending', 'berhasil', 'gagal'])->default('pending');
            $table->dateTime('waktu_bayar')->nullable();
        });
    }

    public function down()
    {
        Schema::dropIfExists('pembayaran');
    }
};