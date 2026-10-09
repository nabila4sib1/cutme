<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Pembayaran extends Model
{
    protected $table = 'pembayaran';

    protected $primaryKey = 'id_bayar';

    public $timestamps = false;

    protected $fillable = [
        'id_booking',
        'metode',
        'jumlah_bayar',
        'tgl_bayar',
        'status_bayar',
    ];

    public function booking(): BelongsTo
    {
        return $this->belongsTo(
            Booking::class,
            'id_booking',
            'id_booking'
        );
    }
}