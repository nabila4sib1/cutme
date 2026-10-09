<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    // Nama relasi HARUS sama persis dengan method di model Booking:
    // jadwal() dan detailBookings() (bukan jadwalKapster/detailBooking).
    private const RELASI = [
        'pelanggan',
        'kapster',
        'jadwal',
        'detailBookings',
        'pembayaran',
        'ulasan',
    ];

    // Alur status booking yang diizinkan (hanya maju satu langkah).
    private const ALUR_STATUS = [
        'menunggu_konfirmasi' => 'datang',
        'datang' => 'dilayani',
        'dilayani' => 'selesai',
    ];

    // GET /api/booking
    // Opsional: ?id_kapster=1 (booking milik kapster tsb)
    // Opsional: ?id_pelanggan=1 (booking milik pelanggan tsb)
    public function index(Request $request)
    {
        $query = Booking::with(self::RELASI);

        if ($request->filled('id_kapster')) {
            $query->where('id_kapster', $request->id_kapster);
        }

        if ($request->filled('id_pelanggan')) {
            $query->where('id_pelanggan', $request->id_pelanggan);
        }

        $booking = $query->orderByDesc('id_booking')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data booking berhasil diambil',
            'data' => $booking
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_pelanggan' => 'required|exists:pelanggan,id_pelanggan',
            'id_kapster' => 'required|exists:kapster,id_kapster',
            'id_jadwal' => 'required|exists:jadwal_kapster,id_jadwal',
            'status' => 'nullable|string|max:50',
            'total_biaya' => 'required|numeric|min:0',
        ]);

        $booking = Booking::create([
            'id_pelanggan' => $request->id_pelanggan,
            'id_kapster' => $request->id_kapster,
            'id_jadwal' => $request->id_jadwal,
            'tgl_booking' => now(),
            'status' => $request->status ?? 'menunggu_konfirmasi',
            'total_biaya' => $request->total_biaya,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil ditambahkan',
            'data' => $booking
        ], 201);
    }

    public function show($id)
    {
        $booking = Booking::with(self::RELASI)->find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data booking ditemukan',
            'data' => $booking
        ]);
    }

    public function update(Request $request, $id)
    {
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'id_pelanggan' => 'sometimes|required|exists:pelanggan,id_pelanggan',
            'id_kapster' => 'sometimes|required|exists:kapster,id_kapster',
            'id_jadwal' => 'sometimes|required|exists:jadwal_kapster,id_jadwal',
            'status' => 'sometimes|required|string|max:50',
            'total_biaya' => 'sometimes|required|numeric|min:0',
        ]);

        $booking->update($request->only([
            'id_pelanggan',
            'id_kapster',
            'id_jadwal',
            'status',
            'total_biaya'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil diubah',
            'data' => $booking
        ]);
    }

    // PATCH /api/booking/{id}/status
    // Dipakai kapster: menunggu_konfirmasi -> datang -> dilayani -> selesai
    public function updateStatus(Request $request, $id)
    {
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'status' => 'required|string|in:menunggu_konfirmasi,datang,dilayani,selesai',
        ]);

        $statusBaru = $request->status;
        $statusSekarang = $booking->status;

        if ((self::ALUR_STATUS[$statusSekarang] ?? null) !== $statusBaru) {
            return response()->json([
                'success' => false,
                'message' => "Status tidak bisa diubah dari '{$statusSekarang}' ke '{$statusBaru}'"
            ], 422);
        }

        $booking->update(['status' => $statusBaru]);

        return response()->json([
            'success' => true,
            'message' => 'Status booking berhasil diperbarui',
            'data' => $booking
        ]);
    }

    // PATCH /api/booking/{id}/batalkan
    // Dipakai pelanggan: hanya bisa batalkan selama kapster belum
    // memproses (status masih 'menunggu_konfirmasi'). Slot jadwal
    // terkait otomatis dikembalikan jadi 'tersedia'.
    public function batalkan($id)
    {
        $booking = Booking::with('jadwal')->find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }

        if ($booking->status !== 'menunggu_konfirmasi') {
            return response()->json([
                'success' => false,
                'message' => 'Booking yang sudah diproses kapster tidak bisa dibatalkan'
            ], 422);
        }

        $booking->update(['status' => 'dibatalkan']);

        if ($booking->jadwal) {
            $booking->jadwal->update(['status_slot' => 'tersedia']);
        }

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil dibatalkan',
            'data' => $booking
        ]);
    }

    public function destroy($id)
    {
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }

        $booking->delete();

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil dihapus'
        ]);
    }
}