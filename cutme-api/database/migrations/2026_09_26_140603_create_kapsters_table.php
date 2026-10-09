<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kapster', function (Blueprint $table) {
            $table->id('id_kapster');
            $table->string('nama', 100);
            $table->string('no_hp', 15);
            $table->string('spesialisasi', 100)->nullable();
            $table->boolean('status_aktif')->default(true);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kapster');
    }
};