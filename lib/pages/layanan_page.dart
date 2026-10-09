import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import 'kapster_page.dart';

class LayananPage extends StatefulWidget {
  final Map pelanggan;

  const LayananPage({
    super.key,
    required this.pelanggan,
  });

  @override
  State<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends State<LayananPage> {
  bool loading = true;
  String? error;

  List<dynamic> layanan = [];

  // id_layanan yang sedang dipilih pelanggan (bisa lebih dari satu).
  final Set<int> dipilih = {};

  @override
  void initState() {
    super.initState();
    loadLayanan();
  }

  Future<void> loadLayanan() async {
    try {
      final result = await ApiService.getLayanan();

      if (!mounted) return;

      setState(() {
        layanan = result['data'] ?? [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  int _idLayanan(dynamic item) {
    return int.tryParse(item['id_layanan']?.toString() ?? '') ?? 0;
  }

  void _toggle(dynamic item) {
    final id = _idLayanan(item);

    setState(() {
      if (dipilih.contains(id)) {
        dipilih.remove(id);
      } else {
        dipilih.add(id);
      }
    });
  }

  List<Map<String, dynamic>> get _layananTerpilih {
    return layanan
        .where((item) => dipilih.contains(_idLayanan(item)))
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  double get _totalHarga {
    return _layananTerpilih.fold<double>(0, (sum, item) {
      return sum + (double.tryParse(item['harga']?.toString() ?? '') ?? 0);
    });
  }

  void _lanjut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KapsterPage(
          layanan: _layananTerpilih,
          pelanggan: widget.pelanggan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        title: const Text(
          'Pilih Layanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _buildBody(),

      // Bar bawah muncul hanya kalau sudah ada yang dipilih.
      bottomNavigationBar: dipilih.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _lanjut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '${dipilih.length} layanan dipilih • '
                    'Rp ${_totalHarga.toStringAsFixed(0)} • Lanjut',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    // =========================
    // LOADING
    // =========================

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // =========================
    // ERROR
    // =========================

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                'Gagal mengambil data layanan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = null;
                  });

                  loadLayanan();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // =========================
    // DATA KOSONG
    // =========================

    if (layanan.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada layanan.',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }

    // =========================
    // LIST LAYANAN (multi-select)
    // =========================

    return RefreshIndicator(
      onRefresh: loadLayanan,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          dipilih.isEmpty ? 20 : 100,
        ),
        children: [
          const Text(
            'Pilih satu atau lebih layanan sekaligus.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 15),
          ...layanan.map((item) {
            final id = _idLayanan(item);

            final String nama =
                item['nama_layanan']?.toString() ?? '-';

            final String harga =
                item['harga']?.toString() ?? '0';

            final String durasi =
                item['durasi_menit']?.toString() ?? '0';

            return _LayananCard(
              nama: nama,
              harga: harga,
              durasi: durasi,
              terpilih: dipilih.contains(id),
              onTap: () => _toggle(item),
            );
          }),
        ],
      ),
    );
  }
}

// ==================================================
// LAYANAN CARD
// ==================================================

class _LayananCard extends StatelessWidget {
  final String nama;
  final String harga;
  final String durasi;
  final bool terpilih;
  final VoidCallback onTap;

  const _LayananCard({
    required this.nama,
    required this.harga,
    required this.durasi,
    required this.terpilih,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: terpilih ? Colors.black : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [

              // ICON
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.content_cut,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Rp $harga',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$durasi menit',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                terpilih
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: terpilih ? Colors.black : Colors.grey,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}