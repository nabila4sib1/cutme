<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\PelangganController;
use App\Http\Controllers\Api\KapsterController;
use App\Http\Controllers\Api\JadwalKapsterController;
use App\Http\Controllers\Api\LayananController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\DetailBookingController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\Api\UlasanController;
use App\Http\Controllers\Api\AuthController;

// Pelanggan
Route::apiResource('pelanggan', PelangganController::class);

// Kapster
Route::apiResource('kapster', KapsterController::class);

// Jadwal Kapster
Route::apiResource('jadwal-kapster', JadwalKapsterController::class);

// Layanan
Route::apiResource('layanan', LayananController::class);

// Booking
Route::apiResource('booking', BookingController::class);

// Detail Booking
Route::apiResource('detail-booking', DetailBookingController::class);

// Pembayaran
Route::apiResource('pembayaran', PembayaranController::class);

// Ulasan
Route::apiResource('ulasan', UlasanController::class);

Route::post('/login/kapster', [AuthController::class, 'loginKapster']);
Route::patch('/booking/{id}/status', [BookingController::class, 'updateStatus']);
Route::post('/login/pelanggan', [AuthController::class, 'loginPelanggan']);

Route::post('/login/admin', function (\Illuminate\Http\Request $request) {
    $username = $request->input('username');
    $password = $request->input('password');

    if (
        $username === env('ADMIN_USERNAME') &&
        $password === env('ADMIN_PASSWORD')
    ) {
        return response()->json([
            'success' => true,
            'message' => 'Login admin berhasil',
            'user' => [
                'username' => $username,
                'role' => 'admin',
            ],
        ]);
    }

    return response()->json([
        'success' => false,
        'message' => 'Username atau password salah',
    ], 401);
});

Route::patch('/booking/{id}/batalkan', [BookingController::class, 'batalkan']);

use App\Http\Controllers\Api\GaleriController;

Route::post('/kapster/{id}/foto', [KapsterController::class, 'uploadFoto']);
Route::get('/galeri', [GaleriController::class, 'index']);
Route::post('/galeri', [GaleriController::class, 'store']);
Route::delete('/galeri/{id}', [GaleriController::class, 'destroy']);