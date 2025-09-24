<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('admin_mall', function (Blueprint $table) {
            $table->foreignId('id_user')->primary()->constrained('user', 'id_user');
            $table->foreignId('id_mall')->nullable()->constrained('mall', 'id_mall');
            $table->string('hak_akses', 50)->nullable();
        });
    }

    public function down()
    {
        Schema::dropIfExists('admin_mall');
    }
};