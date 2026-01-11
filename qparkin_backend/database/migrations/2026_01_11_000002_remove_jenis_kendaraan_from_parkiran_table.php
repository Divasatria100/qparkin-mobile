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
            // Remove jenis_kendaraan from parkiran table
            // Vehicle type should be determined per floor, not per parkiran
            $table->dropColumn('jenis_kendaraan');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('parkiran', function (Blueprint $table) {
            $table->enum('jenis_kendaraan', ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'])
                  ->nullable()
                  ->after('kode_parkiran');
        });
    }
};
