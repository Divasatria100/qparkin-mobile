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
        Schema::table('parkiran', function (Blueprint $table) {
            $table->string('nama_parkiran')->nullable()->after('id_mall');
            $table->string('kode_parkiran', 10)->nullable()->after('nama_parkiran');
            $table->integer('jumlah_lantai')->default(1)->after('kapasitas');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('parkiran', function (Blueprint $table) {
            $table->dropColumn(['nama_parkiran', 'kode_parkiran', 'jumlah_lantai']);
        });
    }
};
