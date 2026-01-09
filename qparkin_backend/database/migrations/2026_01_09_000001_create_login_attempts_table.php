<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('login_attempts', function (Blueprint $table) {
            $table->id();
            $table->string('email')->index();
            $table->string('ip_address', 45);
            $table->text('user_agent')->nullable();
            $table->boolean('is_successful')->default(false);
            $table->timestamp('attempted_at')->useCurrent();
            $table->index(['email', 'attempted_at']);
        });

        Schema::create('account_lockouts', function (Blueprint $table) {
            $table->id();
            $table->string('email')->unique();
            $table->timestamp('locked_at')->useCurrent();
            $table->timestamp('locked_until');
            $table->string('reason')->default('Too many failed login attempts');
            $table->string('unlock_token', 64)->nullable()->unique();
            $table->timestamps();
            $table->index('locked_until');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('account_lockouts');
        Schema::dropIfExists('login_attempts');
    }
};
