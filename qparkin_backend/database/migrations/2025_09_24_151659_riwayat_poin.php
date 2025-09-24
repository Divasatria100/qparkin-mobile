<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('riwayat_poin', function (Blueprint $table) {
            $table->id('id_poin');
            $table->foreignId('id_user')->nullable()->constrained('user', 'id_user');
            $table->foreignId('id_transaksi')->nullable()->constrained('transaksi_parkir', 'id_transaksi');
            $table->integer('poin');
            $table->enum('perubahan', ['tambah', 'kurang'])->nullable();
            $table->string('keterangan', 255)->nullable();
            $table->dateTime('waktu')->nullable();
        });
    }

    public function down()
    {
        Schema::dropIfExists('riwayat_poin');
    }
};