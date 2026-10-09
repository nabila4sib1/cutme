import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'pembayaran_page.dart';

// ============================================================
// WARNA TEMA CUTME
// ============================================================

const Color ink = Color(0xFF15151A);
const Color gold = Color(0xFFC6952C);
const Color burgundy = Color(0xFF7A2E2E);
const Color warmWhite = Color(0xFFF5F3EE);
const Color softGray = Color(0xFF777168);

// ============================================================
// KONFIRMASI PAGE
// ============================================================

class KonfirmasiPage extends StatefulWidget {
  final List<Map<String, dynamic>> layanan;
  final Map<String, dynamic> kapster;
  final Map<String, dynamic> jadwal;
  final Map pelanggan;

  const KonfirmasiPage({
    super.key,
    required this.layanan,
    required this.kapster,
    required this.jadwal,
    required this.pelanggan,
  });

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  bool saving = false;

  // ============================================================
  // TOTAL BIAYA
  // ============================================================

  double get totalBiaya {
    return widget.layanan.fold<double>(0, (sum, item) {
      return sum + getDouble(item, ['harga']);
    });
  }

  // ============================================================
  // BUAT BOOKING
  // ============================================================

  Future<void> buatBooking() async {
    final idPelanggan = getId(
      widget.pelanggan,
      ['id_pelanggan', 'id'],
    );

    final kapsterId = getId(
      widget.kapster,
      ['id_kapster', 'id'],
    );

    final jadwalId = getId(
      widget.jadwal,
      ['id_jadwal', 'id'],
    );

    final adaLayananTidakValid = widget.layanan.any(
      (item) => getId(item, ['id_layanan', 'id']) == 0,
    );

    // ==========================================================
    // VALIDASI DATA
    // ==========================================================

    if (idPelanggan == 0 ||
        kapsterId == 0 ||
        jadwalId == 0 ||
        widget.layanan.isEmpty ||
        adaLayananTidakValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: burgundy,
          content: Text(
            'Data booking tidak lengkap',
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // ========================================================
      // CREATE BOOKING
      // ========================================================

      final booking = await ApiService.createBooking(
        idPelanggan: idPelanggan,
        idKapster: kapsterId,
        idJadwal: jadwalId,
        totalBiaya: totalBiaya,
      );

      final bookingData = extractMap(booking);

      int idBooking = getId(
        bookingData,
        ['id_booking', 'id'],
      );

      if (idBooking == 0) {
        idBooking = getId(
          booking,
          ['id_booking', 'id'],
        );
      }

      if (idBooking == 0) {
        throw Exception(
          'ID booking tidak ditemukan dari server',
        );
      }

      // ========================================================
      // CREATE DETAIL BOOKING
      // ========================================================

      // Satu detail_booking untuk setiap layanan.
      for (final item in widget.layanan) {
        await ApiService.createDetailBooking(
          idBooking: idBooking,
          idLayanan: getId(
            item,
            ['id_layanan', 'id'],
          ),
          subtotal: getDouble(
            item,
            ['harga'],
          ),
        );
      }

      // ========================================================
      // UPDATE STATUS JADWAL
      // ========================================================

      try {
        await ApiService.updateStatusJadwal(
          idJadwal: jadwalId,
          statusSlot: 'dipesan',
        );
      } catch (_) {
        // Booking tetap dianggap berhasil meskipun
        // update status jadwal gagal.
      }

      if (!mounted) return;

      // ========================================================
      // LANJUT KE PEMBAYARAN
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PembayaranPage(
            idBooking: idBooking,
            totalBiaya: totalBiaya,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: burgundy,
          content: Text(
            'Booking gagal: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final namaKapster = getString(
      widget.kapster,
      ['nama_kapster', 'nama'],
    );

    final tanggal = getString(
      widget.jadwal,
      ['tanggal', 'tgl'],
    );

    final jam = getString(
      widget.jadwal,
      ['jam', 'jam_mulai', 'waktu'],
    );

    return Scaffold(
      backgroundColor: warmWhite,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: ink,
        foregroundColor: warmWhite,
        elevation: 0,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),

              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(8),
              ),

              child: const Icon(
                Icons.receipt_long,
                color: ink,
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'Konfirmasi Booking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            15,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ==================================================
              // HEADER
              // ==================================================

              const Text(
                'Cek Pesanan Kamu',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Pastikan semua detail booking sudah benar.',
                style: TextStyle(
                  color: softGray,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // DETAIL BOOKING
              // ==================================================

              Expanded(
                child: ListView(
                  children: [

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),

                        border: Border.all(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(20),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            // ====================================
                            // JUDUL
                            // ====================================

                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,

                                  decoration: BoxDecoration(
                                    color: gold.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),

                                  child: const Icon(
                                    Icons.content_cut,
                                    color: ink,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Text(
                                    'Detail Booking',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ====================================
                            // LAYANAN
                            // ====================================

                            const Text(
                              'LAYANAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: softGray,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ...widget.layanan.map(
                              (item) {
                                final nama = getString(
                                  item,
                                  [
                                    'nama_layanan',
                                    'nama',
                                  ],
                                );

                                final harga = getDouble(
                                  item,
                                  ['harga'],
                                );

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 10,
                                  ),

                                  child: Row(
                                    children: [

                                      Container(
                                        width: 30,
                                        height: 30,

                                        decoration:
                                            BoxDecoration(
                                          color: ink,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(8),
                                        ),

                                        child: const Icon(
                                          Icons.content_cut,
                                          color: gold,
                                          size: 15,
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Text(
                                          nama,
                                          style:
                                              const TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: ink,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        'Rp ${harga.toStringAsFixed(0)}',
                                        style:
                                            const TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.bold,
                                          color: burgundy,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: Divider(),
                            ),

                            // ====================================
                            // KAPSTER
                            // ====================================

                            _InfoRow(
                              icon: Icons.person,
                              label: 'Kapster',
                              value: namaKapster,
                            ),

                            // ====================================
                            // TANGGAL
                            // ====================================

                            _InfoRow(
                              icon: Icons.calendar_month,
                              label: 'Tanggal',
                              value: tanggal,
                            ),

                            // ====================================
                            // JAM
                            // ====================================

                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Jam',
                              value: jam,
                            ),

                            const SizedBox(height: 8),

                            const Divider(),

                            const SizedBox(height: 8),

                            // ====================================
                            // TOTAL
                            // ====================================

                            Container(
                              padding:
                                  const EdgeInsets.all(15),

                              decoration: BoxDecoration(
                                color: ink,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),

                              child: Row(
                                children: [

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          'TOTAL PEMBAYARAN',
                                          style: TextStyle(
                                            color:
                                                Colors.white54,
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),

                                        SizedBox(height: 5),

                                        Text(
                                          'Jumlah yang harus dibayar',
                                          style: TextStyle(
                                            color: warmWhite,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    'Rp ${totalBiaya.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // BUTTON BOOKING
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed:
                      saving ? null : buatBooking,

                  icon: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: ink,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline,
                        ),

                  label: Text(
                    saving
                        ? 'Memproses Booking...'
                        : 'Konfirmasi & Booking',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: ink,
                    disabledBackgroundColor:
                        gold.withValues(alpha: 0.55),
                    disabledForegroundColor:
                        ink.withValues(alpha: 0.7),
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [

          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),

            child: Icon(
              icon,
              color: ink,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: softGray,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}