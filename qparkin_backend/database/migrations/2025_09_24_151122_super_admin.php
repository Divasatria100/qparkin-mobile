<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('super_admin', function (Blueprint $table) {
            $table->foreignId('id_user')->primary()->constrained('user', 'id_user');
            $table->string('hak_akses', 50)->nullable();
        });
    }

    public function down()
    {
        Schema::dropIfExists('super_admin');
    }
};