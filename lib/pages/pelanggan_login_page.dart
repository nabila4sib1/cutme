import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'home_page.dart';
import 'pelanggan_register_page.dart';

// ============================================================
// PELANGGAN LOGIN PAGE
// ============================================================

class PelangganLoginPage extends StatefulWidget {
  const PelangganLoginPage({super.key});

  @override
  State<PelangganLoginPage> createState() =>
      _PelangganLoginPageState();
}

class _PelangganLoginPageState extends State<PelangganLoginPage> {
  final identitasController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool sembunyikanPassword = true;
  String? errorText;

  @override
  void dispose() {
    identitasController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final identitas = identitasController.text.trim();
    final password = passwordController.text;

    if (identitas.isEmpty || password.isEmpty) {
      setState(() {
        errorText = 'Email/No. HP dan password wajib diisi';
      });
      return;
    }

    setState(() {
      loading = true;
      errorText = null;
    });

    try {
      final response = await ApiService.loginPelanggan(
        identitas: identitas,
        password: password,
      );

      if (!mounted) return;

      final data = extractMap(response);

      if (data.isEmpty) {
        setState(() {
          loading = false;
          errorText = 'Data login tidak valid dari server';
        });
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(pelanggan: data),
          settings: const RouteSettings(name: '/pelanggan-home'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void kePendaftaran() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PelangganRegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Pelanggan'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person,
                  size: 56,
                  color: AppColors.ink,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Masuk sebagai Pelanggan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: identitasController,
                  enabled: !loading,
                  decoration: const InputDecoration(
                    labelText: 'Email atau No. HP',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: passwordController,
                  obscureText: sembunyikanPassword,
                  enabled: !loading,
                  onSubmitted: (_) => login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        sembunyikanPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          sembunyikanPassword =
                              !sembunyikanPassword;
                        });
                      },
                    ),
                  ),
                ),

                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const SizedBox(height: 20),

                FilledButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Masuk'),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: loading ? null : kePendaftaran,
                  child: const Text('Belum punya akun? Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}