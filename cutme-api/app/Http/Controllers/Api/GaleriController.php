<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Galeri;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class GaleriController extends Controller
{
    // GET /api/galeri
    // Opsional: ?id_kapster=1 (hanya foto milik kapster itu)
    public function index(Request $request)
    {
        $query = Galeri::with('kapster');

        if ($request->filled('id_kapster')) {
            $query->where('id_kapster', $request->id_kapster);
        }

        $galeri = $query->orderByDesc('tgl_upload')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data galeri berhasil diambil',
            'data' => $galeri
        ]);
    }

    // POST /api/galeri (multipart/form-data)
    // field: id_kapster, judul, foto
    public function store(Request $request)
    {
        $request->validate([
            'id_kapster' => 'required|exists:kapster,id_kapster',
            'judul' => 'required|string|max:100',
            'foto' => 'required|image|max:2048', // max 2MB
        ]);

        $path = $request->file('foto')->store('galeri', 'public');

        $galeri = Galeri::create([
            'id_kapster' => $request->id_kapster,
            'judul' => $request->judul,
            'foto' => $path,
            'tgl_upload' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Foto berhasil diunggah',
            'data' => $galeri
        ], 201);
    }

    public function destroy($id)
    {
        $galeri = Galeri::find($id);

        if (!$galeri) {
            return response()->json([
                'success' => false,
                'message' => 'Galeri tidak ditemukan'
            ], 404);
        }

        if ($galeri->foto) {
            Storage::disk('public')->delete($galeri->foto);
        }

        $galeri->delete();

        return response()->json([
            'success' => true,
            'message' => 'Foto berhasil dihapus'
        ]);
    }
}