<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Kapster extends Model
{
    protected $table = 'kapster';

    protected $primaryKey = 'id_kapster';

    public $timestamps = false;

    protected $fillable = [
        'nama',
        'no_hp',
        'password',
        'spesialisasi',
        'status_aktif',
        'foto',
    ];

    // Password TIDAK PERNAH ikut ke response JSON (GET /kapster,
    // dsb), walaupun kolomnya di-select dari database.
    protected $hidden = [
        'password',
    ];

    // foto_url otomatis ikut di setiap response JSON tanpa perlu
    // ubah controller satu-satu.
    protected $appends = ['foto_url'];

    protected $casts = [
        'status_aktif' => 'boolean',
    ];

    public function getFotoUrlAttribute(): ?string
    {
        if (!$this->foto) {
            return null;
        }

        return asset('storage/' . $this->foto);
    }

    public function jadwal(): HasMany
    {
        return $this->hasMany(
            JadwalKapster::class,
            'id_kapster',
            'id_kapster'
        );
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(
            Booking::class,
            'id_kapster',
            'id_kapster'
        );
    }

    public function galeri(): HasMany
    {
        return $this->hasMany(
            Galeri::class,
            'id_kapster',
            'id_kapster'
        );
    }
}