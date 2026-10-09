import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import 'kapster_jadwal_page.dart';

// ============================================================
// KAPSTER LOGIN PAGE
// ============================================================
//
// Login kapster pakai No. HP + password. Kalau berhasil, pindah
// ke KapsterJadwalPage dengan membawa data kapster yang login.

class KapsterLoginPage extends StatefulWidget {
  const KapsterLoginPage({super.key});

  @override
  State<KapsterLoginPage> createState() =>
      _KapsterLoginPageState();
}

class _KapsterLoginPageState extends State<KapsterLoginPage> {
  final noHpController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool sembunyikanPassword = true;
  String? errorText;

  @override
  void dispose() {
    noHpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final noHp = noHpController.text.trim();
    final password = passwordController.text;

    if (noHp.isEmpty || password.isEmpty) {
      setState(() {
        errorText = 'No. HP dan password wajib diisi';
      });
      return;
    }

    setState(() {
      loading = true;
      errorText = null;
    });

    try {
      final response = await ApiService.loginKapster(
        noHp: noHp,
        password: password,
      );

      if (!mounted) return;

      final data = response is Map ? response['data'] : null;

      if (data is! Map) {
        setState(() {
          loading = false;
          errorText = 'Data login tidak valid dari server';
        });
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => KapsterJadwalPage(kapster: data),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Kapster'),
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
                  Icons.content_cut,
                  size: 56,
                  color: AppColors.ink,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Masuk sebagai Kapster',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  enabled: !loading,
                  decoration: const InputDecoration(
                    labelText: 'No. HP',
                    prefixIcon: Icon(Icons.phone),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}