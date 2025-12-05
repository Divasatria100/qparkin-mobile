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
        Schema::table('mall', function (Blueprint $table) {
            // Feature flag untuk enable/disable slot reservation per mall
            $table->boolean('has_slot_reservation_enabled')->default(false)->after('alamat_gmaps');
            
            // Index untuk performa query
            $table->index('has_slot_reservation_enabled');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            $table->dropIndex(['has_slot_reservation_enabled']);
            $table->dropColumn('has_slot_reservation_enabled');
        });
    }
};
