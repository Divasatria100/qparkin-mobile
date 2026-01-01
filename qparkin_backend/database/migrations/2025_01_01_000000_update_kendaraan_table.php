<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * Menambahkan field tambahan untuk modul kendaraan mobile app:
     * - warna: warna kendaraan (opsional)
     * - foto_path: path foto kendaraan di storage (opsional)
     * - is_active: status kendaraan aktif (untuk kendaraan utama)
     * - created_at: waktu kendaraan ditambahkan
     * - updated_at: waktu terakhir diupdate
     * - last_used_at: waktu terakhir digunakan untuk parkir (HANYA diupdate oleh sistem parkir)
     * 
     * CATATAN: Migration ini HANYA menambah kolom, TIDAK mengubah struktur existing
     */
    public function up()
    {
        // Cek apakah kolom sudah ada untuk menghindari error saat re-run migration
        if (!Schema::hasColumn('kendaraan', 'warna')) {
            Schema::table('kendaraan', function (Blueprint $table) {
                // Field tambahan - hanya menambah, tidak mengubah existing
                $table->string('warna', 50)->nullable()->after('tipe');
                $table->string('foto_path')->nullable()->after('warna');
                $table->boolean('is_active')->default(false)->after('foto_path');
                
                // Timestamps - Laravel standard
                $table->timestamp('created_at')->nullable()->after('is_active');
                $table->timestamp('updated_at')->nullable()->after('created_at');
                $table->timestamp('last_used_at')->nullable()->after('updated_at')
                    ->comment('Diupdate oleh sistem parkir, bukan manual');
                
                // Index untuk performa query
                $table->index(['id_user', 'is_active'], 'idx_user_active');
                $table->index('plat', 'idx_plat');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down()
    {
        Schema::table('kendaraan', function (Blueprint $table) {
            // Drop indexes first
            $table->dropIndex('idx_user_active');
            $table->dropIndex('idx_plat');
            
            // Drop columns
            $table->dropColumn([
                'warna',
                'foto_path',
                'is_active',
                'created_at',
                'updated_at',
                'last_used_at'
            ]);
        });
    }
};
