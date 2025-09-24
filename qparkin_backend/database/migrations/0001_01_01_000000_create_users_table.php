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
        Schema::create('user', function (Blueprint $table) {
            $table->id('id_user'); // primary key default
            $table->string('name'); // nama user
            $table->string('no_hp', 20)->unique()->nullable();
            $table->string('email')->unique()->nullable(); // email, dipakai kalau login Google
            $table->timestamp('email_verified_at')->nullable(); // bawaan Laravel auth
            $table->string('password')->nullable(); // bisa null untuk login Google
            $table->string('provider')->nullable(); // contoh: 'google', 'email'
            $table->string('provider_id')->nullable(); // id unik dari provider
        
            // tambahan custom field
            $table->enum('role', ['customer', 'admin_mall', 'super_admin'])->default('customer');
            $table->integer('saldo_poin')->default(0);
            $table->enum('status', ['aktif', 'non-aktif'])->default('aktif');
        
            $table->rememberToken(); // untuk fitur "remember me"
            $table->timestamps(); // created_at & updated_at
        });
        

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
