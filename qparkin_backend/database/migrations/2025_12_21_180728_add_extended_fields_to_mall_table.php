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
            // Informasi Dasar Mall
            $table->string('kode_mall', 10)->nullable()->after('nama_mall');
            $table->enum('kategori', ['super', 'premium', 'standard', 'community'])->default('standard')->after('kode_mall');
            $table->text('deskripsi')->nullable()->after('kategori');
            
            // Lokasi & Kontak
            $table->string('provinsi', 100)->nullable()->after('lokasi');
            $table->string('kota', 100)->nullable()->after('provinsi');
            $table->text('alamat_lengkap')->nullable()->after('kota');
            $table->string('kode_pos', 10)->nullable()->after('alamat_lengkap');
            $table->string('telepon', 20)->nullable()->after('kode_pos');
            $table->string('email')->nullable()->after('telepon');
            $table->string('website')->nullable()->after('email');
            
            // Konfigurasi Parkir
            $table->integer('slot_mobil')->default(0)->after('kapasitas');
            $table->integer('slot_motor')->default(0)->after('slot_mobil');
            $table->integer('slot_disabilitas')->default(0)->after('slot_motor');
            $table->integer('tarif_jam_pertama')->default(0)->after('slot_disabilitas');
            $table->integer('tarif_jam_berikutnya')->default(0)->after('tarif_jam_pertama');
            $table->integer('tarif_motor')->default(0)->after('tarif_jam_berikutnya');
            $table->integer('tarif_maksimal_harian')->nullable()->after('tarif_motor');
            
            // Pengaturan Tambahan
            $table->json('fasilitas')->nullable()->after('tarif_maksimal_harian');
            $table->string('jam_operasional', 50)->default('24jam')->after('fasilitas');
            $table->enum('status', ['active', 'inactive', 'maintenance'])->default('active')->after('jam_operasional');
            
            // Index untuk performa
            $table->index('kode_mall');
            $table->index('kategori');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('mall', function (Blueprint $table) {
            $table->dropIndex(['kode_mall']);
            $table->dropIndex(['kategori']);
            $table->dropIndex(['status']);
            
            $table->dropColumn([
                'kode_mall', 'kategori', 'deskripsi',
                'provinsi', 'kota', 'alamat_lengkap', 'kode_pos', 'telepon', 'email', 'website',
                'slot_mobil', 'slot_motor', 'slot_disabilitas',
                'tarif_jam_pertama', 'tarif_jam_berikutnya', 'tarif_motor', 'tarif_maksimal_harian',
                'fasilitas', 'jam_operasional', 'status'
            ]);
        });
    }
};