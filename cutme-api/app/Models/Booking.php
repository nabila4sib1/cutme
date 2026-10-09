<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Booking extends Model
{
    protected $table = 'booking';

    protected $primaryKey = 'id_booking';

    public $timestamps = false;

    protected $fillable = [
        'id_pelanggan',
        'id_kapster',
        'id_jadwal',
        'tgl_booking',
        'status',
        'total_biaya',
    ];

    public function pelanggan(): BelongsTo
    {
        return $this->belongsTo(
            Pelanggan::class,
            'id_pelanggan',
            'id_pelanggan'
        );
    }

    public function kapster(): BelongsTo
    {
        return $this->belongsTo(
            Kapster::class,
            'id_kapster',
            'id_kapster'
        );
    }

    public function jadwal(): BelongsTo
    {
        return $this->belongsTo(
            JadwalKapster::class,
            'id_jadwal',
            'id_jadwal'
        );
    }

    public function detailBookings(): HasMany
    {
        return $this->hasMany(
            DetailBooking::class,
            'id_booking',
            'id_booking'
        );
    }

    public function pembayaran(): HasOne
    {
        return $this->hasOne(
            Pembayaran::class,
            'id_booking',
            'id_booking'
        );
    }

    public function ulasan(): HasOne
    {
        return $this->hasOne(
            Ulasan::class,
            'id_booking',
            'id_booking'
        );
    }
}