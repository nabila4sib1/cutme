import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

// ============================================================
// ADMIN JADWAL KAPSTER
// ============================================================
//
// Halaman ini untuk ADMIN membuat slot jadwal (tanggal + jam)
// untuk kapster tertentu. Setelah dibuat di sini, slot ini akan
// muncul di:
//  - Halaman KapsterJadwalPage (kapster login lihat jadwalnya)
//  - Halaman booking milik pelanggan (pilih slot yang tersedia)

class AdminJadwalPage extends StatefulWidget {
  const AdminJadwalPage({super.key});

  @override
  State<AdminJadwalPage> createState() => _AdminJadwalPageState();
}

class _AdminJadwalPageState extends State<AdminJadwalPage> {
  bool loading = true;

  List<dynamic> jadwal = [];

  @override
  void initState() {
    super.initState();
    loadJadwal();
  }

  // ============================================================
  // FORMAT HELPER (tanggal & jam)
  // ============================================================

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Format buat dikirim ke API: 'YYYY-MM-DD'
  String _formatTanggalApi(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  // Format buat ditampilkan ke admin: 'DD/MM/YYYY'
  String _formatTanggalTampilan(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  // Format buat dikirim ke API: 'HH:mm'
  String _formatJamApi(TimeOfDay time) {
    return '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
  }

  DateTime? _parseTanggal(String raw) {
    if (raw.isEmpty) return null;
    // Ambil 10 karakter pertama saja ('YYYY-MM-DD'), jaga-jaga
    // kalau backend mengirim format dengan jam/timezone ikutan.
    final cleaned = raw.length >= 10 ? raw.substring(0, 10) : raw;
    return DateTime.tryParse(cleaned);
  }

  TimeOfDay? _parseJam(String raw) {
    if (raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  // ============================================================
  // LOAD DATA JADWAL
  // ============================================================

  Future<void> loadJadwal() async {
    try {
      final response = await ApiService.getJadwalKapster();

      if (!mounted) return;

      setState(() {
        jadwal = extractList(response);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil jadwal: $e'),
        ),
      );
    }
  }

  // ============================================================
  // SLOT JAM BAKU (09:00 - 17:00, per 1 jam)
  // ============================================================
  //
  // Daripada admin ngetik/pilih jam manual satu-satu, admin
  // tinggal TANDAI slot jam mana aja yang mau dibuka untuk
  // kapster+tanggal tertentu. Mau ubah jam operasional toko,
  // tinggal edit list ini.

  static const List<(String, String)> _slotBaku = [
    ('09:00', '10:00'),
    ('10:00', '11:00'),
    ('11:00', '12:00'),
    ('13:00', '14:00'),
    ('14:00', '15:00'),
    ('15:00', '16:00'),
    ('16:00', '17:00'),
  ];

  // ============================================================
  // TAMBAH JADWAL
  // ============================================================

  Future<void> tambahJadwal() async {
    // Ambil daftar kapster dulu buat dropdown, SEBELUM dialog
    // dibuka (biar dialognya nggak perlu nge-load lagi di
    // dalam).
    List<dynamic> kapsterList;

    try {
      final response = await ApiService.getKapster();
      kapsterList = extractList(response);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data kapster: $e'),
        ),
      );
      return;
    }

    if (kapsterList.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Belum ada kapster. Tambahkan kapster dulu di menu Kapster.',
          ),
        ),
      );
      return;
    }

