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
        Schema::create('slot_reservations', function (Blueprint $table) {
            $table->id('id_reservation');
            $table->string('reservation_id', 36)->unique(); // UUID untuk tracking
            $table->foreignId('id_slot')->constrained('parking_slots', 'id_slot')->onDelete('cascade');
            $table->foreignId('id_user')->constrained('user', 'id_user')->onDelete('cascade');
            $table->foreignId('id_kendaraan')->constrained('kendaraan', 'id_kendaraan')->onDelete('cascade');
            $table->foreignId('id_floor')->constrained('parking_floors', 'id_floor')->onDelete('cascade');
            $table->enum('status', ['active', 'confirmed', 'expired', 'cancelled'])->default('active');
            $table->timestamp('reserved_at')->useCurrent();
            $table->timestamp('expires_at'); // 5 menit dari reserved_at
            $table->timestamp('confirmed_at')->nullable(); // Saat booking dikonfirmasi
            $table->timestamps();

            // Index untuk performa query
            $table->index('reservation_id');
            $table->index('id_user');
            $table->index('id_slot');
            $table->index('status');
            $table->index('expires_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('slot_reservations');
    }
};
