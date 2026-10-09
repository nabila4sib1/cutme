<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pembayaran', function (Blueprint $table) {
            $table->id('id_bayar');

            $table->unsignedBigInteger('id_booking');

            $table->string('metode', 20);
            $table->decimal('jumlah_bayar', 10, 2);
            $table->dateTime('tgl_bayar')->useCurrent();
            $table->string('status_bayar', 20)->default('belum_lunas');

            $table->foreign('id_booking')
                ->references('id_booking')
                ->on('booking');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pembayaran');
    }
};