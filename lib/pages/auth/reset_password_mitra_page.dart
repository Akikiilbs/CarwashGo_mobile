// lib/pages/auth/reset_password_mitra_page.dart

import 'package:flutter/material.dart';

class ResetPasswordMitraPage extends StatefulWidget {
  final String email;

  const ResetPasswordMitraPage({super.key, required this.email});

  @override
  State<ResetPasswordMitraPage> createState() => _ResetPasswordMitraPageState();
}

class _ResetPasswordMitraPageState extends State<ResetPasswordMitraPage> {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Reset Password Mitra"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Text(
              "Reset password untuk email:",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),

            Text(
              widget.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            const Text(
              "Password Baru",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _passController,
              obscureText: _obscure1,
              decoration: InputDecoration(
                hintText: "Masukkan password baru",
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Konfirmasi Password",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _confirmController,
              obscureText: _obscure2,
              decoration: InputDecoration(
                hintText: "Ulangi password baru",
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_passController.text.isEmpty ||
                      _confirmController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Semua kolom wajib diisi")),
                    );
                    return;
                  }

                  if (_passController.text != _confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Password tidak sama")),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Password berhasil direset")),
                  );

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-mitra',
                    (route) => false,
                  );
                },
                child: const Text(
                  "RESET PASSWORD",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
