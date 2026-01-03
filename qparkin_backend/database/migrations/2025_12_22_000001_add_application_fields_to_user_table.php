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
        Schema::table('user', function (Blueprint $table) {
            // Status pengajuan untuk admin mall
            $table->enum('application_status', ['pending', 'approved', 'rejected'])->nullable()->after('status');
            
            // Informasi mall yang diajukan
            $table->string('requested_mall_name')->nullable()->after('application_status');
            $table->string('requested_mall_location')->nullable()->after('requested_mall_name');
            $table->text('application_notes')->nullable()->after('requested_mall_location');
            
            // Tanggal pengajuan dan review
            $table->timestamp('applied_at')->nullable()->after('application_notes');
            $table->timestamp('reviewed_at')->nullable()->after('applied_at');
            $table->unsignedBigInteger('reviewed_by')->nullable()->after('reviewed_at');
            
            // Foreign key untuk reviewer (super admin)
            $table->foreign('reviewed_by')->references('id_user')->on('user')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user', function (Blueprint $table) {
            $table->dropForeign(['reviewed_by']);
            $table->dropColumn([
                'application_status',
                'requested_mall_name', 
                'requested_mall_location',
                'application_notes',
                'applied_at',
                'reviewed_at',
                'reviewed_by'
            ]);
        });
    }
};