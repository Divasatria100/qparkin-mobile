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
        Schema::create('parking_floors', function (Blueprint $table) {
            $table->id('id_floor');
            $table->foreignId('id_parkiran')->constrained('parkiran', 'id_parkiran')->onDelete('cascade');
            $table->string('floor_name', 50); // e.g., "Lantai 1", "Basement 2"
            $table->integer('floor_number'); // 1, 2, 3, -1 (basement), etc.
            $table->integer('total_slots')->default(0); // Total slots di lantai ini
            $table->integer('available_slots')->default(0); // Slots yang tersedia
            $table->enum('status', ['active', 'inactive', 'maintenance'])->default('active');
            $table->timestamps();

            // Index untuk performa query
            $table->index('id_parkiran');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('parking_floors');
    }
};
