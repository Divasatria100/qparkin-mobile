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
        Schema::table('transaksi_parkir', function (Blueprint $table) {
            // Tambah kolom id_slot
            $table->foreignId('id_slot')->nullable()->after('id_parkiran')
                ->constrained('parking_slots', 'id_slot')->onDelete('set null');
            
            // Index untuk performa query
            $table->index('id_slot');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('transaksi_parkir', function (Blueprint $table) {
            // Drop foreign key dan index terlebih dahulu
            $table->dropForeign(['id_slot']);
            $table->dropIndex(['id_slot']);
            
            // Drop kolom
            $table->dropColumn('id_slot');
        });
    }
};
