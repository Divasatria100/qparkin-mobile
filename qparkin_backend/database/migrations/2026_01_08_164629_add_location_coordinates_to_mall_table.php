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
            // Cek apakah kolom belum ada sebelum menambahkan
            if (!Schema::hasColumn('mall', 'latitude')) {
                $table->decimal('latitude', 10, 8)->nullable()->after('lokasi');
            }
            if (!Schema::hasColumn('mall', 'longitude')) {
                $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            if (Schema::hasColumn('mall', 'latitude')) {
                $table->dropColumn('latitude');
            }
            if (Schema::hasColumn('mall', 'longitude')) {
                $table->dropColumn('longitude');
            }
        });
    }
};
