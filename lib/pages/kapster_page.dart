import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'jadwal_page.dart';

class KapsterPage extends StatefulWidget {
  final List<Map<String, dynamic>> layanan;
  final Map pelanggan;

  const KapsterPage({
    super.key,
    required this.layanan,
    required this.pelanggan,
  });

  @override
  State<KapsterPage> createState() => _KapsterPageState();
}

class _KapsterPageState extends State<KapsterPage> {
  bool loading = true;
  String? errorMessage;

  List<dynamic> kapsters = [];

  // id_kapster -> (rata-rata rating, jumlah ulasan)
  final Map<int, (double, int)> ratingKapster = {};

  @override
  void initState() {
    super.initState();
    loadKapster();
  }

  Future<void> loadKapster() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final hasil = await Future.wait([
        ApiService.getKapster(),
        ApiService.getUlasan(),
      ]);

      final result = hasil[0];
      final ulasanList = extractList(hasil[1]);

      // Hitung rata-rata rating per kapster dari ulasan.
      // Setiap ulasan punya booking -> booking punya kapster.
      final Map<int, List<int>> ratingPerKapster = {};

      for (final u in ulasanList) {
        final booking = u is Map ? u['booking'] : null;
        final kapsterData =
            booking is Map ? booking['kapster'] : null;

        if (kapsterData is! Map) continue;

        final idKapster = getId(kapsterData, ['id_kapster', 'id']);
        final rating = getDouble(u, ['rating']).round();

        ratingPerKapster.putIfAbsent(idKapster, () => []).add(rating);
      }

      ratingKapster.clear();
      ratingPerKapster.forEach((id, list) {
        final rata = list.reduce((a, b) => a + b) / list.length;
        ratingKapster[id] = (rata, list.length);
      });

      if (result['success'] == true) {
        setState(() {
          kapsters = result['data'] ?? [];
          loading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result['message'] ?? 'Gagal mengambil data kapster';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal terhubung ke server:\n$e';
        loading = false;
      });
    }
  }

  String getNamaKapster(Map<String, dynamic> kapster) {
    return kapster['nama_kapster']?.toString() ??
        kapster['nama']?.toString() ??
        'Kapster';
  }

  String getSpesialisasi(Map<String, dynamic> kapster) {
    final value = kapster['spesialisasi']?.toString().trim();

    if (value == null || value.isEmpty) {
      return 'Kapster Umum';
    }

    return 'Spesialis: $value';
  }

  void _pilihKapster(Map<String, dynamic> kapster) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JadwalPage(
          layanan: widget.layanan,
          kapster: kapster,
          pelanggan: widget.pelanggan,
        ),
      ),
    );
  }

  double get _totalHarga {
    return widget.layanan.fold<double>(0, (sum, item) {
      return sum + getDouble(item, ['harga']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kapster'),
      ),

      body: RefreshIndicator(
        onRefresh: loadKapster,

        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // =================================================
            // LAYANAN YANG DIPILIH (bisa lebih dari satu)
            // =================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.layanan.map((item) {
                      final nama = getString(
                        item,
                        ['nama_layanan', 'nama'],
                      );

                      final harga = getDouble(item, ['harga']);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.content_cut,
                              color: AppColors.ink,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(nama)),
                            Text(
                              'Rp ${harga.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Rp ${_totalHarga.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Pilih Kapster',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Pilih kapster yang tersedia untuk layanan kamu.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // LOADING
            // =================================================

            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

            // =================================================
            // ERROR
            // =================================================

            else if (errorMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 45,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton.icon(
                        onPressed: loadKapster,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )

            // =================================================
            // DATA KOSONG
            // =================================================

            else if (kapsters.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: const [

                      Icon(
                        Icons.person_off_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'Belum ada kapster',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Data kapster belum tersedia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )

            // =================================================
            // LIST KAPSTER
            // =================================================

            else
              ...kapsters.map(
                (item) {
                  final kapster =
                      Map<String, dynamic>.from(item);

                  final idKapster = getId(
                    kapster,
                    ['id_kapster', 'id'],
                  );

                  final ratingInfo = ratingKapster[idKapster];

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),

                    child: Card(
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(16),

                        onTap: () => _pilihKapster(kapster),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(18),

                          child: Row(
                            children: [

                              Container(
                                width: 55,
                                height: 55,
                                decoration:
                                    BoxDecoration(
                                  color: AppColors.ink
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(
                                    15,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.ink,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      getNamaKapster(
                                        kapster,
                                      ),
                                      style:
                                          const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      getSpesialisasi(kapster),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    if (ratingInfo != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 15,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            ratingInfo.$1
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' (${ratingInfo.$2} ulasan)',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      const Text(
                                        'Belum ada ulasan',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}