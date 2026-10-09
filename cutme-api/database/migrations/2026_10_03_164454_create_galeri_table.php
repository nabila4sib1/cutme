<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('galeri', function (Blueprint $table) {
            $table->id('id_galeri');

            $table->unsignedBigInteger('id_kapster');

            $table->string('judul', 100);
            $table->string('foto');
            $table->dateTime('tgl_upload')->useCurrent();

            $table->foreign('id_kapster')
                ->references('id_kapster')
                ->on('kapster');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('galeri');
    }
};