import 'dart:io';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../utils/pilih_foto.dart';

// ============================================================
// ADMIN KAPSTER
// ============================================================

class AdminKapsterPage extends StatefulWidget {
  const AdminKapsterPage({super.key});

  @override
  State<AdminKapsterPage> createState() =>
      _AdminKapsterPageState();
}

class _AdminKapsterPageState extends State<AdminKapsterPage> {
  bool loading = true;

  List<dynamic> kapster = [];

  @override
  void initState() {
    super.initState();
    loadKapster();
  }

  // ============================================================
  // LOAD DATA KAPSTER
  // ============================================================

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

  // ============================================================
  // TAMBAH KAPSTER
  // ============================================================

  Future<void> tambahKapster() async {
    final namaController = TextEditingController();
    final noHpController = TextEditingController();
    final passwordController = TextEditingController();
    final spesialisasiController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    String? fotoPath;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            Future<void> pilihFotoKapster() async {
              final path = await pilihFoto(dialogBuilderContext);

              if (path != null) {
                setDialogState(() {
                  fotoPath = path;
                });
              }
            }

            return AlertDialog(
              title: const Text('Tambah Kapster'),

              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: saving ? null : pilihFotoKapster,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                AppColors.goldSoft,
                            backgroundImage: fotoPath != null
                                ? FileImage(File(fotoPath!))
                                : null,
                            child: fotoPath == null
                                ? const Icon(
                                    Icons.add_a_photo,
                                    color: AppColors.ink,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Center(
                        child: TextButton(
                          onPressed: saving ? null : pilihFotoKapster,
                          child: Text(
                            fotoPath == null
                                ? 'Pilih Foto (opsional)'
                                : 'Ganti Foto',
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama kapster',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Nama kapster wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: noHpController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'No. HP',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'No. HP wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password (min. 6 karakter)',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi';
                          }

                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: spesialisasiController,
                        decoration: const InputDecoration(
                          labelText: 'Spesialisasi (opsional)',
                          prefixIcon: Icon(Icons.content_cut),
                        ),
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

                          String? pesanTambahan;

                          try {
                            final hasil = await ApiService.createKapster(
                              nama: namaController.text.trim(),
                              noHp: noHpController.text.trim(),
                              password: passwordController.text,
                              spesialisasi:
                                  spesialisasiController.text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : spesialisasiController
                                          .text
                                          .trim(),
                            );

                            // Upload foto (kalau dipilih) SETELAH
                            // kapster berhasil dibuat, karena perlu
                            // id_kapster yang baru. Kalau upload foto
                            // gagal, kapster tetap dianggap berhasil
                            // ditambahkan (foto bisa diatur ulang
                            // lewat menu "Ganti Foto").
                            if (fotoPath != null) {
                              final dataBaru = extractMap(hasil);

                              final idBaru = getId(
                                dataBaru,
                                ['id_kapster', 'id'],
                              );

                              if (idBaru != 0) {
                                try {
                                  await ApiService.uploadFotoKapster(
                                    idKapster: idBaru,
                                    fotoPath: fotoPath!,
                                  );
                                } catch (e) {
                                  pesanTambahan =
                                      ' (tapi upload foto gagal: $e)';
                                }
                              }
                            }

                            // Tutup dialog DULU sebelum melakukan
                            // setState() di halaman induk (loadKapster).
                            // Kalau urutannya dibalik, Form + GlobalKey
                            // di dalam dialog bisa ke-rebuild bersamaan
                            // dengan proses dispose dialog, sehingga
                            // memicu assertion '_dependents.isEmpty'.
                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            await loadKapster();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Kapster berhasil ditambahkan'
                                  '${pesanTambahan ?? ''}',
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
                                  'Gagal menambahkan kapster: $e',
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
      noHpController.dispose();
      passwordController.dispose();
      spesialisasiController.dispose();
    });
  }

  // ============================================================
  // HAPUS KAPSTER
  // ============================================================

  Future<void> hapusKapster(dynamic item) async {
    final id = getId(
      item,
      ['id_kapster', 'id'],
    );

    final nama = getString(
      item,
      ['nama_kapster', 'nama'],
      defaultValue: 'kapster ini',
    );

    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID kapster tidak ditemukan'),
        ),
      );
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kapster?'),

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
      await ApiService.deleteKapster(id);

      if (!mounted) return;

      await loadKapster();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kapster berhasil dihapus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus kapster: $e'),
        ),
      );
    }
  }

  // ============================================================
  // ATUR PASSWORD KAPSTER
  // ============================================================
  //
  // Dipakai untuk set/ganti password kapster (termasuk kapster lama
  // yang belum punya password sama sekali).

  Future<void> aturPasswordKapster(dynamic item) async {
    final id = getId(
      item,
      ['id_kapster', 'id'],
    );

    final nama = getString(
      item,
      ['nama_kapster', 'nama'],
      defaultValue: 'kapster ini',
    );

    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID kapster tidak ditemukan'),
        ),
      );
      return;
    }

    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;
        String? errorText;

        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: Text('Atur Password: $nama'),

              content: TextField(
                controller: passwordController,
                obscureText: true,
                enabled: !saving,
                decoration: InputDecoration(
                  labelText: 'Password baru (min. 6 karakter)',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: errorText,
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
                          if (passwordController.text.length < 6) {
                            setDialogState(() {
                              errorText =
                                  'Password minimal 6 karakter';
                            });
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                            errorText = null;
                          });

                          try {
                            await ApiService.updateKapster(
                              idKapster: id,
                              password: passwordController.text,
                            );

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password berhasil diatur',
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
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    // Jeda dispose supaya animasi keluar dialog selesai dulu.
    Future.delayed(const Duration(milliseconds: 300), () {
      passwordController.dispose();
    });
  }

  // ============================================================
  // GANTI FOTO KAPSTER
  // ============================================================

  Future<void> gantiFotoKapster(dynamic item) async {
    final id = getId(item, ['id_kapster', 'id']);

    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID kapster tidak ditemukan'),
        ),
      );
      return;
    }

    final path = await pilihFoto(context);

    if (path == null) return;
    if (!mounted) return;

    try {
      await ApiService.uploadFotoKapster(
        idKapster: id,
        fotoPath: path,
      );

      if (!mounted) return;

      await loadKapster();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto kapster berhasil diperbarui'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah foto: $e'),
        ),
      );
    }
  }

  // ============================================================
  // MENU KAPSTER
  // ============================================================

  void tampilkanMenuKapster(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ganti Foto'),
                onTap: () {
                  Navigator.pop(context);
                  gantiFotoKapster(item);
                },
              ),

              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Atur Password'),
                onTap: () {
                  Navigator.pop(context);
                  aturPasswordKapster(item);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text(
                  'Hapus Kapster',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  hapusKapster(item);
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

                        final fotoUrl = getString(
                          item,
                          ['foto_url'],
                          defaultValue: '',
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
                              backgroundImage: fotoUrl.isNotEmpty
                                  ? NetworkImage(fotoUrl)
                                  : null,
                              child: fotoUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.ink,
                                    )
                                  : null,
                            ),

                            title: Text(
                              nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                tampilkanMenuKapster(item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_admin_kapster',
        onPressed: tambahKapster,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}