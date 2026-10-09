import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// INFORMASI KAPSTER PAGE
// ============================================================
//
// Halaman ini HANYA untuk melihat daftar kapster (read-only).
// Untuk booking, pelanggan pakai tombol "Mulai Booking" di Home.

class InformasiKapsterPage extends StatefulWidget {
  const InformasiKapsterPage({super.key});

  @override
  State<InformasiKapsterPage> createState() =>
      _InformasiKapsterPageState();
}

class _InformasiKapsterPageState
    extends State<InformasiKapsterPage> {
  bool loading = true;
  List<dynamic> kapster = [];

  @override
  void initState() {
    super.initState();
    loadKapster();
  }

  Future<void> loadKapster() async {
    try {
      final response = await ApiService.getKapster();

      if (!mounted) return;

      setState(() {
        kapster = extractList(response);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil kapster: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Kapster'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadKapster,
              child: kapster.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text('Belum ada kapster.'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: kapster.length,
                      itemBuilder: (context, index) {
                        final item = kapster[index];

                        final nama = getString(
                          item,
                          ['nama_kapster', 'nama'],
                        );

                        final spesialisasi = getString(
                          item,
                          ['spesialisasi'],
                          defaultValue: '',
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
                                Icons.person,
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
                              spesialisasi.isEmpty
                                  ? 'Kapster Umum'
                                  : 'Spesialis: $spesialisasi',
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}