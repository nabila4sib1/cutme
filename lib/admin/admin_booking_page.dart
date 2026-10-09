import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

class AdminBookingPage extends StatefulWidget {
  const AdminBookingPage({super.key});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  bool loading = true;
  List<dynamic> booking = [];

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
          content: Text('Gagal mengambil booking: $e'),
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
        return Colors.indigo;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking (${booking.length})'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadBooking,
              child: booking.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text('Belum ada booking.'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: booking.length,
                      itemBuilder: (context, index) {
                        final item = booking[index];

                        final status = getString(item, ['status']);
                        final total =
                            getDouble(item, ['total_biaya']);

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

                        final warna = warnaStatus(status);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        namaPelanggan,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        labelStatus(status),
                                      ),
                                      backgroundColor: warna
                                          .withValues(alpha: 0.12),
                                      labelStyle: TextStyle(
                                        color: warna,
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                      side: BorderSide.none,
                                      visualDensity:
                                          VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kapster: $namaKapster',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$tanggalBooking • Rp ${total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}