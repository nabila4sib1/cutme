import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'konfirmasi_page.dart';

// ============================================================
// JADWAL PAGE
// ============================================================
//
// Halaman ini menerima daftar `layanan` (bisa lebih dari satu)
// dan `kapster` yang sudah dipilih pelanggan, lalu menampilkan
// jadwal yang tersedia untuk kapster tersebut (difilter
// berdasarkan id_kapster, dan hanya yang status_slot ==
// 'tersedia').

class JadwalPage extends StatefulWidget {
  final List<Map<String, dynamic>> layanan;
  final Map<String, dynamic> kapster;
  final Map pelanggan;

  const JadwalPage({
    super.key,
    required this.layanan,
    required this.kapster,
    required this.pelanggan,
  });

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  bool loading = true;
  String? errorMessage;

  List<dynamic> jadwalList = [];

  @override
  void initState() {
    super.initState();
    loadJadwal();
  }

  Future<void> loadJadwal() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getJadwalKapster();
      final semuaJadwal = extractList(response);

      final kapsterId = getId(
        widget.kapster,
        ['id_kapster', 'id'],
      );

      // Hanya tampilkan jadwal milik kapster yang dipilih,
      // dan yang statusnya masih 'tersedia' (belum dibooking
      // pelanggan lain).
      final hasilFilter = semuaJadwal.where((item) {
        final itemKapsterId = getId(item, ['id_kapster']);

        final statusSlot = getString(
          item,
          ['status_slot'],
          defaultValue: 'tersedia',
        ).toLowerCase();

        return itemKapsterId == kapsterId &&
            statusSlot == 'tersedia';
      }).toList();

      if (!mounted) return;

      setState(() {
        jadwalList = hasilFilter;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Gagal mengambil jadwal: $e';
        loading = false;
      });
    }
  }

  void _pilihJadwal(dynamic item) {
    final jadwalTerpilih = Map<String, dynamic>.from(item);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KonfirmasiPage(
          layanan: widget.layanan,
          kapster: widget.kapster,
          jadwal: jadwalTerpilih,
          pelanggan: widget.pelanggan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final namaLayanan = widget.layanan
        .map((l) => getString(l, ['nama_layanan', 'nama']))
        .join(', ');

    final namaKapster = getString(
      widget.kapster,
      ['nama_kapster', 'nama'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Jadwal'),
      ),

      body: RefreshIndicator(
        onRefresh: loadJadwal,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // =================================================
            // RINGKASAN LAYANAN + KAPSTER
            // =================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.content_cut,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(namaLayanan)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: 10),
                        Text(namaKapster),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Jadwal Tersedia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: loadJadwal,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else if (jadwalList.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('Belum ada jadwal tersedia.'),
                  ),
                ),
              )
            else
              ...jadwalList.map((item) {
                final tanggal = getString(
                  item,
                  ['tanggal', 'tgl'],
                );

                final jamMulai = getString(
                  item,
                  ['jam_mulai', 'jam', 'waktu'],
                );

                final jamSelesai = getString(
                  item,
                  ['jam_selesai'],
                  defaultValue: '',
                );

                final jamTampil = jamSelesai.isNotEmpty
                    ? '$jamMulai - $jamSelesai'
                    : jamMulai;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.calendar_month),
                    ),
                    title: Text(
                      tanggal,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(jamTampil),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () => _pilihJadwal(item),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}