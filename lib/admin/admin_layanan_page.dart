import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// ADMIN LAYANAN
// ============================================================

class AdminLayananPage extends StatefulWidget {
  const AdminLayananPage({super.key});

  @override
  State<AdminLayananPage> createState() =>
      _AdminLayananPageState();
}

class _AdminLayananPageState extends State<AdminLayananPage> {
  bool loading = true;

  List<dynamic> layanan = [];

  @override
  void initState() {
    super.initState();
    loadLayanan();
  }

  // ============================================================
  // LOAD DATA LAYANAN
  // ============================================================

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

  // ============================================================
  // TAMBAH LAYANAN
  // ============================================================

  Future<void> tambahLayanan() async {
    final namaController = TextEditingController();
    final hargaController = TextEditingController();
    final durasiController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Layanan'),

              content: Form(
                key: formKey,

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama layanan',
                          prefixIcon: Icon(Icons.content_cut),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Nama layanan wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: hargaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          prefixText: 'Rp ',
                          prefixIcon: Icon(Icons.payments),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Harga wajib diisi';
                          }

                          final harga =
                              double.tryParse(value.trim());

                          if (harga == null) {
                            return 'Harga harus berupa angka';
                          }

                          if (harga < 0) {
                            return 'Harga tidak boleh negatif';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: durasiController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Durasi',
                          suffixText: 'menit',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Durasi wajib diisi';
                          }

                          final durasi =
                              int.tryParse(value.trim());

                          if (durasi == null) {
                            return 'Durasi harus berupa angka';
                          }

                          if (durasi <= 0) {
                            return 'Durasi harus lebih dari 0';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
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
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            await ApiService.createLayanan(
                              namaLayanan:
                                  namaController.text.trim(),
                              harga: double.parse(
                                hargaController.text.trim(),
                              ),
                              durasiMenit: int.parse(
                                durasiController.text.trim(),
                              ),
                            );

                            // Tutup dialog DULU sebelum melakukan
                            // setState() di halaman induk (loadLayanan).
                            // Kalau urutannya dibalik, Form + GlobalKey
                            // di dalam dialog bisa ke-rebuild bersamaan
                            // dengan proses dispose dialog, sehingga
                            // memicu assertion '_dependents.isEmpty'.
                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            await loadLayanan();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Layanan berhasil ditambahkan',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menambahkan layanan: $e',
                                ),
                              ),
                            );
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
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    // Beri jeda sebelum dispose supaya animasi keluar AlertDialog
    // (fade/scale, ~200-300ms) selesai dulu. Kalau di-dispose
    // langsung, TextFormField yang masih mid-animasi bisa kebentur
    // controller yang sudah disposed -> "used after being disposed".
    Future.delayed(const Duration(milliseconds: 300), () {
      namaController.dispose();
      hargaController.dispose();
      durasiController.dispose();
    });
  }

  // ============================================================
  // EDIT LAYANAN
  // ============================================================

  Future<void> editLayanan(dynamic item) async {
    final id = getId(
      item,
      ['id_layanan', 'id'],
    );

    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID layanan tidak ditemukan'),
        ),
      );
      return;
    }

    final namaController = TextEditingController(
      text: getString(
        item,
        ['nama_layanan', 'nama'],
        defaultValue: '',
      ),
    );

    final hargaController = TextEditingController(
      text: getDouble(
        item,
        ['harga'],
      ).toStringAsFixed(0),
    );

    final durasiController = TextEditingController(
      text: getString(
        item,
        ['durasi_menit', 'durasi'],
        defaultValue: '',
      ),
    );

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Layanan'),

              content: Form(
                key: formKey,

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama layanan',
                          prefixIcon: Icon(Icons.content_cut),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Nama layanan wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: hargaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          prefixText: 'Rp ',
                          prefixIcon: Icon(Icons.payments),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Harga wajib diisi';
                          }

                          final harga =
                              double.tryParse(value.trim());

                          if (harga == null) {
                            return 'Harga harus berupa angka';
                          }

                          if (harga < 0) {
                            return 'Harga tidak boleh negatif';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: durasiController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Durasi',
                          suffixText: 'menit',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Durasi wajib diisi';
                          }

                          final durasi =
                              int.tryParse(value.trim());

                          if (durasi == null) {
                            return 'Durasi harus berupa angka';
                          }

                          if (durasi <= 0) {
                            return 'Durasi harus lebih dari 0';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
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
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            await ApiService.updateLayanan(
                              idLayanan: id,
                              namaLayanan:
                                  namaController.text.trim(),
                              harga: double.parse(
                                hargaController.text.trim(),
                              ),
                              durasiMenit: int.parse(
                                durasiController.text.trim(),
                              ),
                            );

                            // Tutup dialog DULU sebelum melakukan
                            // setState() di halaman induk (loadLayanan).
                            // Kalau urutannya dibalik, Form + GlobalKey
                            // di dalam dialog bisa ke-rebuild bersamaan
                            // dengan proses dispose dialog, sehingga
                            // memicu assertion '_dependents.isEmpty'.
                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            await loadLayanan();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Layanan berhasil diubah',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal mengubah layanan: $e',
                                ),
                              ),
                            );
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
                      : const Text('Simpan Perubahan'),
                ),
              ],
            );
          },
        );
      },
    );

    // Beri jeda sebelum dispose supaya animasi keluar AlertDialog
    // (fade/scale, ~200-300ms) selesai dulu. Kalau di-dispose
    // langsung, TextFormField yang masih mid-animasi bisa kebentur
    // controller yang sudah disposed -> "used after being disposed".
    Future.delayed(const Duration(milliseconds: 300), () {
      namaController.dispose();
      hargaController.dispose();
      durasiController.dispose();
    });
  }

  // ============================================================
  // HAPUS LAYANAN
  // ============================================================

  Future<void> hapusLayanan(dynamic item) async {
    final id = getId(
      item,
      ['id_layanan', 'id'],
    );

    final nama = getString(
      item,
      ['nama_layanan', 'nama'],
      defaultValue: 'layanan ini',
    );

    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID layanan tidak ditemukan'),
        ),
      );
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Layanan?'),

          content: Text(
            'Apakah kamu yakin ingin menghapus "$nama"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    try {
      await ApiService.deleteLayanan(id);

      if (!mounted) return;

      await loadLayanan();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan berhasil dihapus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus layanan: $e'),
        ),
      );
    }
  }

  // ============================================================
  // MENU LAYANAN
  // ============================================================

  void tampilkanMenuLayanan(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Layanan'),
                onTap: () {
                  Navigator.pop(context);
                  editLayanan(item);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text(
                  'Hapus Layanan',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  hapusLayanan(item);
                },
              ),

              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Batal'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          margin:
                              const EdgeInsets.only(bottom: 12),

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

                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: 6),
                              child: Text(
                                'Rp ${harga.toStringAsFixed(0)} • $durasi menit',
                              ),
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                tampilkanMenuLayanan(item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_admin_layanan',
        onPressed: tambahLayanan,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}