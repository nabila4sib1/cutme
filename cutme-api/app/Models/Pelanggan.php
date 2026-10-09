<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Pelanggan extends Model
{
    protected $table = 'pelanggan';

    protected $primaryKey = 'id_pelanggan';

    public $timestamps = false;

    protected $fillable = [
        'nama',
        'no_hp',
        'email',
        'password',
    ];

    // Password TIDAK PERNAH ikut ke response JSON.
    protected $hidden = [
        'password',
    ];

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class, 'id_pelanggan', 'id_pelanggan');
    }

    public function ulasans(): HasMany
    {
        return $this->hasMany(Ulasan::class, 'id_pelanggan', 'id_pelanggan');
    }
}