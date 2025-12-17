<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('parkiran', function (Blueprint $table) {
            if (!Schema::hasColumn('parkiran', 'nama_parkiran')) {
                $table->string('nama_parkiran')->nullable()->after('id_mall');
            }
            if (!Schema::hasColumn('parkiran', 'kode_parkiran')) {
                $table->string('kode_parkiran', 10)->nullable()->after('nama_parkiran');
            }
            if (!Schema::hasColumn('parkiran', 'jumlah_lantai')) {
                $table->integer('jumlah_lantai')->default(1)->after('kapasitas');
            }
        });
    }

    public function down()
    {
        Schema::table('parkiran', function (Blueprint $table) {
            $table->dropColumn(['nama_parkiran', 'kode_parkiran', 'jumlah_lantai']);
        });
    }
};
