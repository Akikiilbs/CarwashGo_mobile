import 'package:flutter/material.dart';
import 'login_mitra_page.dart';

class ResetPasswordMitraPage extends StatefulWidget {
  final String email;
  const ResetPasswordMitraPage({super.key, required this.email});

  @override
  State<ResetPasswordMitraPage> createState() => _ResetPasswordMitraPageState();
}

class _ResetPasswordMitraPageState extends State<ResetPasswordMitraPage> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _key = GlobalKey<FormState>();

  bool hide1 = true;
  bool hide2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: Column(
            children: [
              TextFormField(
                controller: _pass,
                obscureText: hide1,
                decoration: InputDecoration(
                  labelText: "Password Baru",
                  suffixIcon: IconButton(
                    icon: Icon(hide1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => hide1 = !hide1),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v!.length < 6 ? "Minimal 6 karakter" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _confirm,
                obscureText: hide2,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password",
                  suffixIcon: IconButton(
                    icon: Icon(hide2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => hide2 = !hide2),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) =>
                    v != _pass.text ? "Password tidak sama" : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginMitraPage()),
                        (_) => false,
                      );
                    }
                  },
                  child: const Text("Reset Password",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
