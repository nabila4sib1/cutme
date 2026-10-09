<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kapster', function (Blueprint $table) {
            // Simpan path relatif (mis. 'kapster/abc123.jpg'),
            // bukan URL penuh. URL penuhnya dibentuk di accessor
            // model Kapster::getFotoUrlAttribute().
            $table->string('foto')->nullable()->after('spesialisasi');
        });
    }

    public function down(): void
    {
        Schema::table('kapster', function (Blueprint $table) {
            $table->dropColumn('foto');
        });
    }
};