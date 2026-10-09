import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'pages/pelanggan_login_page.dart';
import 'pages/kapster_login_page.dart';
import 'admin/admin_login_page.dart';

void main() {
  runApp(const CutMeApp());
}

// ============================================================
// APP
// ============================================================

class CutMeApp extends StatelessWidget {
  const CutMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CutMe',
      theme: AppTheme.light(),
      home: const RolePage(),
    );
  }
}

// ============================================================
// ROLE PAGE
// ============================================================

class RolePage extends StatelessWidget {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 40,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ================================
                // WORDMARK
                // ================================
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold,
                      width: 1.4,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.content_cut,
                      size: 32,
                      color: AppColors.gold,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'CutMe',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Colors.white),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Potong rambut, dipesan dengan tenang.',
                  style: TextStyle(
                    color: Color(0xFFB9B9C0),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 56),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MASUK SEBAGAI',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _RoleCard(
                  icon: Icons.person_outline,
                  title: 'Pelanggan',
                  subtitle: 'Booking layanan potong rambut',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PelangganLoginPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                _RoleCard(
                  icon: Icons.content_cut,
                  title: 'Kapster',
                  subtitle: 'Lihat jadwal dan kelola booking',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KapsterLoginPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                _RoleCard(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin / Kasir',
                  subtitle: 'Kelola layanan dan data toko',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROLE CARD
// ============================================================

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1D1D24),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9A9AA2),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}