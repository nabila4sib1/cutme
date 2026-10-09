import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'home_page.dart';

// ============================================================
// PELANGGAN REGISTER PAGE
// ============================================================

class PelangganRegisterPage extends StatefulWidget {
  const PelangganRegisterPage({super.key});

  @override
  State<PelangganRegisterPage> createState() =>
      _PelangganRegisterPageState();
}

class _PelangganRegisterPageState
    extends State<PelangganRegisterPage> {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final noHpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool sembunyikanPassword = true;
  String? errorText;

  @override
  void dispose() {
    namaController.dispose();
    noHpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> daftar() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
      errorText = null;
    });

    try {
      final response = await ApiService.register(
        nama: namaController.text.trim(),
        noHp: noHpController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      final data = extractMap(response);

      if (data.isEmpty) {
        setState(() {
          loading = false;
          errorText = 'Data pendaftaran tidak valid dari server';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelanggan'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: namaController,
                    enabled: !loading,
                    decoration: const InputDecoration(
                      labelText: 'Nama lengkap',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: noHpController,
                    enabled: !loading,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'No. HP',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'No. HP wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: emailController,
                    enabled: !loading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!value.contains('@')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: passwordController,
                    obscureText: sembunyikanPassword,
                    enabled: !loading,
                    decoration: InputDecoration(
                      labelText: 'Password (min. 6 karakter)',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
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
                    onPressed: loading ? null : daftar,
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}