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
        Schema::table('booking', function (Blueprint $table) {
            // Tambah kolom id_slot dan reservation_id
            $table->foreignId('id_slot')->nullable()->after('id_transaksi')
                ->constrained('parking_slots', 'id_slot')->onDelete('set null');
            
            $table->string('reservation_id', 36)->nullable()->after('id_slot');
            
            // Index untuk performa query
            $table->index('id_slot');
            $table->index('reservation_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('booking', function (Blueprint $table) {
            // Drop foreign key dan index terlebih dahulu
            $table->dropForeign(['id_slot']);
            $table->dropIndex(['id_slot']);
            $table->dropIndex(['reservation_id']);
            
            // Drop kolom
            $table->dropColumn(['id_slot', 'reservation_id']);
        });
    }
};
