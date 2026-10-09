import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

// ============================================================
// WARNA TEMA CUTME
// ============================================================

const Color ink = Color(0xFF15151A);
const Color gold = Color(0xFFC6952C);
const Color burgundy = Color(0xFF7A2E2E);
const Color warmWhite = Color(0xFFF5F3EE);
const Color softGray = Color(0xFF777168);

// ============================================================
// PEMBAYARAN PAGE
// ============================================================

class PembayaranPage extends StatefulWidget {
  final int idBooking;
  final double totalBiaya;

  const PembayaranPage({
    super.key,
    required this.idBooking,
    required this.totalBiaya,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

// Tampilan yang sedang aktif.
enum _TampilanBayar {
  pilihMetode,
  transfer,
  qris,
}

// ============================================================
// DATA BANK
// ============================================================

class _BankTransfer {
  final String nama;
  final String kodeVa;

  const _BankTransfer(
    this.nama,
    this.kodeVa,
  );
}

const List<_BankTransfer> _daftarBank = [
  _BankTransfer('BCA', '3910'),
  _BankTransfer('Mandiri', '8960'),
  _BankTransfer('BNI', '9880'),
  _BankTransfer('BRI', '2610'),
];

// ============================================================
// STATE
// ============================================================

class _PembayaranPageState extends State<PembayaranPage> {
  bool paying = false;

  _TampilanBayar tampilan =
      _TampilanBayar.pilihMetode;

  _BankTransfer? bankDipilih;

  // ==========================================================
  // PROSES PEMBAYARAN
  // ==========================================================

  Future<void> bayar(String metode) async {
    setState(() {
      paying = true;
    });

    try {
      await ApiService.createPembayaran(
        idBooking: widget.idBooking,
        metode: metode,
        jumlahBayar: widget.totalBiaya,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SelesaiPage(
            idBooking: widget.idBooking,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        paying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: burgundy,
          content: Text(
            'Pembayaran gagal: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // NOMOR VIRTUAL ACCOUNT
  // ==========================================================

  String _nomorVa(_BankTransfer bank) {
    return '${bank.kodeVa}${widget.idBooking.toString().padLeft(8, '0')}';
  }

  // ==========================================================
  // SALIN VA
  // ==========================================================

  void _salinVa(_BankTransfer bank) {
    Clipboard.setData(
      ClipboardData(
        text: _nomorVa(bank),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: ink,
        content: Text(
          'Nomor VA disalin',
          style: TextStyle(
            color: warmWhite,
          ),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmWhite,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: ink,
        foregroundColor: warmWhite,
        elevation: 0,

        leading: tampilan ==
                _TampilanBayar.pilihMetode
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: paying
                    ? null
                    : () {
                        setState(() {
                          tampilan =
                              _TampilanBayar
                                  .pilihMetode;

                          bankDipilih = null;
                        });
                      },
              ),

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),

              decoration: BoxDecoration(
                color: gold,
                borderRadius:
                    BorderRadius.circular(8),
              ),

              child: const Icon(
                Icons.payment,
                color: ink,
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'Pembayaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: switch (tampilan) {
          _TampilanBayar.pilihMetode =>
            _viewPilihMetode(),

          _TampilanBayar.transfer =>
            _viewTransfer(),

          _TampilanBayar.qris =>
            _viewQris(),
        },
      ),
    );
  }

  // ============================================================
  // VIEW: PILIH METODE
  // ============================================================

  Widget _viewPilihMetode() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        // ======================================================
        // HEADER
        // ======================================================

        const Text(
          'Selesaikan Pembayaran',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Pilih metode pembayaran yang kamu inginkan.',
          style: TextStyle(
            color: softGray,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // TOTAL
        // ======================================================

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: ink,
            borderRadius:
                BorderRadius.circular(18),
          ),

          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration: BoxDecoration(
                  color: gold.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.receipt_long,
                  color: gold,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PEMBAYARAN',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Booking CutMe',
                      style: TextStyle(
                        color: warmWhite,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                'Rp ${widget.totalBiaya.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: gold,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Tersedia beberapa pilihan pembayaran.',
          style: TextStyle(
            color: softGray,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 15),

        // ======================================================
        // LOADING
        // ======================================================

        if (paying)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: gold,
                  ),

                  SizedBox(height: 14),

                  Text(
                    'Memproses pembayaran...',
                    style: TextStyle(
                      color: softGray,
                    ),
                  ),
                ],
              ),
            ),
          )

        // ======================================================
        // METODE PEMBAYARAN
        // ======================================================

        else
          Expanded(
            child: ListView(
              children: [
                _paymentButton(
                  icon: Icons.payments_outlined,
                  title: 'Tunai',
                  subtitle:
                      'Bayar langsung di tempat',
                  onTap: () => bayar('tunai'),
                ),

                _paymentButton(
                  icon:
                      Icons.account_balance,
                  title: 'Transfer Bank',
                  subtitle:
                      'BCA, Mandiri, BNI, BRI',
                  onTap: () {
                    setState(() {
                      tampilan =
                          _TampilanBayar
                              .transfer;
                    });
                  },
                ),

                _paymentButton(
                  icon: Icons.qr_code_2,
                  title: 'QRIS',
                  subtitle:
                      'Scan menggunakan e-wallet atau m-banking',
                  onTap: () {
                    setState(() {
                      tampilan =
                          _TampilanBayar.qris;
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // PAYMENT BUTTON
  // ============================================================

  Widget _paymentButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              Colors.black.withValues(alpha: 0.06),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius:
              BorderRadius.circular(16),
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: gold.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Icon(
                    icon,
                    color: ink,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: softGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 34,
                  height: 34,

                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius:
                        BorderRadius.circular(9),
                  ),

                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: gold,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VIEW: TRANSFER BANK
  // ============================================================

  Widget _viewTransfer() {
    if (bankDipilih == null) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Pilih Bank',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Pilih bank untuk mendapatkan nomor Virtual Account.',
            style: TextStyle(
              color: softGray,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                ..._daftarBank.map(
                  (bank) {
                    return Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),

                        border: Border.all(
                          color: Colors.black
                              .withValues(
                            alpha: 0.06,
                          ),
                        ),
                      ),

                      child: Material(
                        color:
                            Colors.transparent,

                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),

                          onTap: () {
                            setState(() {
                              bankDipilih =
                                  bank;
                            });
                          },

                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(16),

                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        ink,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                  ),

                                  child:
                                      const Icon(
                                    Icons
                                        .account_balance,
                                    color:
                                        gold,
                                    size: 25,
                                  ),
                                ),

                                const SizedBox(
                                  width: 14,
                                ),

                                Expanded(
                                  child: Text(
                                    'Bank ${bank.nama}',
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color: ink,
                                    ),
                                  ),
                                ),

                                const Icon(
                                  Icons
                                      .arrow_forward_ios,
                                  color:
                                      softGray,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    final bank = bankDipilih!;
    final nomorVa = _nomorVa(bank);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Transfer Bank',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Bank ${bank.nama}',
          style: const TextStyle(
            color: softGray,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // VA CARD
        // ======================================================

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: ink,
            borderRadius:
                BorderRadius.circular(18),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'NOMOR VIRTUAL ACCOUNT',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      nomorVa,
                      style: const TextStyle(
                        color: warmWhite,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Salin nomor VA',

                    icon: const Icon(
                      Icons.copy,
                      color: gold,
                    ),

                    onPressed: () =>
                        _salinVa(bank),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                height: 1,
                color: Colors.white12,
              ),

              const SizedBox(height: 15),

              const Text(
                'TOTAL TRANSFER',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Rp ${widget.totalBiaya.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // PETUNJUK
        // ======================================================

        Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: gold.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: gold.withValues(
                alpha: 0.25,
              ),
            ),
          ),

          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Icon(
                Icons.info_outline,
                color: burgundy,
                size: 20,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Transfer sesuai nominal di atas ke '
                  'nomor Virtual Account, lalu tekan '
                  'tombol setelah transfer berhasil.',
                  style: TextStyle(
                    color: ink,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // ======================================================
        // BUTTON
        // ======================================================

        _paymentActionButton(
          text: 'Saya Sudah Transfer',
          icon: Icons.check_circle_outline,
          onPressed: paying
              ? null
              : () => bayar('transfer'),
        ),
      ],
    );
  }

  // ============================================================
  // VIEW: QRIS
  // ============================================================

  Widget _viewQris() {
    final dataQr =
        'CUTME|BOOKING:${widget.idBooking}|TOTAL:${widget.totalBiaya.toStringAsFixed(0)}';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Scan QRIS',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Scan kode QR menggunakan e-wallet atau m-banking.',
          style: TextStyle(
            color: softGray,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // QR CARD
        // ======================================================

        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: gold.withValues(
                      alpha: 0.35,
                    ),
                    width: 1.5,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.07),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(8),

                      decoration:
                          BoxDecoration(
                        color: warmWhite,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: QrImageView(
                        data: dataQr,
                        version:
                            QrVersions.auto,
                        size: 210,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'TOTAL PEMBAYARAN',
                      style: TextStyle(
                        color: softGray,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Rp ${widget.totalBiaya.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: burgundy,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Booking #${widget.idBooking}',
                      style: const TextStyle(
                        color: softGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // BUTTON
        // ======================================================

        _paymentActionButton(
          text: 'Saya Sudah Bayar',
          icon: Icons.check_circle_outline,
          onPressed: paying
              ? null
              : () => bayar('qris'),
        ),
      ],
    );
  }

  // ============================================================
  // BUTTON AKSI PEMBAYARAN
  // ============================================================

  Widget _paymentActionButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: paying
            ? const SizedBox(
                width: 20,
                height: 20,

                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: ink,
                ),
              )
            : Icon(icon),

        label: Text(
          paying
              ? 'Memproses Pembayaran...'
              : text,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: ink,
          disabledBackgroundColor:
              gold.withValues(alpha: 0.55),
          disabledForegroundColor:
              ink.withValues(alpha: 0.7),
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SELESAI PAGE
// ============================================================

class SelesaiPage extends StatelessWidget {
  final int idBooking;

  const SelesaiPage({
    super.key,
    required this.idBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmWhite,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                // ==================================================
                // ICON SUKSES
                // ==================================================

                Container(
                  width: 105,
                  height: 105,

                  decoration:
                      const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ink,
                  ),

                  child: Center(
                    child: Container(
                      width: 75,
                      height: 75,

                      decoration:
                          BoxDecoration(
                        shape: BoxShape.circle,
                        color: gold,
                      ),

                      child: const Icon(
                        Icons.check,
                        color: ink,
                        size: 48,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // JUDUL
                // ==================================================

                const Text(
                  'Booking Selesai!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Booking #$idBooking berhasil diproses.',
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: softGray,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Terima kasih telah menggunakan CutMe.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: softGray,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // BUTTON KEMBALI
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Kembali ke HomePage pelanggan.
                      Navigator.of(context)
                          .popUntil(
                        (route) =>
                            route.settings.name ==
                            '/pelanggan-home',
                      );
                    },

                    icon: const Icon(
                      Icons.home_outlined,
                    ),

                    label: const Text(
                      'Kembali ke Menu',
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: ink,
                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      textStyle:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}