    int? selectedKapsterId;
    DateTime? selectedTanggal;
    final Set<int> selectedSlot = {};
    String? errorText;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Jadwal'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedKapsterId,
                      decoration: const InputDecoration(
                        labelText: 'Kapster',
                        prefixIcon: Icon(Icons.person),
                      ),
                      hint: const Text('Pilih kapster'),
                      items: kapsterList.map((k) {
                        final id = getId(k, ['id_kapster', 'id']);

                        final nama = getString(
                          k,
                          ['nama_kapster', 'nama'],
                          defaultValue: 'Kapster #$id',
                        );

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(nama),
                        );
                      }).toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedKapsterId = value;
                              });
                            },
                    ),

                    const SizedBox(height: 12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        selectedTanggal == null
                            ? 'Pilih tanggal'
                            : _formatTanggalTampilan(
                                selectedTanggal!,
                              ),
                      ),
                      onTap: saving
                          ? null
                          : () async {
                              final now = DateTime.now();

                              final picked = await showDatePicker(
                                context: dialogBuilderContext,
                                initialDate:
                                    selectedTanggal ?? now,
                                firstDate: now.subtract(
                                  const Duration(days: 1),
                                ),
                                lastDate: now.add(
                                  const Duration(days: 365),
                                ),
                              );

                              if (picked != null) {
                                setDialogState(() {
                                  selectedTanggal = picked;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Tandai Slot Jam',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_slotBaku.length, (i) {
                        final slot = _slotBaku[i];
                        final terpilih = selectedSlot.contains(i);

                        return FilterChip(
                          label: Text('${slot.$1}-${slot.$2}'),
                          selected: terpilih,
                          onSelected: saving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    if (value) {
                                      selectedSlot.add(i);
                                    } else {
                                      selectedSlot.remove(i);
                                    }
                                  });
                                },
                        );
                      }),
                    ),

                    const SizedBox(height: 4),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: saving
                            ? null
                            : () {
                                setDialogState(() {
                                  if (selectedSlot.length ==
                                      _slotBaku.length) {
                                    selectedSlot.clear();
                                  } else {
                                    selectedSlot.addAll(
                                      List.generate(
                                        _slotBaku.length,
                                        (i) => i,
                                      ),
                                    );
                                  }
                                });
                              },
                        child: Text(
                          selectedSlot.length == _slotBaku.length
                              ? 'Batal pilih semua'
                              : 'Pilih semua slot',
                        ),
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
                          if (selectedKapsterId == null ||
                              selectedTanggal == null ||
                              selectedSlot.isEmpty) {
                            setDialogState(() {
                              errorText =
                                  'Pilih kapster, tanggal, dan minimal 1 slot jam';
                            });
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                            errorText = null;
                          });

                          final tanggalApi = _formatTanggalApi(
                            selectedTanggal!,
                          );

                          int berhasil = 0;
                          int gagal = 0;

                          // Buat satu slot jadwal per jam yang
                          // ditandai. Dijalankan berurutan (bukan
                          // Future.wait) supaya kalau salah satu
                          // gagal, sisanya tetap lanjut dicoba.
                          for (final i in selectedSlot) {
                            final slot = _slotBaku[i];

                            try {
                              await ApiService.createJadwalKapster(
                                idKapster: selectedKapsterId!,
                                tanggal: tanggalApi,
                                jamMulai: slot.$1,
                                jamSelesai: slot.$2,
                                statusSlot: 'tersedia',
                              );
                              berhasil++;
                            } catch (_) {
                              gagal++;
                            }
                          }

                          if (!dialogContext.mounted) {
                            return;
                          }

                          Navigator.pop(dialogContext);

                          if (!mounted) return;

                          await loadJadwal();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                gagal == 0
                                    ? '$berhasil slot jadwal berhasil ditambahkan'
                                    : '$berhasil slot berhasil, $gagal gagal (mungkin sudah ada)',
                              ),
                            ),
                          );
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
  }

  // ============================================================
  // EDIT JADWAL
  // ============================================================

  Future<void> editJadwal(dynamic item) async {
    final idJadwal = getId(item, ['id_jadwal', 'id']);

    if (idJadwal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID jadwal tidak ditemukan'),
        ),
      );
      return;
    }

    List<dynamic> kapsterList;

    try {
      final response = await ApiService.getKapster();
      kapsterList = extractList(response);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data kapster: $e'),
        ),
      );
      return;
    }

    int? selectedKapsterId = getId(item, ['id_kapster']);
    if (selectedKapsterId == 0) selectedKapsterId = null;

    DateTime? selectedTanggal = _parseTanggal(
      getString(item, ['tanggal'], defaultValue: ''),
    );

    TimeOfDay? selectedJamMulai = _parseJam(
      getString(item, ['jam_mulai'], defaultValue: ''),
    );

    TimeOfDay? selectedJamSelesai = _parseJam(
      getString(item, ['jam_selesai'], defaultValue: ''),
    );

    String selectedStatus = getString(
      item,
      ['status_slot'],
      defaultValue: 'tersedia',
    );

    if (selectedStatus != 'tersedia' &&
        selectedStatus != 'dipesan') {
      selectedStatus = 'tersedia';
    }

    String? errorText;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Jadwal'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedKapsterId,
                      decoration: const InputDecoration(
                        labelText: 'Kapster',
                        prefixIcon: Icon(Icons.person),
                      ),
                      hint: const Text('Pilih kapster'),
                      items: kapsterList.map((k) {
                        final id = getId(k, ['id_kapster', 'id']);

                        final nama = getString(
                          k,
                          ['nama_kapster', 'nama'],
                          defaultValue: 'Kapster #$id',
                        );

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(nama),
                        );
                      }).toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedKapsterId = value;
                              });
                            },
                    ),

                    const SizedBox(height: 12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        selectedTanggal == null
                            ? 'Pilih tanggal'
                            : _formatTanggalTampilan(
                                selectedTanggal!,
                              ),
                      ),
                      onTap: saving
                          ? null
                          : () async {
                              final now = DateTime.now();

                              final picked = await showDatePicker(
                                context: dialogBuilderContext,
                                initialDate:
                                    selectedTanggal ?? now,
                                firstDate: now.subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: now.add(
                                  const Duration(days: 365),
                                ),
                              );

                              if (picked != null) {
                                setDialogState(() {
                                  selectedTanggal = picked;
                                });
                              }
                            },
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        selectedJamMulai == null
                            ? 'Pilih jam mulai'
                            : selectedJamMulai!
                                .format(dialogBuilderContext),
                      ),
                      onTap: saving
                          ? null
                          : () async {
                              final picked = await showTimePicker(
                                context: dialogBuilderContext,
                                initialTime: selectedJamMulai ??
                                    const TimeOfDay(
                                      hour: 9,
                                      minute: 0,
                                    ),
                              );

                              if (picked != null) {
                                setDialogState(() {
                                  selectedJamMulai = picked;
                                });
                              }
                            },
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          const Icon(Icons.access_time_filled),
                      title: Text(
                        selectedJamSelesai == null
                            ? 'Pilih jam selesai'
                            : selectedJamSelesai!
                                .format(dialogBuilderContext),
                      ),
                      onTap: saving
                          ? null
                          : () async {
                              final picked = await showTimePicker(
                                context: dialogBuilderContext,
                                initialTime:
                                    selectedJamSelesai ??
                                        const TimeOfDay(
                                          hour: 10,
                                          minute: 0,
                                        ),
                              );

                              if (picked != null) {
                                setDialogState(() {
                                  selectedJamSelesai = picked;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status slot',
                        prefixIcon: Icon(Icons.event_available),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'tersedia',
                          child: Text('Tersedia'),
                        ),
                        DropdownMenuItem(
                          value: 'dipesan',
                          child: Text('Dipesan'),
                        ),
                      ],
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedStatus = value;
                                });
                              }
                            },
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 12),
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
                          if (selectedKapsterId == null ||
                              selectedTanggal == null ||
                              selectedJamMulai == null ||
                              selectedJamSelesai == null) {
                            setDialogState(() {
                              errorText =
                                  'Semua field wajib diisi';
                            });
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                            errorText = null;
                          });

                          try {
                            await ApiService.updateJadwalKapster(
                              idJadwal: idJadwal,
                              idKapster: selectedKapsterId,
                              tanggal: _formatTanggalApi(
                                selectedTanggal!,
                              ),
                              jamMulai: _formatJamApi(
                                selectedJamMulai!,
                              ),
                              jamSelesai: _formatJamApi(
                                selectedJamSelesai!,
                              ),
                              statusSlot: selectedStatus,
                            );

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            await loadJadwal();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Jadwal berhasil diubah',
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
                                  'Gagal mengubah jadwal: $e';
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
                      : const Text('Simpan Perubahan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // HAPUS JADWAL
  // ============================================================

  Future<void> hapusJadwal(dynamic item) async {
    final idJadwal = getId(item, ['id_jadwal', 'id']);

    if (idJadwal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID jadwal tidak ditemukan'),
        ),
      );
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Jadwal?'),

          content: const Text(
            'Apakah kamu yakin ingin menghapus jadwal ini?',
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
      await ApiService.deleteJadwalKapster(idJadwal);

      if (!mounted) return;

      await loadJadwal();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil dihapus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus jadwal: $e'),
        ),
      );
    }
  }

  // ============================================================
  // MENU JADWAL
  // ============================================================

  void tampilkanMenuJadwal(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Jadwal'),
                onTap: () {
                  Navigator.pop(context);
                  editJadwal(item);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text(
                  'Hapus Jadwal',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  hapusJadwal(item);
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
              onRefresh: loadJadwal,
              child: jadwal.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text('Belum ada jadwal.'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jadwal.length,
                      itemBuilder: (context, index) {
                        final item = jadwal[index];

                        // Data kapster ikut ter-nested dari
                        // relasi Eloquent with('kapster').
                        final kapsterData = item is Map &&
                                item['kapster'] is Map
                            ? item['kapster']
                            : null;

                        final namaKapster = kapsterData != null
                            ? getString(
                                kapsterData,
                                ['nama_kapster', 'nama'],
                                defaultValue: 'Kapster',
                              )
                            : 'Kapster';

                        final tanggalRaw = getString(
                          item,
                          ['tanggal'],
                        );

                        final tanggalTampilan = _parseTanggal(
                                  tanggalRaw,
                                ) !=
                                null
                            ? _formatTanggalTampilan(
                                _parseTanggal(tanggalRaw)!,
                              )
                            : tanggalRaw;

                        final jamMulai = getString(
                          item,
                          ['jam_mulai'],
                        );

                        final jamSelesai = getString(
                          item,
                          ['jam_selesai'],
                        );

                        final statusSlot = getString(
                          item,
                          ['status_slot'],
                          defaultValue: 'tersedia',
                        );

                        final statusTersedia =
                            statusSlot == 'tersedia';

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
                                Icons.calendar_month,
                                color: AppColors.ink,
                              ),
                            ),

                            title: Text(
                              namaKapster,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: 6),
                              child: Text(
                                '$tanggalTampilan • $jamMulai - $jamSelesai',
                              ),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(
                                    statusTersedia
                                        ? 'Tersedia'
                                        : 'Dipesan',
                                  ),
                                  backgroundColor: statusTersedia
                                      ? Colors.green
                                          .withValues(alpha: 0.1)
                                      : Colors.orange
                                          .withValues(alpha: 0.1),
                                  labelStyle: TextStyle(
                                    color: statusTersedia
                                        ? Colors.green[800]
                                        : Colors.orange[800],
                                    fontSize: 12,
                                  ),
                                ),

                                IconButton(
                                  icon:
                                      const Icon(Icons.more_vert),
                                  onPressed: () {
                                    tampilkanMenuJadwal(item);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_admin_jadwal',
        onPressed: tambahJadwal,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}