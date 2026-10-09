<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('booking', function (Blueprint $table) {
            $table->id('id_booking');

            $table->unsignedBigInteger('id_pelanggan');
            $table->unsignedBigInteger('id_kapster');
            $table->unsignedBigInteger('id_jadwal');

            $table->dateTime('tgl_booking')->useCurrent();
            $table->string('status', 30)->default('menunggu_konfirmasi');
            $table->decimal('total_biaya', 10, 2)->default(0);

            $table->foreign('id_pelanggan')
                ->references('id_pelanggan')
                ->on('pelanggan');

            $table->foreign('id_kapster')
                ->references('id_kapster')
                ->on('kapster');

            $table->foreign('id_jadwal')
                ->references('id_jadwal')
                ->on('jadwal_kapster');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('booking');
    }
};