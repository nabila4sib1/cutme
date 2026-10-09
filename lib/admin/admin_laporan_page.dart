import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// ADMIN LAPORAN TRANSAKSI
// ============================================================

class AdminLaporanPage extends StatefulWidget {
  const AdminLaporanPage({super.key});

  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  bool loading = true;
  List<dynamic> booking = [];

  String periode = 'Harian';
  DateTime tanggalDipilih = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadBooking();
  }

  Future<void> loadBooking() async {
    try {
      final response = await ApiService.getBooking();

      if (!mounted) return;

      setState(() {
        booking = extractList(response);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil laporan: $e'),
        ),
      );
    }
  }

  String labelStatus(String status) {
    switch (status) {
      case 'menunggu_konfirmasi':
        return 'Menunggu';
      case 'datang':
        return 'Datang';
      case 'dilayani':
        return 'Dilayani';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color warnaStatus(String status) {
    switch (status) {
      case 'menunggu_konfirmasi':
        return Colors.orange;
      case 'datang':
        return Colors.blue;
      case 'dilayani':
        return Colors.deepPurple;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _potongTanggal(String raw) {
    if (raw.length >= 10) {
      final bagian = raw.substring(0, 10).split('-');

      if (bagian.length == 3) {
        return '${bagian[2]}/${bagian[1]}/${bagian[0]}';
      }
    }

    return raw;
  }

  DateTime? _parseTanggal(dynamic raw) {
    if (raw == null) return null;

    return DateTime.tryParse(raw.toString());
  }

  Map? _ambilPembayaran(dynamic item) {
    if (item is Map && item['pembayaran'] is Map) {
      return item['pembayaran'] as Map;
    }

    return null;
  }

  // ============================================================
  // STATUS PEMBAYARAN
  // Hanya pembayaran yang sudah berhasil yang dihitung.
  // ============================================================

  bool _pembayaranValid(dynamic item) {
    final pembayaran = _ambilPembayaran(item);

    if (pembayaran == null) return false;

    final statusBayar = getString(
      pembayaran,
      ['status_bayar'],
    ).trim().toLowerCase();

    const statusBerhasil = [
      'lunas',
      'berhasil',
      'sukses',
      'paid',
      'success',
      'dibayar',
      'terbayar',
      'terkonfirmasi',
    ];

    return statusBerhasil.contains(statusBayar);
  }

  // ============================================================
  // BOOKING BATAL TIDAK DIHITUNG SEBAGAI TRANSAKSI
  // ============================================================

  bool _transaksiValid(dynamic item) {
    if (item is! Map) return false;

    final status = getString(
      item,
      ['status'],
    ).trim().toLowerCase();

    if (status == 'dibatalkan') return false;

    return _pembayaranValid(item);
  }

  // Tanggal transaksi memakai tgl_bayar.
  // Jika tidak tersedia, gunakan tgl_booking.
  DateTime? _tanggalTransaksi(dynamic item) {
    final pembayaran = _ambilPembayaran(item);

    final tanggalBayar = pembayaran == null
        ? null
        : _parseTanggal(pembayaran['tgl_bayar']);

    if (tanggalBayar != null) return tanggalBayar;

    return _parseTanggal(
      item is Map ? item['tgl_booking'] : null,
    );
  }

  bool _sesuaiPeriode(dynamic item) {
    final tanggal = _tanggalTransaksi(item);

    if (tanggal == null) return false;

    final tanggalAwal = DateTime(
      tanggalDipilih.year,
      tanggalDipilih.month,
      tanggalDipilih.day,
    );

    final tanggalItem = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
    );

    if (periode == 'Harian') {
      return tanggalItem == tanggalAwal;
    }

    if (periode == 'Mingguan') {
      final awalMinggu = tanggalAwal.subtract(
        Duration(days: tanggalAwal.weekday - 1),
      );

      final akhirMinggu = awalMinggu.add(
        const Duration(days: 7),
      );

      return !tanggalItem.isBefore(awalMinggu) &&
          tanggalItem.isBefore(akhirMinggu);
    }

    final awalBulan = DateTime(
      tanggalDipilih.year,
      tanggalDipilih.month,
    );

    final awalBulanBerikutnya = DateTime(
      tanggalDipilih.year,
      tanggalDipilih.month + 1,
    );

    return !tanggalItem.isBefore(awalBulan) &&
        tanggalItem.isBefore(awalBulanBerikutnya);
  }

  String _formatTanggalPilihan() {
    final tanggal = tanggalDipilih.day.toString().padLeft(2, '0');
    final bulan = tanggalDipilih.month.toString().padLeft(2, '0');

    return '$tanggal/$bulan/${tanggalDipilih.year}';
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: tanggalDipilih,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (hasil != null && mounted) {
      setState(() {
        tanggalDipilih = hasil;
      });
    }
  }

  String _formatRupiah(double nilai) {
    return 'Rp ${nilai.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    // Booking batal dan pembayaran yang belum berhasil
    // tidak dimasukkan ke laporan transaksi.
    final transaksiValid = booking.where(_transaksiValid).toList();

    // Terapkan filter periode pada transaksi yang valid.
    final transaksiPeriode = transaksiValid
        .where(_sesuaiPeriode)
        .toList();

    // Total pendapatan hanya dari transaksi valid pada periode.
    final totalPendapatan = transaksiPeriode.fold<double>(
      0,
      (sum, item) {
        final pembayaran = _ambilPembayaran(item);

        if (pembayaran == null) return sum;

        return sum + getDouble(
          pembayaran,
          ['jumlah_bayar'],
        );
      },
    );

    final jumlahTransaksi = transaksiPeriode.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadBooking,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ==========================================
                  // FILTER PERIODE
                  // ==========================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Periode Laporan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'Harian',
                                label: Text('Harian'),
                              ),
                              ButtonSegment(
                                value: 'Mingguan',
                                label: Text('Mingguan'),
                              ),
                              ButtonSegment(
                                value: 'Bulanan',
                                label: Text('Bulanan'),
                              ),
                            ],
                            selected: {periode},
                            onSelectionChanged: (pilihan) {
                              setState(() {
                                periode = pilihan.first;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pilihTanggal,
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                            label: Text(
                              'Tanggal: ${_formatTanggalPilihan()}',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            periode == 'Harian'
                                ? 'Menampilkan transaksi pada tanggal terpilih.'
                                : periode == 'Mingguan'
                                    ? 'Minggu dihitung dari Senin sampai Minggu.'
                                    : 'Menampilkan transaksi pada bulan terpilih.',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==========================================
                  // RINGKASAN TRANSAKSI
                  // ==========================================
                  Card(
                    color: AppColors.ink,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pendapatan',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatRupiah(totalPendapatan),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Jumlah Transaksi',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$jumlahTransaksi transaksi valid',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // DAFTAR TRANSAKSI
                  // ==========================================
                  Text(
                    'Daftar Transaksi (${transaksiPeriode.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (transaksiPeriode.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'Belum ada transaksi valid pada periode ini.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  ...transaksiPeriode.map((item) {
                    final status = getString(
                      item,
                      ['status'],
                    );

                    final total = getDouble(
                      item,
                      ['total_biaya'],
                    );

                    final pelangganData =
                        item is Map && item['pelanggan'] is Map
                            ? item['pelanggan']
                            : null;

                    final namaPelanggan = pelangganData != null
                        ? getString(
                            pelangganData,
                            ['nama', 'nama_pelanggan'],
                            defaultValue: 'Pelanggan',
                          )
                        : 'Pelanggan';

                    final kapsterData =
                        item is Map && item['kapster'] is Map
                            ? item['kapster']
                            : null;

                    final namaKapster = kapsterData != null
                        ? getString(
                            kapsterData,
                            ['nama_kapster', 'nama'],
                            defaultValue: 'Kapster',
                          )
                        : 'Kapster';

                    final tanggalBooking = _potongTanggal(
                      getString(item, ['tgl_booking']),
                    );

                    final pembayaranData = _ambilPembayaran(item);

                    final metodeBayar = pembayaranData != null
                        ? getString(
                            pembayaranData,
                            ['metode'],
                            defaultValue: '-',
                          )
                        : '-';

                    final warna = warnaStatus(status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    namaPelanggan,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    labelStatus(status),
                                  ),
                                  backgroundColor:
                                      warna.withValues(alpha: 0.12),
                                  labelStyle: TextStyle(
                                    color: warna,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  side: BorderSide.none,
                                  visualDensity:
                                      VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kapster: $namaKapster • $tanggalBooking',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatRupiah(total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    metodeBayar.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}