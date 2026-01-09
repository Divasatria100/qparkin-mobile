<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('security_logs', function (Blueprint $table) {
            $table->id();
            $table->string('type')->index(); // sql_injection_attempt, xss_attempt, etc.
            $table->enum('severity', ['LOW', 'MEDIUM', 'HIGH'])->default('LOW')->index();
            $table->string('ip_address', 45)->index();
            $table->text('user_agent')->nullable();
            $table->string('url', 500);
            $table->string('method', 10);
            $table->json('payload')->nullable();
            $table->timestamp('detected_at')->index();
            $table->timestamps();
            
            // Composite indexes for common queries
            $table->index(['type', 'detected_at']);
            $table->index(['severity', 'detected_at']);
            $table->index(['ip_address', 'detected_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('security_logs');
    }
};
