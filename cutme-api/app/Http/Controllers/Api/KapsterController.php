<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kapster;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class KapsterController extends Controller
{
    public function index()
    {
        $kapster = Kapster::all();

        return response()->json([
            'success' => true,
            'message' => 'Data kapster berhasil diambil',
            'data' => $kapster
        ]);
    }

    public function show($id)
    {
        $kapster = Kapster::find($id);

        if (!$kapster) {
            return response()->json([
                'success' => false,
                'message' => 'Kapster tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data kapster ditemukan',
            'data' => $kapster
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:100',
            'no_hp' => 'required|string|max:20|unique:kapster,no_hp',
            'password' => 'required|string|min:6',
            'spesialisasi' => 'nullable|string|max:100',
            'status_aktif' => 'boolean',
        ]);

        $kapster = Kapster::create([
            'nama' => $request->nama,
            'no_hp' => $request->no_hp,
            'password' => Hash::make($request->password),
            'spesialisasi' => $request->spesialisasi,
            'status_aktif' => $request->has('status_aktif')
                ? $request->status_aktif
                : true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kapster berhasil ditambahkan',
            'data' => $kapster
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $kapster = Kapster::find($id);

        if (!$kapster) {
            return response()->json([
                'success' => false,
                'message' => 'Kapster tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama' => 'sometimes|required|string|max:100',
            'no_hp' => 'sometimes|required|string|max:20|unique:kapster,no_hp,' . $id . ',id_kapster',
            // password OPSIONAL saat update: kalau field ini tidak
            // dikirim/kosong, password lama tetap dipakai (tidak
            // di-reset).
            'password' => 'sometimes|nullable|string|min:6',
            'spesialisasi' => 'nullable|string|max:100',
            'status_aktif' => 'sometimes|boolean',
        ]);

        $data = $request->only([
            'nama',
            'no_hp',
            'spesialisasi',
            'status_aktif',
        ]);

        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $kapster->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Kapster berhasil diubah',
            'data' => $kapster
        ]);
    }

    // POST /api/kapster/{id}/foto (multipart/form-data, field "foto")
    public function uploadFoto(Request $request, $id)
    {
        $kapster = Kapster::find($id);

        if (!$kapster) {
            return response()->json([
                'success' => false,
                'message' => 'Kapster tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'foto' => 'required|image|max:2048', // max 2MB
        ]);

        // Hapus foto lama kalau ada, biar storage tidak numpuk
        // file yang sudah tidak terpakai.
        if ($kapster->foto) {
            Storage::disk('public')->delete($kapster->foto);
        }

        $path = $request->file('foto')->store('kapster', 'public');

        $kapster->update(['foto' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'Foto kapster berhasil diperbarui',
            'data' => $kapster
        ]);
    }

    public function destroy($id)
    {
        $kapster = Kapster::find($id);

        if (!$kapster) {
            return response()->json([
                'success' => false,
                'message' => 'Kapster tidak ditemukan'
            ], 404);
        }

        if ($kapster->foto) {
            Storage::disk('public')->delete($kapster->foto);
        }

        $kapster->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kapster berhasil dihapus'
        ]);
    }
}