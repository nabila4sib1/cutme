import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'layanan_page.dart';
import 'informasi_layanan_page.dart';
import 'informasi_kapster_page.dart';
import 'booking_saya_page.dart';
import 'profil_page.dart';

class HomePage extends StatefulWidget {
  final Map pelanggan;

  const HomePage({
    super.key,
    required this.pelanggan,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  bool loadingGaleri = true;
  List<dynamic> kapsterList = [];
  List<dynamic> galeriList = [];

  @override
  void initState() {
    super.initState();
    loadGaleriDanKapster();
  }

  Future<void> loadGaleriDanKapster() async {
    try {
      final hasil = await Future.wait([
        ApiService.getKapster(),
        ApiService.getGaleri(),
      ]);

      if (!mounted) return;

      setState(() {
        kapsterList = extractList(hasil[0]);
        galeriList = extractList(hasil[1]);
        loadingGaleri = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingGaleri = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Row(
          children: [
            Icon(Icons.content_cut, color: AppColors.gold, size: 20),
            SizedBox(width: 10),
            Text('CutMe'),
          ],
        ),
      ),

      // IndexedStack menjaga state tiap tab (booking saya tidak
      // reload ulang tiap pindah tab).
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _berandaTab(context),
          BookingSayaPage(pelanggan: widget.pelanggan),
          ProfilPage(pelanggan: widget.pelanggan),
        ],
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================

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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB: BERANDA
  // ============================================================

  Widget _berandaTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // =========================
          // GREETING
          // =========================

          Text(
            'Halo, ${getString(widget.pelanggan, [
              'nama',
              'nama_pelanggan',
            ], defaultValue: 'Pelanggan')}',
            style: Theme.of(context).textTheme.headlineLarge,
          ),

          const SizedBox(height: 6),

          const Text(
            'Mau potong rambut hari ini?',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // BOOKING CARD
          // =========================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.ink, AppColors.inkSoft],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 1.2),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: AppColors.gold,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Booking Sekarang',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Pilih layanan dan kapster favoritmu.',
                  style: TextStyle(
                    color: Color(0xFFBFBFC6),
                    fontSize: 13.5,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LayananPage(
                            pelanggan: widget.pelanggan,
                          ),
                        ),
                      );
                    },
                    child: const Text('Mulai Booking'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // =========================
          // MENU (informasi saja, bukan alur booking)
          // =========================

          Text(
            'Menu',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child: _MenuCard(
                  icon: Icons.content_cut,
                  title: 'Informasi Layanan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const InformasiLayananPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: _MenuCard(
                  icon: Icons.people_outline,
                  title: 'Informasi Kapster',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const InformasiKapsterPage(),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),

          const SizedBox(height: 30),

          // =========================
          // KAPSTER KAMI
          // =========================

          if (!loadingGaleri && kapsterList.isNotEmpty) ...[
            Text(
              'Kapster Kami',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kapsterList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final k = kapsterList[index];

                  final nama = getString(
                    k,
                    ['nama_kapster', 'nama'],
                    defaultValue: 'Kapster',
                  );

                  final fotoUrl = getString(
                    k,
                    ['foto_url'],
                    defaultValue: '',
                  );

                  return SizedBox(
                    width: 75,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.goldSoft,
                          backgroundImage: fotoUrl.isNotEmpty
                              ? NetworkImage(fotoUrl)
                              : null,
                          child: fotoUrl.isEmpty
                              ? const Icon(Icons.person, color: AppColors.ink)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],

          // =========================
          // HASIL KARYA KAMI
          // =========================

          if (!loadingGaleri && galeriList.isNotEmpty) ...[
            Text(
              'Hasil Karya Kami',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: galeriList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final g = galeriList[index];

                  final judul = getString(
                    g,
                    ['judul'],
                    defaultValue: 'Hasil Kerja',
                  );

                  final fotoUrl = getString(
                    g,
                    ['foto_url'],
                    defaultValue: '',
                  );

                  final kapsterData =
                      g is Map && g['kapster'] is Map ? g['kapster'] : null;

                  final namaKapster = kapsterData != null
                      ? getString(
                          kapsterData,
                          ['nama_kapster', 'nama'],
                          defaultValue: '',
                        )
                      : '';

                  return SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: fotoUrl.isNotEmpty
                              ? Image.network(
                                  fotoUrl,
                                  width: 140,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 140,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                )
                              : Container(
                                  width: 140,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_outlined),
                                ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (namaKapster.isNotEmpty)
                          Text(
                            'oleh $namaKapster',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],

          // =========================
          // INFO
          // =========================

          Text(
            'Informasi',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Row(
              children: [

                CircleAvatar(
                  backgroundColor: AppColors.ink,
                  child: Icon(
                    Icons.store,
                    color: AppColors.gold,
                  ),
                ),

                SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CutMe Barbershop',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Pesan jadwal potong rambut dengan mudah.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// MENU CARD
// ==================================================

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.ink,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}