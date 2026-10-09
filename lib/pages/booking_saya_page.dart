import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// BOOKING SAYA PAGE
// ============================================================
//
// Riwayat booking milik pelanggan yang login, dengan status
// yang di-update kapster (menunggu_konfirmasi -> datang ->
// dilayani -> selesai). Kalau sudah selesai dan belum diberi
// ulasan, pelanggan bisa memberi rating + komentar.
//
// Dipakai sebagai isi tab "Booking" di HomePage, jadi TIDAK
// punya Scaffold/AppBar sendiri.

class BookingSayaPage extends StatefulWidget {
  final Map pelanggan;

  const BookingSayaPage({
    super.key,
    required this.pelanggan,
  });

  @override
  State<BookingSayaPage> createState() => _BookingSayaPageState();
}

class _BookingSayaPageState extends State<BookingSayaPage> {
  bool loading = true;
  List<dynamic> booking = [];

  int get idPelanggan =>
      getId(widget.pelanggan, ['id_pelanggan', 'id']);

  @override
  void initState() {
    super.initState();
    loadBooking();
  }

  Future<void> loadBooking() async {
    try {
      final response = await ApiService.getBooking(
        idPelanggan: idPelanggan,
      );

      if (!mounted) return;

      final data = extractList(response);

      // Yang belum selesai ditaruh di atas.
      data.sort((a, b) {
        final aSelesai = getString(a, ['status']) == 'selesai';
        final bSelesai = getString(b, ['status']) == 'selesai';
        if (aSelesai == bSelesai) return 0;
        return aSelesai ? 1 : -1;
      });

      setState(() {
        booking = data;
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
        return 'Menunggu konfirmasi';
      case 'datang':
        return 'Kamu sudah datang';
      case 'dilayani':
        return 'Sedang dilayani';
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

  String _potongTanggal(String raw) {
    if (raw.length >= 10) {
      final bagian = raw.substring(0, 10).split('-');
      if (bagian.length == 3) {
        return '${bagian[2]}/${bagian[1]}/${bagian[0]}';
      }
    }
    return raw;
  }

  String _potongJam(String raw) {
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  // ============================================================
  // BATALKAN BOOKING
  // ============================================================
  //
  // Hanya bisa dilakukan selama status masih 'menunggu_konfirmasi'
  // (kapster belum memproses). Server juga menolak kalau sudah
  // lewat dari status itu, ini cuma jaga-jaga di sisi UI.

  Future<void> batalkanBooking(dynamic item) async {
    final idBooking = getId(item, ['id_booking', 'id']);

    if (idBooking == 0) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Booking?'),
          content: const Text(
            'Slot jadwal yang kamu pesan akan dibuka lagi untuk '
            'pelanggan lain. Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Tidak'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) return;

    try {
      await ApiService.cancelBooking(idBooking: idBooking);

      if (!mounted) return;

      await loadBooking();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil dibatalkan'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membatalkan: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BERI ULASAN
  // ============================================================

  Future<void> beriUlasan(dynamic item) async {
    final idBooking = getId(item, ['id_booking', 'id']);

    if (idBooking == 0) return;

    int rating = 5;
    final komentarController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;
        String? errorText;

        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Beri Ulasan'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final bintangKe = i + 1;

                        return IconButton(
                          onPressed: saving
                              ? null
                              : () {
                                  setDialogState(() {
                                    rating = bintangKe;
                                  });
                                },
                          icon: Icon(
                            bintangKe <= rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: komentarController,
                      enabled: !saving,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Komentar (opsional)',
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
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Batal'),
                ),

                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setDialogState(() {
                            saving = true;
                            errorText = null;
                          });

                          try {
                            await ApiService.createUlasan(
                              idBooking: idBooking,
                              idPelanggan: idPelanggan,
                              rating: rating,
                              komentar:
                                  komentarController.text.trim().isEmpty
                                      ? null
                                      : komentarController.text.trim(),
                            );

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            await loadBooking();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Terima kasih atas ulasannya',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                              errorText =
                                  'Gagal: ${e.toString().replaceFirst('Exception: ', '')}';
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
                      : const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      komentarController.dispose();
    });
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return loading
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

                        final jadwalData =
                            item is Map && item['jadwal'] is Map
                                ? item['jadwal']
                                : null;

                        final tanggal = jadwalData != null
                            ? _potongTanggal(
                                getString(jadwalData, ['tanggal']),
                              )
                            : '-';

                        final jamMulai = jadwalData != null
                            ? _potongJam(
                                getString(jadwalData, ['jam_mulai']),
                              )
                            : '';

                        final jamSelesai = jadwalData != null
                            ? _potongJam(
                                getString(jadwalData, ['jam_selesai']),
                              )
                            : '';

                        final sudahAdaUlasan =
                            item is Map && item['ulasan'] != null;

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
                                        namaKapster,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label:
                                          Text(labelStatus(status)),
                                      backgroundColor: warna
                                          .withValues(alpha: 0.12),
                                      labelStyle: TextStyle(
                                        color: warna,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  '$tanggal • $jamMulai - $jamSelesai',
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  'Total: Rp ${total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                if (status ==
                                    'menunggu_konfirmasi') ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      onPressed: () =>
                                          batalkanBooking(item),
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                      ),
                                      label: const Text(
                                        'Batalkan Booking',
                                      ),
                                    ),
                                  ),
                                ],

                                if (status == 'selesai' &&
                                    !sudahAdaUlasan) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          beriUlasan(item),
                                      icon: const Icon(
                                        Icons.star_border,
                                      ),
                                      label: const Text(
                                        'Beri Ulasan',
                                      ),
                                    ),
                                  ),
                                ] else if (sudahAdaUlasan) ...[
                                  const SizedBox(height: 8),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Sudah diberi ulasan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          );
  }
}