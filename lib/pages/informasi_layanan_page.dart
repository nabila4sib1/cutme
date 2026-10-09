import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// INFORMASI LAYANAN PAGE
// ============================================================
//
// Halaman ini HANYA untuk melihat daftar layanan (read-only).
// Untuk booking, pelanggan pakai tombol "Mulai Booking" di Home.

class InformasiLayananPage extends StatefulWidget {
  const InformasiLayananPage({super.key});

  @override
  State<InformasiLayananPage> createState() =>
      _InformasiLayananPageState();
}

class _InformasiLayananPageState
    extends State<InformasiLayananPage> {
  bool loading = true;
  List<dynamic> layanan = [];

  @override
  void initState() {
    super.initState();
    loadLayanan();
  }

  Future<void> loadLayanan() async {
    try {
      final response = await ApiService.getLayanan();

      if (!mounted) return;

      setState(() {
        layanan = extractList(response);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil layanan: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Layanan'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadLayanan,
              child: layanan.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text('Belum ada layanan.'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: layanan.length,
                      itemBuilder: (context, index) {
                        final item = layanan[index];

                        final nama = getString(
                          item,
                          ['nama_layanan', 'nama'],
                        );

                        final harga = getDouble(
                          item,
                          ['harga'],
                        );

                        final durasi = getString(
                          item,
                          ['durasi_menit', 'durasi'],
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.goldSoft,
                              child: const Icon(
                                Icons.content_cut,
                                color: AppColors.ink,
                              ),
                            ),
                            title: Text(
                              nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Rp ${harga.toStringAsFixed(0)} • $durasi menit',
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}