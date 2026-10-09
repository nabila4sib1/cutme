<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pembayaran;
use Illuminate\Http\Request;

class PembayaranController extends Controller
{
    public function index()
    {
        $pembayaran = Pembayaran::with('booking')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data pembayaran berhasil diambil',
            'data' => $pembayaran
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_booking' => 'required|exists:booking,id_booking',
            'metode' => 'required|string|max:50',
            'jumlah_bayar' => 'required|numeric|min:0',
            'status_bayar' => 'nullable|string|max:30',
        ]);

        $pembayaran = Pembayaran::create([
            'id_booking' => $request->id_booking,
            'metode' => $request->metode,
            'jumlah_bayar' => $request->jumlah_bayar,
            'tgl_bayar' => now(),
            'status_bayar' => $request->status_bayar ?? 'belum_lunas',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil ditambahkan',
            'data' => $pembayaran
        ], 201);
    }

    public function show($id)
    {
        $pembayaran = Pembayaran::with('booking')->find($id);

        if (!$pembayaran) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data pembayaran ditemukan',
            'data' => $pembayaran
        ]);
    }

    public function update(Request $request, $id)
    {
        $pembayaran = Pembayaran::find($id);

        if (!$pembayaran) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'id_booking' => 'sometimes|required|exists:booking,id_booking',
            'metode' => 'sometimes|required|string|max:50',
            'jumlah_bayar' => 'sometimes|required|numeric|min:0',
            'status_bayar' => 'sometimes|required|string|max:30',
        ]);

        $pembayaran->update($request->only([
            'id_booking',
            'metode',
            'jumlah_bayar',
            'status_bayar'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil diubah',
            'data' => $pembayaran
        ]);
    }

    public function destroy($id)
    {
        $pembayaran = Pembayaran::find($id);

        if (!$pembayaran) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        $pembayaran->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil dihapus'
        ]);
    }
}