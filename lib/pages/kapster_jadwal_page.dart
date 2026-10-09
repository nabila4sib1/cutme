import 'dart:io';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../utils/pilih_foto.dart';

// ============================================================
// KAPSTER JADWAL PAGE
// ============================================================
//
// Halaman beranda untuk role "Kapster" setelah login:
//  - Tab "Booking": dashboard ringkas (card statistik hari ini)
//    + daftar booking hari ini dengan tombol ubah status
//  - Tab "Jadwal Saya": slot jadwal pribadi kapster ini
//  - Tab "Riwayat": booking yang sudah selesai (semua waktu)

class KapsterJadwalPage extends StatefulWidget {
  final Map kapster;

  const KapsterJadwalPage({
    super.key,
    required this.kapster,
  });

  @override
  State<KapsterJadwalPage> createState() =>
      _KapsterJadwalPageState();
}

class _KapsterJadwalPageState extends State<KapsterJadwalPage> {
  bool loading = true;
  int selectedIndex = 0;

  List<dynamic> jadwal = [];
  List<dynamic> booking = [];

  // id_layanan -> nama_layanan, buat nampilin nama layanan di
  // kartu booking tanpa perlu ubah relasi di backend.
  Map<int, String> layananMap = {};

  // id booking yang sedang di-update (buat nampilin loading di tombol)
  final Set<int> sedangUpdate = {};

  int get idKapster => getId(
        widget.kapster,
        ['id_kapster', 'id'],
      );

  String get namaKapster => getString(
        widget.kapster,
        ['nama', 'nama_kapster'],
        defaultValue: 'Kapster',
      );

  String get _hariIniStr {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    loadSemua();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadSemua() async {
    try {
      final hasil = await Future.wait([
        ApiService.getJadwalKapster(),
        ApiService.getBooking(idKapster: idKapster),
        ApiService.getLayanan(),
      ]);

      if (!mounted) return;

      // API jadwal mengembalikan semua kapster, jadi disaring di sini
      // supaya hanya jadwal milik kapster yang login.
      final semuaJadwal = extractList(hasil[0]);

      final jadwalSaya = semuaJadwal
          .where(
            (j) => getId(j, ['id_kapster']) == idKapster,
          )
          .toList();

      final bookingSaya = extractList(hasil[1]);

      final layananList = extractList(hasil[2]);

      final map = <int, String>{};

      for (final l in layananList) {
        final id = getId(
          l,
          ['id_layanan', 'id'],
        );

        map[id] = getString(
          l,
          ['nama_layanan', 'nama'],
          defaultValue: 'Layanan',
        );
      }

      setState(() {
        jadwal = jadwalSaya;
        booking = bookingSaya;
        layananMap = map;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data: $e'),
        ),
      );
    }
  }

  String namaLayananUntuk(dynamic item) {
    final detail = item is Map
        ? item['detailBookings']
        : null;

    if (detail is List && detail.isNotEmpty) {
      final idLayanan = getId(
        detail.first,
        ['id_layanan'],
      );

      return layananMap[idLayanan] ?? 'Layanan';
    }

    return 'Layanan';
  }

  // ============================================================
  // UBAH STATUS BOOKING
  // ============================================================

  String? statusBerikutnya(String status) {
    switch (status) {
      case 'menunggu_konfirmasi':
        return 'datang';

      case 'datang':
        return 'dilayani';

      case 'dilayani':
        return 'selesai';

      default:
        return null;
    }
  }

  String labelTombol(String status) {
    switch (status) {
      case 'menunggu_konfirmasi':
        return 'Konfirmasi Datang';

      case 'datang':
        return 'Mulai Layani';

      case 'dilayani':
        return 'Selesai';

      default:
        return '';
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

  Future<void> ubahStatus(dynamic item) async {
    final idBooking = getId(
      item,
      ['id_booking', 'id'],
    );

    final statusSekarang = getString(
      item,
      ['status'],
    );

    final statusBaru = statusBerikutnya(statusSekarang);

    if (idBooking == 0 || statusBaru == null) return;

    setState(() {
      sedangUpdate.add(idBooking);
    });

    try {
      await ApiService.updateStatusBooking(
        idBooking: idBooking,
        status: statusBaru,
      );

      if (!mounted) return;

      await loadSemua();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status diubah: ${labelStatus(statusBaru)}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengubah status: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sedangUpdate.remove(idBooking);
        });
      }
    }
  }

  // ============================================================
  // UPLOAD HASIL KERJA
  // ============================================================

  //
  // Bebas, tidak terikat ke booking/layanan tertentu di database
  // (cuma judul + foto) - tapi dipicu dari kartu booking yang
  // sudah selesai, judul-nya di-prefill dari nama layanan biar
  // kapster tidak perlu ngetik dari nol.

