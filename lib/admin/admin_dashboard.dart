import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'admin_laporan_page.dart';
import 'admin_pelanggan_page.dart';
import 'admin_booking_page.dart';
import 'admin_ulasan_page.dart';

// ============================================================
// ADMIN DASHBOARD
// ============================================================
//
// Kapster & Layanan TIDAK ditaruh di sini lagi karena sudah
// ada tab-nya sendiri di bottom navigation (biar tidak dobel).
// Di sini hanya hal yang belum punya tempat lain: Pelanggan,
// Booking Hari Ini, Laporan Transaksi, Ulasan.

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool loading = true;

  int jumlahPelanggan = 0;
  int jumlahBookingHariIni = 0;
  int jumlahTransaksi = 0;
  int jumlahUlasan = 0;

  @override
  void initState() {
    super.initState();
    loadStatistik();
  }

  Future<void> loadStatistik() async {
    try {
      final hasil = await Future.wait([
        ApiService.getPelanggan(),
        ApiService.getBooking(),
        ApiService.getUlasan(),
      ]);

      if (!mounted) return;

      final pelanggan = extractList(hasil[0]);
      final booking = extractList(hasil[1]);
      final ulasan = extractList(hasil[2]);

      final hariIni = DateTime.now();
      final hariIniStr =
          '${hariIni.year}-${hariIni.month.toString().padLeft(2, '0')}-${hariIni.day.toString().padLeft(2, '0')}';

      // ============================================================
      // BOOKING HARI INI
      // ============================================================

      final bookingHariIni = booking.where((item) {
        final jadwalData =
            item is Map && item['jadwal'] is Map
                ? item['jadwal']
                : null;

        if (jadwalData == null) {
          return false;
        }

        final tanggalJadwal = getString(
          jadwalData,
          ['tanggal'],
        );

        return tanggalJadwal.startsWith(hariIniStr);
      }).length;

      // Statistik transaksi tetap dihitung seperti sebelumnya.
      // Angka ini tidak ditampilkan pada kartu Laporan Transaksi.
      final transaksi = booking.where((item) {
        return item is Map && item['pembayaran'] != null;
      }).length;

      setState(() {
        jumlahPelanggan = pelanggan.length;
        jumlahBookingHariIni = bookingHariIni;
        jumlahTransaksi = transaksi;
        jumlahUlasan = ulasan.length;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil statistik: $e'),
        ),
      );
    }
  }

  String _tampilkan(int value) {
    return loading ? '-' : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadStatistik,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Admin',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Ketuk kartu untuk melihat detailnya',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _dashboardCard(
                  icon: Icons.people,
                  color: AppColors.burgundy,
                  title: 'Pelanggan',
                  value: _tampilkan(jumlahPelanggan),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPelangganPage(),
                      ),
                    );
                  },
                ),

                _dashboardCard(
                  icon: Icons.calendar_month,
                  color: Colors.orange,
                  title: 'Booking Hari Ini',
                  value: _tampilkan(jumlahBookingHariIni),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminBookingPage(),
                      ),
                    );
                  },
                ),

                // ==========================================
                // LAPORAN TRANSAKSI
                // Angka tidak ditampilkan pada kartu ini.
                // ==========================================
                _dashboardCard(
                  icon: Icons.payments,
                  color: Colors.green,
                  title: 'Laporan Transaksi',
                  value: '',
                  tampilkanAngka: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLaporanPage(),
                      ),
                    );
                  },
                ),

                _dashboardCard(
                  icon: Icons.star,
                  color: Colors.amber[800]!,
                  title: 'Ulasan',
                  value: _tampilkan(jumlahUlasan),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminUlasanPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dashboardCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool tampilkanAngka = true,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),

              const SizedBox(height: 8),

              if (tampilkanAngka)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (tampilkanAngka)
                const SizedBox(height: 2),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
