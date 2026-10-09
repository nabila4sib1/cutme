<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Galeri extends Model
{
    protected $table = 'galeri';

    protected $primaryKey = 'id_galeri';

    public $timestamps = false;

    protected $fillable = [
        'id_kapster',
        'judul',
        'foto',
        'tgl_upload',
    ];

    // foto_url otomatis ikut di setiap response JSON (index,
    // show, dst) tanpa perlu ubah controller satu-satu.
    protected $appends = ['foto_url'];

    public function getFotoUrlAttribute(): ?string
    {
        if (!$this->foto) {
            return null;
        }

        return asset('storage/' . $this->foto);
    }

    public function kapster(): BelongsTo
    {
        return $this->belongsTo(
            Kapster::class,
            'id_kapster',
            'id_kapster'
        );
    }
}