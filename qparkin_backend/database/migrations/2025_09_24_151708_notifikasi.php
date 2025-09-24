<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('notifikasi', function (Blueprint $table) {
            $table->id('id_notifikasi');
            $table->foreignId('id_user')->nullable()->constrained('user', 'id_user');
            $table->text('pesan')->nullable();
            $table->dateTime('waktu_kirim')->nullable();
            $table->enum('status', ['terbaca', 'belum'])->default('belum');
        });
    }

    public function down()
    {
        Schema::dropIfExists('notifikasi');
    }
};