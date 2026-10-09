import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// ============================================================
// PILIH FOTO (helper dipakai bareng)
// ============================================================
//
// Nampilin bottom sheet: Kamera / Galeri / File & Dokumen.
// Opsi "File & Dokumen" penting buat emulator Android yang
// galerinya kosong - lewat ini bisa browse ke folder lain
// (misalnya Downloads, tempat file dari laptop biasa nyangkut
// kalau di-drag ke jendela emulator).
//
// Return: path foto yang dipilih (String), atau null kalau
// dibatalkan.

Future<String?> pilihFoto(BuildContext context) async {
  final sumber = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('File & Dokumen'),
              subtitle: const Text(
                'Browse ke folder lain, mis. Downloads',
              ),
              onTap: () => Navigator.pop(ctx, 'files'),
            ),
          ],
        ),
      );
    },
  );

  if (sumber == null) return null;

  if (sumber == 'files') {
    final hasil = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    return hasil?.files.single.path;
  }

  final picked = await ImagePicker().pickImage(
    source: sumber == 'camera' ? ImageSource.camera : ImageSource.gallery,
    maxWidth: 1000,
    imageQuality: 85,
  );

  return picked?.path;
}