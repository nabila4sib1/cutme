<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Layanan;
use Illuminate\Http\Request;

class LayananController extends Controller
{
    public function index()
    {
        $layanan = Layanan::all();

        return response()->json([
            'success' => true,
            'message' => 'Data layanan berhasil diambil',
            'data' => $layanan
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_layanan' => 'required|string|max:100',
            'harga' => 'required|numeric|min:0',
            'durasi_menit' => 'required|integer|min:1',
        ]);

        $layanan = Layanan::create([
            'nama_layanan' => $request->nama_layanan,
            'harga' => $request->harga,
            'durasi_menit' => $request->durasi_menit,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil ditambahkan',
            'data' => $layanan
        ], 201);
    }

    public function show($id)
    {
        $layanan = Layanan::find($id);

        if (!$layanan) {
            return response()->json([
                'success' => false,
                'message' => 'Layanan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data layanan ditemukan',
            'data' => $layanan
        ]);
    }

    public function update(Request $request, $id)
    {
        $layanan = Layanan::find($id);

        if (!$layanan) {
            return response()->json([
                'success' => false,
                'message' => 'Layanan tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama_layanan' => 'sometimes|required|string|max:100',
            'harga' => 'sometimes|required|numeric|min:0',
            'durasi_menit' => 'sometimes|required|integer|min:1',
        ]);

        $layanan->update($request->only([
            'nama_layanan',
            'harga',
            'durasi_menit'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil diubah',
            'data' => $layanan
        ]);
    }

    public function destroy($id)
    {
        $layanan = Layanan::find($id);

        if (!$layanan) {
            return response()->json([
                'success' => false,
                'message' => 'Layanan tidak ditemukan'
            ], 404);
        }

        $layanan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil dihapus'
        ]);
    }
}