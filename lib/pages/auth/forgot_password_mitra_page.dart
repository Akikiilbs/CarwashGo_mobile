import 'package:flutter/material.dart';

class ForgotPasswordMitraPage extends StatefulWidget {
  const ForgotPasswordMitraPage({super.key});

  @override
  State<ForgotPasswordMitraPage> createState() => _ForgotPasswordMitraPageState();
}

class _ForgotPasswordMitraPageState extends State<ForgotPasswordMitraPage> {
  final _email = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blueAccent),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),

              const Text("Lupa Password Mitra?",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent)),

              const SizedBox(height: 10),
              const Text(
                "Masukkan email untuk menerima kode verifikasi.",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 30),

              Form(
                key: _key,
                child: TextFormField(
                  controller: _email,
                  validator: (v) =>
                      v!.contains("@") ? null : "Email tidak valid",
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Kirim",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      Navigator.pushNamed(
                        context,
                        '/verify-email-mitra',
                        arguments: _email.text,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
