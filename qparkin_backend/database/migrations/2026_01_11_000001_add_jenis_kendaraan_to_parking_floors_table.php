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
        Schema::table('parking_floors', function (Blueprint $table) {
            $table->enum('jenis_kendaraan', ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam'])
                  ->after('floor_number')
                  ->nullable()
                  ->comment('Jenis kendaraan yang diizinkan di lantai ini');
            
            // Add index for filtering by vehicle type
            $table->index('jenis_kendaraan');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('parking_floors', function (Blueprint $table) {
            $table->dropIndex(['jenis_kendaraan']);
            $table->dropColumn('jenis_kendaraan');
        });
    }
};
