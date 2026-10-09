import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../utils/helpers.dart';

// ============================================================
// PROFIL PAGE (TAB CONTENT)
// ============================================================
//
// Dipakai sebagai isi tab "Profil" di HomePage (bukan halaman
// terpisah), jadi TIDAK punya Scaffold/AppBar sendiri.

class ProfilPage extends StatelessWidget {
  final Map pelanggan;

  const ProfilPage({
    super.key,
    required this.pelanggan,
  });

  void _logout(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final nama = getString(
      pelanggan,
      ['nama', 'nama_pelanggan'],
      defaultValue: 'Pelanggan',
    );

    final email = getString(
      pelanggan,
      ['email'],
      defaultValue: '-',
    );

    final noHp = getString(
      pelanggan,
      ['no_hp'],
      defaultValue: '-',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('No. HP'),
                  subtitle: Text(noHp),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
        ],
      ),
    );
  }
}