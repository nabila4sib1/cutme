import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import 'admin_page.dart';

// ============================================================
// ADMIN LOGIN PAGE
// ============================================================
//
// Satu akun tetap (username+password dari .env server), tidak
// terkait tabel database manapun.

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool sembunyikanPassword = true;
  String? errorText;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorText = 'Username dan password wajib diisi';
      });
      return;
    }

    setState(() {
      loading = true;
      errorText = null;
    });

    try {
      await ApiService.loginAdmin(
        username: username,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminPage(),
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
        title: const Text('Login Admin / Kasir'),
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
                  Icons.admin_panel_settings,
                  size: 56,
                  color: AppColors.ink,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Masuk sebagai Admin / Kasir',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: usernameController,
                  enabled: !loading,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
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