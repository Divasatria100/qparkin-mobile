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
            // Drop lokasi column as it's no longer used
            // We now use google_maps_url for initial registration
            // and latitude/longitude for precise coordinates
            if (Schema::hasColumn('mall', 'lokasi')) {
                $table->dropColumn('lokasi');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            // Restore lokasi column if migration is rolled back
            if (!Schema::hasColumn('mall', 'lokasi')) {
                $table->string('lokasi', 255)->nullable()->after('nama_mall');
            }
        });
    }
};
