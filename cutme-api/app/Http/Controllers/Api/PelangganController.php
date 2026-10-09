<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pelanggan;
use Illuminate\Http\Request;

class PelangganController extends Controller
{
    // Menampilkan semua pelanggan
    public function index()
    {
        $pelanggan = Pelanggan::all();

        return response()->json([
            'success' => true,
            'message' => 'Data pelanggan berhasil diambil',
            'data' => $pelanggan
        ]);
    }

    // Menampilkan satu pelanggan
    public function show($id)
    {
        $pelanggan = Pelanggan::find($id);

        if (!$pelanggan) {
            return response()->json([
                'success' => false,
                'message' => 'Pelanggan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data pelanggan ditemukan',
            'data' => $pelanggan
        ]);
    }

    // Menambahkan pelanggan (registrasi)
    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:100',
            'no_hp' => 'required|string|max:20|unique:pelanggan,no_hp',
            'email' => 'required|email|max:100|unique:pelanggan,email',
            'password' => 'required|string|min:6',
        ]);

        $pelanggan = Pelanggan::create([
            'nama' => $request->nama,
            'no_hp' => $request->no_hp,
            'email' => $request->email,
            'password' => bcrypt($request->password),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pelanggan berhasil ditambahkan',
            'data' => $pelanggan
        ], 201);
    }

    // Mengubah pelanggan
    public function update(Request $request, $id)
    {
        $pelanggan = Pelanggan::find($id);

        if (!$pelanggan) {
            return response()->json([
                'success' => false,
                'message' => 'Pelanggan tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama' => 'sometimes|required|string|max:100',
            'no_hp' => 'sometimes|required|string|max:20|unique:pelanggan,no_hp,' . $id . ',id_pelanggan',
            'email' => 'sometimes|required|email|max:100|unique:pelanggan,email,' . $id . ',id_pelanggan',
            'password' => 'sometimes|required|string|min:6',
        ]);

        $data = $request->only([
            'nama',
            'no_hp',
            'email',
        ]);

        if ($request->filled('password')) {
            $data['password'] = bcrypt($request->password);
        }

        $pelanggan->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Pelanggan berhasil diubah',
            'data' => $pelanggan
        ]);
    }

    // Menghapus pelanggan
    public function destroy($id)
    {
        $pelanggan = Pelanggan::find($id);

        if (!$pelanggan) {
            return response()->json([
                'success' => false,
                'message' => 'Pelanggan tidak ditemukan'
            ], 404);
        }

        $pelanggan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pelanggan berhasil dihapus'
        ]);
    }
}