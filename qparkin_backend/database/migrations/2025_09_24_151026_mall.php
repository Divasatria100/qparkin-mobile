<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('mall', function (Blueprint $table) {
            $table->id('id_mall');
            $table->string('nama_mall', 100)->nullable();
            $table->string('lokasi', 255)->nullable();
            $table->integer('kapasitas')->nullable();
            $table->string('alamat_gmaps', 255)->nullable();
        });
    }

    public function down()
    {
        Schema::dropIfExists('mall');
    }
};