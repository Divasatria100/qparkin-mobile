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
        Schema::create('parking_slots', function (Blueprint $table) {
            $table->id('id_slot');
            $table->foreignId('id_floor')->constrained('parking_floors', 'id_floor')->onDelete('cascade');
            $table->string('slot_code', 20)->unique(); // e.g., "A-101", "B-205"
            $table->enum('jenis_kendaraan', ['Roda Dua', 'Roda Tiga', 'Roda Empat', 'Lebih dari Enam']);
            $table->enum('status', ['available', 'occupied', 'reserved', 'maintenance'])->default('available');
            $table->integer('position_x')->nullable(); // Koordinat X untuk visualisasi
            $table->integer('position_y')->nullable(); // Koordinat Y untuk visualisasi
            $table->timestamps();

            // Index untuk performa query
            $table->index('id_floor');
            $table->index('status');
            $table->index('jenis_kendaraan');
            $table->index(['id_floor', 'status']); // Composite index untuk query lantai + status
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('parking_slots');
    }
};
