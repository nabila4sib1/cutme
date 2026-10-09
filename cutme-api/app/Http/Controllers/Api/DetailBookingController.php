<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DetailBooking;
use Illuminate\Http\Request;

class DetailBookingController extends Controller
{
    public function index()
    {
        $detail = DetailBooking::with([
            'booking',
            'layanan'
        ])->get();

        return response()->json([
            'success' => true,
            'message' => 'Data detail booking berhasil diambil',
            'data' => $detail
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_booking' => 'required|exists:booking,id_booking',
            'id_layanan' => 'required|exists:layanan,id_layanan',
            'subtotal' => 'required|numeric|min:0',
        ]);

        $detail = DetailBooking::create([
            'id_booking' => $request->id_booking,
            'id_layanan' => $request->id_layanan,
            'subtotal' => $request->subtotal,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Detail booking berhasil ditambahkan',
            'data' => $detail
        ], 201);
    }

    public function show($id)
    {
        $detail = DetailBooking::with([
            'booking',
            'layanan'
        ])->find($id);

        if (!$detail) {
            return response()->json([
                'success' => false,
                'message' => 'Detail booking tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail booking ditemukan',
            'data' => $detail
        ]);
    }

    public function update(Request $request, $id)
    {
        $detail = DetailBooking::find($id);

        if (!$detail) {
            return response()->json([
                'success' => false,
                'message' => 'Detail booking tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'id_booking' => 'sometimes|required|exists:booking,id_booking',
            'id_layanan' => 'sometimes|required|exists:layanan,id_layanan',
            'subtotal' => 'sometimes|required|numeric|min:0',
        ]);

        $detail->update($request->only([
            'id_booking',
            'id_layanan',
            'subtotal'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Detail booking berhasil diubah',
            'data' => $detail
        ]);
    }

    public function destroy($id)
    {
        $detail = DetailBooking::find($id);

        if (!$detail) {
            return response()->json([
                'success' => false,
                'message' => 'Detail booking tidak ditemukan'
            ], 404);
        }

        $detail->delete();

        return response()->json([
            'success' => true,
            'message' => 'Detail booking berhasil dihapus'
        ]);
    }
}