<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class JadwalKapster extends Model
{
    protected $table = 'jadwal_kapster';

    protected $primaryKey = 'id_jadwal';

    public $timestamps = false;

    protected $fillable = [
        'id_kapster',
        'tanggal',
        'jam_mulai',
        'jam_selesai',
        'status_slot',
    ];

    public function kapster(): BelongsTo
    {
        return $this->belongsTo(
            Kapster::class,
            'id_kapster',
            'id_kapster'
        );
    }

    public function bookings()
    {
        return $this->hasMany(
            Booking::class,
            'id_jadwal',
            'id_jadwal'
        );
    }
}