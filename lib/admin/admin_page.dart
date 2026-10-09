import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'admin_layanan_page.dart';
import 'admin_kapster_page.dart';
import 'admin_jadwal_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Hanya izinkan tombol back benar-benar keluar dari
      // AdminPage kalau sedang di tab Dashboard (index 0).
      // Kalau sedang di tab lain (misalnya setelah tap card
      // "Kapster"/"Layanan" di dashboard), back akan kembali
      // ke tab Dashboard dulu, bukan langsung keluar.
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        setState(() {
          selectedIndex = 0;
        });
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'CutMe - Admin',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
          ),
        ],
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: [
          const AdminDashboard(),
          const AdminLayananPage(),
          const AdminKapsterPage(),
          const AdminJadwalPage(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(Icons.content_cut_outlined),
            selectedIcon: Icon(Icons.content_cut),
            label: 'Layanan',
          ),

          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Kapster',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
        ],
      ),
      ),
    );
  }
}