<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('gerbang', function (Blueprint $table) {
            $table->id('id_gerbang');
            $table->foreignId('id_mall')->constrained('mall', 'id_mall');
            $table->string('nama_gerbang', 255);
            $table->string('lokasi', 255)->nullable();
            $table->dateTime('dibuat_pada');
        });
    }

    public function down()
    {
        Schema::dropIfExists('gerbang');
    }
};