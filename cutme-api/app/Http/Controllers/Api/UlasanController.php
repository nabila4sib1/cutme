<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ulasan;
use Illuminate\Http\Request;

class UlasanController extends Controller
{
    public function index()
    {
        $ulasan = Ulasan::with([
            'booking.kapster',
            'pelanggan'
        ])->get();

        return response()->json([
            'success' => true,
            'message' => 'Data ulasan berhasil diambil',
            'data' => $ulasan
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_booking' => 'required|exists:booking,id_booking',
            'id_pelanggan' => 'required|exists:pelanggan,id_pelanggan',
            'rating' => 'required|integer|min:1|max:5',
            'komentar' => 'nullable|string',
        ]);

        $ulasan = Ulasan::create([
            'id_booking' => $request->id_booking,
            'id_pelanggan' => $request->id_pelanggan,
            'rating' => $request->rating,
            'komentar' => $request->komentar,
            'tgl_ulasan' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil ditambahkan',
            'data' => $ulasan
        ], 201);
    }

    public function show($id)
    {
        $ulasan = Ulasan::with([
            'booking.kapster',
            'pelanggan'
        ])->find($id);

        if (!$ulasan) {
            return response()->json([
                'success' => false,
                'message' => 'Ulasan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data ulasan ditemukan',
            'data' => $ulasan
        ]);
    }

    public function update(Request $request, $id)
    {
        $ulasan = Ulasan::find($id);

        if (!$ulasan) {
            return response()->json([
                'success' => false,
                'message' => 'Ulasan tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'id_booking' => 'sometimes|required|exists:booking,id_booking',
            'id_pelanggan' => 'sometimes|required|exists:pelanggan,id_pelanggan',
            'rating' => 'sometimes|required|integer|min:1|max:5',
            'komentar' => 'nullable|string',
        ]);

        $ulasan->update($request->only([
            'id_booking',
            'id_pelanggan',
            'rating',
            'komentar'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil diubah',
            'data' => $ulasan
        ]);
    }

    public function destroy($id)
    {
        $ulasan = Ulasan::find($id);

        if (!$ulasan) {
            return response()->json([
                'success' => false,
                'message' => 'Ulasan tidak ditemukan'
            ], 404);
        }

        $ulasan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil dihapus'
        ]);
    }
}