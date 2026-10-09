<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ulasan', function (Blueprint $table) {
            $table->id('id_ulasan');

            $table->unsignedBigInteger('id_booking');
            $table->unsignedBigInteger('id_pelanggan');

            $table->integer('rating');
            $table->text('komentar')->nullable();
            $table->dateTime('tgl_ulasan')->useCurrent();

            $table->foreign('id_booking')
                ->references('id_booking')
                ->on('booking');

            $table->foreign('id_pelanggan')
                ->references('id_pelanggan')
                ->on('pelanggan');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ulasan');
    }
};