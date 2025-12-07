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
        Schema::create('notifikasi', function (Blueprint $table) {
            $table->id('id_notifikasi');
            $table->unsignedBigInteger('id_user');
            $table->string('judul');
            $table->text('pesan');
            $table->enum('kategori', ['system', 'parking', 'payment', 'security', 'maintenance', 'report'])->default('system');
            $table->enum('status', ['belum', 'sudah'])->default('belum');
            $table->timestamp('dibaca_pada')->nullable();
            $table->timestamps();

            $table->foreign('id_user')->references('id_user')->on('user')->onDelete('cascade');
            $table->index(['id_user', 'status']);
            $table->index('kategori');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifikasi');
    }
};
