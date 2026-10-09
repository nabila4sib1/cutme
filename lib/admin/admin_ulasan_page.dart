import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// ADMIN - ULASAN PELANGGAN
// ============================================================

class AdminUlasanPage extends StatefulWidget {
  const AdminUlasanPage({super.key});

  @override
  State<AdminUlasanPage> createState() => _AdminUlasanPageState();
}

class _AdminUlasanPageState extends State<AdminUlasanPage> {
  bool loading = true;
  List<dynamic> ulasan = [];

  @override
  void initState() {
    super.initState();
    loadUlasan();
  }

  Future<void> loadUlasan() async {
    try {
      final response = await ApiService.getUlasan();

      if (!mounted) return;

      final data = extractList(response);

      // Terbaru di atas.
      data.sort((a, b) {
        final tglA = getString(a, ['tgl_ulasan']);
        final tglB = getString(b, ['tgl_ulasan']);
        return tglB.compareTo(tglA);
      });

      setState(() {
        ulasan = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil ulasan: $e'),
        ),
      );
    }
  }

  // 'YYYY-MM-DD HH:mm:ss' -> 'DD/MM/YYYY HH:mm'
  String _formatTanggalJam(String raw) {
    if (raw.length < 16) return raw;

    final tanggal = raw.substring(0, 10).split('-');
    final jam = raw.substring(11, 16);

    if (tanggal.length != 3) return raw;

    return '${tanggal[2]}/${tanggal[1]}/${tanggal[0]} $jam';
  }

  double get rataRataRating {
    if (ulasan.isEmpty) return 0;

    final total = ulasan.fold<double>(
      0,
      (sum, item) => sum + getDouble(item, ['rating']),
    );

    return total / ulasan.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ulasan Pelanggan (${ulasan.length})'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadUlasan,
              child: ulasan.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text('Belum ada ulasan.'),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (ulasan.isNotEmpty)
                          Card(
                            color: AppColors.ink,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rataRataRating
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rata-rata dari ${ulasan.length} ulasan',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        ...ulasan.map((item) {
                          final rating =
                              getDouble(item, ['rating']).round();

                          final komentar = getString(
                            item,
                            ['komentar'],
                            defaultValue: '',
                          );

                          final tanggal = _formatTanggalJam(
                            getString(item, ['tgl_ulasan']),
                          );

                          final pelangganData =
                              item is Map &&
                                      item['pelanggan'] is Map
                                  ? item['pelanggan']
                                  : null;

                          final namaPelanggan = pelangganData != null
                              ? getString(
                                  pelangganData,
                                  ['nama', 'nama_pelanggan'],
                                  defaultValue: 'Pelanggan',
                                )
                              : 'Pelanggan';

                          return Card(
                            margin:
                                const EdgeInsets.only(bottom: 12),
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
                                      Text(
                                        tanggal,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  if (komentar.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(komentar),
                                  ],
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