import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mitra_provider.dart';

class SignupMitraPage extends StatefulWidget {
  const SignupMitraPage({super.key});

  @override
  State<SignupMitraPage> createState() => _SignupMitraPageState();
}

class _SignupMitraPageState extends State<SignupMitraPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua kolom")),
      );
      return;
    }

    // ✅ SIMPAN DATA DASAR KE MITRA PROVIDER (TANPA DESKRIPSI)
    context.read<MitraProvider>().setMitra(
      nama: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      alamat: "",
      jamOperasional: "",
      deskripsi: "",
      hariOperasional: "",
      harga: "", // ✅ FIX ERROR WAJIB ADA
    );


    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Akun Berhasil Dibuat"),
        content: const Text("Silakan login untuk melengkapi profil mitra."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    ).then((_) {
      Navigator.pushReplacementNamed(context, '/login-mitra');
    });
  }

  void _goBackToLogin() {
    Navigator.pushReplacementNamed(context, '/login-mitra');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Mitra"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: _goBackToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ================= NAMA USAHA / PEMILIK =================
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Usaha / Pemilik",
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ================= EMAIL =================
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // ================= NOMOR HP =================
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Nomor HP",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 12),

              // ================= PASSWORD =================
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Kata Sandi",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= BUTTON DAFTAR =================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "DAFTAR",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _goBackToLogin,
                child: const Text("Sudah punya akun? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
