<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kapster;
use App\Models\Pelanggan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // ============================================================
    // LOGIN KAPSTER
    // ============================================================
    //
    // Login pakai No. HP + password. Kalau cocok, kembalikan data
    // kapster (TANPA password, karena sudah $hidden di model).
    //
    // Catatan: ini belum pakai token/session (Sanctum, dsb) -
    // Flutter cukup simpan id_kapster hasil login di
    // SharedPreferences untuk dipakai di halaman-halaman
    // berikutnya. Kalau nanti butuh keamanan lebih (logout paksa,
    // multi-device, dll), ini titik yang pas buat upgrade ke
    // Laravel Sanctum.

    public function loginKapster(Request $request)
    {
        $request->validate([
            'no_hp' => 'required|string',
            'password' => 'required|string',
        ]);

        $kapster = Kapster::where('no_hp', $request->no_hp)->first();

        if (!$kapster) {
            return response()->json([
                'success' => false,
                'message' => 'No. HP atau password salah',
            ], 401);
        }

        if (!$kapster->status_aktif) {
            return response()->json([
                'success' => false,
                'message' => 'Akun kapster ini tidak aktif',
            ], 403);
        }

        if (!$kapster->password ||
            !Hash::check($request->password, $kapster->password)) {
            return response()->json([
                'success' => false,
                'message' => 'No. HP atau password salah',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => $kapster,
        ]);
    }


    // ============================================================
    // LOGIN PELANGGAN
    // ============================================================
    //
    // Login pakai email ATAU no_hp (bebas kirim salah satu di
    // field 'identitas') + password.

    public function loginPelanggan(Request $request)
    {
        $request->validate([
            'identitas' => 'required|string',
            'password' => 'required|string',
        ]);

        $pelanggan = Pelanggan::where('email', $request->identitas)
            ->orWhere('no_hp', $request->identitas)
            ->first();

        if (!$pelanggan) {
            return response()->json([
                'success' => false,
                'message' => 'Akun tidak ditemukan',
            ], 401);
        }

        if (!$pelanggan->password ||
            !Hash::check($request->password, $pelanggan->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email/No. HP atau password salah',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => $pelanggan,
        ]);
    }


    // ============================================================
    // LOGIN ADMIN
    // ============================================================
    //
    // Satu akun tetap, username+password diambil dari .env lewat
    // config/admin.php (lihat ADMIN_USERNAME & ADMIN_PASSWORD).

    public function loginAdmin(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $validUsername = config('admin.username');
        $validPassword = config('admin.password');

        if ($request->username !== $validUsername ||
            $request->password !== $validPassword) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'username' => $validUsername,
            ],
        ]);
    }
}