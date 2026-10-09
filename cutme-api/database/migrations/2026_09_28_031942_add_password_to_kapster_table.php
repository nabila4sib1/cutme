<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kapster', function (Blueprint $table) {
            $table->string('password')->nullable()->after('no_hp');
        });
    }

    public function down(): void
    {
        Schema::table('kapster', function (Blueprint $table) {
            $table->dropColumn('password');
        });
    }
};