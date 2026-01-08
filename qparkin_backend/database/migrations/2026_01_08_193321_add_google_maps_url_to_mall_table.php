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
            // Add google_maps_url column after longitude
            if (!Schema::hasColumn('mall', 'google_maps_url')) {
                $table->string('google_maps_url', 500)->nullable()->after('longitude');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            // Drop google_maps_url column if exists
            if (Schema::hasColumn('mall', 'google_maps_url')) {
                $table->dropColumn('google_maps_url');
            }
        });
    }
};
