import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// ADMIN - DAFTAR PELANGGAN
// ============================================================

class AdminPelangganPage extends StatefulWidget {
  const AdminPelangganPage({super.key});

  @override
  State<AdminPelangganPage> createState() =>
      _AdminPelangganPageState();
}

class _AdminPelangganPageState extends State<AdminPelangganPage> {
  bool loading = true;
  List<dynamic> pelanggan = [];

  @override
  void initState() {
    super.initState();
    loadPelanggan();
  }

  Future<void> loadPelanggan() async {
    try {
      final response = await ApiService.getPelanggan();

      if (!mounted) return;

      setState(() {
        pelanggan = extractList(response);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil pelanggan: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pelanggan (${pelanggan.length})'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPelanggan,
              child: pelanggan.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text('Belum ada pelanggan.'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pelanggan.length,
                      itemBuilder: (context, index) {
                        final item = pelanggan[index];

                        final nama = getString(
                          item,
                          ['nama', 'nama_pelanggan'],
                        );

                        final email = getString(
                          item,
                          ['email'],
                          defaultValue: '-',
                        );

                        final noHp = getString(
                          item,
                          ['no_hp'],
                          defaultValue: '-',
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
                            subtitle: Text('$email • $noHp'),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}