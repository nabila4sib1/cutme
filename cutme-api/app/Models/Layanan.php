<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Layanan extends Model
{
    protected $table = 'layanan';

    protected $primaryKey = 'id_layanan';

    public $timestamps = false;

    protected $fillable = [
        'nama_layanan',
        'harga',
        'durasi_menit',
    ];

    public function detailBookings(): HasMany
    {
        return $this->hasMany(
            DetailBooking::class,
            'id_layanan',
            'id_layanan'
        );
    }
}