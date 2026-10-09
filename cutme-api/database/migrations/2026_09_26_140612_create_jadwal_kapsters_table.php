<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jadwal_kapster', function (Blueprint $table) {
            $table->id('id_jadwal');

            $table->unsignedBigInteger('id_kapster');

            $table->date('tanggal');
            $table->time('jam_mulai');
            $table->time('jam_selesai');
            $table->string('status_slot', 20)->default('tersedia');

            $table->foreign('id_kapster')
                ->references('id_kapster')
                ->on('kapster');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jadwal_kapster');
    }
};