  Future<void> uploadHasilKerja({
    String judulAwal = '',
  }) async {
    final path = await pilihFoto(context);

    if (path == null) return;
    if (!mounted) return;

    final judulController = TextEditingController(
      text: judulAwal,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;
        String? errorText;

        return StatefulBuilder(
          builder: (
            dialogBuilderContext,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Upload Hasil Kerja'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(path),
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: judulController,
                      enabled: !saving,
                      decoration: const InputDecoration(
                        labelText:
                            'Judul (mis. "Hasil Cat Rambut")',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 8),

                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),

                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (judulController.text
                              .trim()
                              .isEmpty) {
                            setDialogState(() {
                              errorText =
                                  'Judul wajib diisi';
                            });

                            return;
                          }

                          setDialogState(() {
                            saving = true;
                            errorText = null;
                          });

                          try {
                            await ApiService.createGaleri(
                              idKapster: idKapster,
                              judul:
                                  judulController.text.trim(),
                              fotoPath: path,
                            );

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Foto hasil kerja berhasil diunggah',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              saving = false;
                              errorText =
                                  'Gagal mengunggah: $e';
                            });
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Unggah'),
                ),
              ],
            );
          },
        );
      },
    );

    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        judulController.dispose();
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  // ============================================================
  // FORMAT HELPER
  // ============================================================

  String _potongTanggal(String raw) {
    if (raw.length >= 10) {
      final bagian = raw
          .substring(0, 10)
          .split('-');

      if (bagian.length == 3) {
        return '${bagian[2]}/${bagian[1]}/${bagian[0]}';
      }
    }

    return raw;
  }

  String _potongJam(String raw) {
    return raw.length >= 5
        ? raw.substring(0, 5)
        : raw;
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $namaKapster 👋'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : IndexedStack(
              index: selectedIndex,
              children: [
                _tabBeranda(),
                _tabJadwal(),
                _tabRiwayat(),
              ],
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Booking',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Jadwal Saya',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB: BERANDA (statistik + booking hari ini)
  // ============================================================

  Widget _tabBeranda() {

    // ============================================================
    // PERBAIKAN:
    // Booking Hari Ini berdasarkan tanggal JADWAL,
    // bukan berdasarkan tgl_booking.
    //
    // tgl_booking = kapan pelanggan membuat booking
    // jadwal.tanggal = kapan pelanggan akan datang
    // ============================================================

    final bookingHariIni = booking.where((item) {
      final jadwalData =
          item is Map && item['jadwal'] is Map
              ? item['jadwal']
              : null;

      if (jadwalData == null) return false;

      return getString(
        jadwalData,
        ['tanggal'],
      ).startsWith(_hariIniStr);
    }).toList();

    final jumlahMenunggu = bookingHariIni
        .where(
          (i) =>
              getString(i, ['status']) ==
              'menunggu_konfirmasi',
        )
        .length;

    final jumlahSelesai = bookingHariIni
        .where(
          (i) =>
              getString(i, ['status']) ==
              'selesai',
        )
        .length;

    return RefreshIndicator(
      onRefresh: loadSemua,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =================================================
          // KARTU STATISTIK
          // =================================================

          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.calendar_month,
                  color: AppColors.ink,
                  value: bookingHariIni.length.toString(),
                  label: 'Booking',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _statCard(
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                  value: jumlahMenunggu.toString(),
                  label: 'Menunggu',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _statCard(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  value: jumlahSelesai.toString(),
                  label: 'Selesai',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Booking Hari Ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (bookingHariIni.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Belum ada booking hari ini.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...bookingHariIni.map(_kartuBooking),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuBooking(dynamic item) {
    final idBooking = getId(
      item,
      ['id_booking', 'id'],
    );

    final status = getString(
      item,
      ['status'],
    );

    final total = getDouble(
      item,
      ['total_biaya'],
    );

    final namaLayanan = namaLayananUntuk(item);

    final pelanggan =
        item is Map && item['pelanggan'] is Map
            ? item['pelanggan']
            : null;

    final namaPelanggan = pelanggan != null
        ? getString(
            pelanggan,
            ['nama', 'nama_pelanggan'],
            defaultValue: 'Pelanggan',
          )
        : 'Pelanggan';

    final jadwalData =
        item is Map && item['jadwal'] is Map
            ? item['jadwal']
            : null;

    final tanggal = jadwalData != null
        ? _potongTanggal(
            getString(
              jadwalData,
              ['tanggal'],
            ),
          )
        : '-';

    final jamMulai = jadwalData != null
        ? _potongJam(
            getString(
              jadwalData,
              ['jam_mulai'],
            ),
          )
        : '';

    final jamSelesai = jadwalData != null
        ? _potongJam(
            getString(
              jadwalData,
              ['jam_selesai'],
            ),
          )
        : '';

    final berikutnya = statusBerikutnya(status);

    final updating =
        sedangUpdate.contains(idBooking);

    final warna = warnaStatus(status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

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

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.content_cut,
                  size: 16,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Text(namaLayanan),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Text(tanggal),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Text(
                  '$jamMulai - $jamSelesai',
                ),
              ],
            ),

            const Divider(
              height: 24,
            ),

            Row(
              children: [
                Text(
                  'Total: Rp ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (berikutnya != null) ...[
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,

                child: FilledButton(
                  onPressed: updating
                      ? null
                      : () => ubahStatus(item),

                  child: updating
                      ? const SizedBox(
                          width: 18,
                          height: 18,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          labelTombol(status),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB: JADWAL SAYA
  // ============================================================

  Widget _tabJadwal() {
    return RefreshIndicator(
      onRefresh: loadSemua,

      child: jadwal.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 200),

                Center(
                  child: Text(
                    'Belum ada jadwal.',
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: jadwal.length,

              itemBuilder: (context, index) {
                final item = jadwal[index];

                final tanggal = _potongTanggal(
                  getString(
                    item,
                    ['tanggal'],
                  ),
                );

                final jamMulai = _potongJam(
                  getString(
                    item,
                    ['jam_mulai'],
                  ),
                );

                final jamSelesai = _potongJam(
                  getString(
                    item,
                    ['jam_selesai'],
                  ),
                );

                final statusSlot = getString(
                  item,
                  ['status_slot'],
                  defaultValue: 'tersedia',
                );

                final tersedia =
                    statusSlot == 'tersedia';

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.calendar_month,
                      ),
                    ),

                    title: Text(tanggal),

                    subtitle: Text(
                      '$jamMulai - $jamSelesai',
                    ),

                    trailing: Chip(
                      label: Text(
                        tersedia
                            ? 'Tersedia'
                            : 'Dipesan',
                      ),

                      backgroundColor: tersedia
                          ? Colors.green.withValues(
                              alpha: 0.12,
                            )
                          : Colors.orange.withValues(
                              alpha: 0.12,
                            ),

                      labelStyle: TextStyle(
                        color: tersedia
                            ? Colors.green[800]
                            : Colors.orange[800],
                        fontSize: 12,
                      ),

                      side: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ============================================================
  // TAB: RIWAYAT
  // ============================================================

  Widget _tabRiwayat() {
    final riwayat = booking
        .where(
          (i) =>
              getString(i, ['status']) ==
              'selesai',
        )
        .toList();

    return RefreshIndicator(
      onRefresh: loadSemua,

      child: riwayat.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 200),

                Center(
                  child: Text(
                    'Belum ada riwayat booking selesai.',
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: riwayat.length,

              itemBuilder: (context, index) {
                final item = riwayat[index];

                final namaLayanan =
                    namaLayananUntuk(item);

                final total = getDouble(
                  item,
                  ['total_biaya'],
                );

                final pelanggan =
                    item is Map &&
                            item['pelanggan'] is Map
                        ? item['pelanggan']
                        : null;

                final namaPelanggan =
                    pelanggan != null
                        ? getString(
                            pelanggan,
                            [
                              'nama',
                              'nama_pelanggan',
                            ],
                            defaultValue:
                                'Pelanggan',
                          )
                        : 'Pelanggan';

                final jadwalData =
                    item is Map &&
                            item['jadwal'] is Map
                        ? item['jadwal']
                        : null;

                final tanggal =
                    jadwalData != null
                        ? _potongTanggal(
                            getString(
                              jadwalData,
                              ['tanggal'],
                            ),
                          )
                        : '-';

                final ulasanData =
                    item is Map &&
                            item['ulasan'] is Map
                        ? item['ulasan']
                        : null;

                final rating =
                    ulasanData != null
                        ? getDouble(
                            ulasanData,
                            ['rating'],
                          ).round()
                        : null;

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

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
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            Text(
                              'Rp ${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '$namaLayanan • $tanggal',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        if (rating != null) ...[
                          const SizedBox(height: 6),

                          Row(
                            children:
                                List.generate(
                              5,
                              (i) {
                                return Icon(
                                  i < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 15,
                                  color:
                                      Colors.amber,
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,

                          child:
                              OutlinedButton.icon(
                            onPressed: () =>
                                uploadHasilKerja(
                              judulAwal:
                                  'Hasil $namaLayanan',
                            ),

                            icon: const Icon(
                              Icons
                                  .add_a_photo_outlined,
                            ),

                            label: const Text(
                              'Upload Hasil Kerja',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}