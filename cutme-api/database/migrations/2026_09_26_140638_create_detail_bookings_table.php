<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('detail_booking', function (Blueprint $table) {
            $table->id('id_detail');

            $table->unsignedBigInteger('id_booking');
            $table->unsignedBigInteger('id_layanan');

            $table->decimal('subtotal', 10, 2);

            $table->foreign('id_booking')
                ->references('id_booking')
                ->on('booking');

            $table->foreign('id_layanan')
                ->references('id_layanan')
                ->on('layanan');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('detail_booking');
    }
};