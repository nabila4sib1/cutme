<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JadwalKapster;
use Illuminate\Http\Request;

class JadwalKapsterController extends Controller
{
    public function index()
    {
        $jadwal = JadwalKapster::with('kapster')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data jadwal kapster berhasil diambil',
            'data' => $jadwal
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_kapster' => 'required|exists:kapster,id_kapster',
            'tanggal' => 'required|date',
            'jam_mulai' => 'required',
            'jam_selesai' => 'required',
            'status_slot' => 'nullable|string|max:30',
        ]);

        $jadwal = JadwalKapster::create([
            'id_kapster' => $request->id_kapster,
            'tanggal' => $request->tanggal,
            'jam_mulai' => $request->jam_mulai,
            'jam_selesai' => $request->jam_selesai,
            'status_slot' => $request->status_slot ?? 'tersedia',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal kapster berhasil ditambahkan',
            'data' => $jadwal
        ], 201);
    }

    public function show($id)
    {
        $jadwal = JadwalKapster::with('kapster')->find($id);

        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal kapster tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Jadwal kapster ditemukan',
            'data' => $jadwal
        ]);
    }

    public function update(Request $request, $id)
    {
        $jadwal = JadwalKapster::find($id);

        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal kapster tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'id_kapster' => 'sometimes|required|exists:kapster,id_kapster',
            'tanggal' => 'sometimes|required|date',
            'jam_mulai' => 'sometimes|required',
            'jam_selesai' => 'sometimes|required',
            'status_slot' => 'sometimes|required|string|max:30',
        ]);

        $jadwal->update($request->only([
            'id_kapster',
            'tanggal',
            'jam_mulai',
            'jam_selesai',
            'status_slot'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Jadwal kapster berhasil diubah',
            'data' => $jadwal
        ]);
    }

    public function destroy($id)
    {
        $jadwal = JadwalKapster::find($id);

        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal kapster tidak ditemukan'
            ], 404);
        }

        $jadwal->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jadwal kapster berhasil dihapus'
        ]);
    }
}