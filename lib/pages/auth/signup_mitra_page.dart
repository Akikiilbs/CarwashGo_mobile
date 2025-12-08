// import 'package:flutter/material.dart';

// class SignupMitraPage extends StatefulWidget {
//   const SignupMitraPage({super.key});

//   @override
//   State<SignupMitraPage> createState() => _SignupMitraPageState();
// }

// class _SignupMitraPageState extends State<SignupMitraPage> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isObscure = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _register() {
//     if (_nameController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _phoneController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Harap lengkapi semua kolom")),
//       );
//       return;
//     }

//     // TODO: implement actual registration backend
//     // For now simulate success:
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Akun dibuat"),
//         content: const Text("Akun mitra berhasil dibuat. Silakan login."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           )
//         ],
//       ),
//     ).then((_) {
//       // Setelah menutup dialog, menuju ke login (replacement agar tidak menumpuk)
//       Navigator.pushReplacementNamed(context, '/login-mitra');
//       // Optional: show a SnackBar at login page stating success (you can pass args if needed)
//     });
//   }

//   void _goBackToLogin() {
//     Navigator.pushReplacementNamed(context, '/login-mitra');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Daftar Mitra"),
//         backgroundColor: Colors.blueAccent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new),
//           onPressed: _goBackToLogin,
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: "Nama Usaha / Pemilik",
//                   prefixIcon: const Icon(Icons.person),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   prefixIcon: const Icon(Icons.email_outlined),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: "Nomor HP",
//                   prefixIcon: const Icon(Icons.phone),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: _isObscure,
//                 decoration: InputDecoration(
//                   labelText: "Kata Sandi",
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isObscure ? Icons.visibility_off : Icons.visibility,
//                     ),
//                     onPressed: () => setState(() => _isObscure = !_isObscure),
//                   ),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _register,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text(
//                     "DAFTAR",
//                     style: TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextButton(
//                 onPressed: _goBackToLogin,
//                 child: const Text("Sudah punya akun? Login"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:carwashgo/features/auth/data/auth_api.dart';
import 'package:carwashgo/features/auth/models/auth_response.dart';

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

  bool _isLoading = false;
  String? _errorMessage;

  final _authApi = AuthApi();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goBackToLogin() {
    Navigator.pushReplacementNamed(context, '/login-mitra');
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua kolom")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.registerPartner(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }

    if (!mounted) return;

    if (res.status == 'success') {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registrasi berhasil"),
          content: const Text(
            "Registrasi berhasil, silahkan tunggu akun disetujui oleh admin.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );

      Navigator.pushReplacementNamed(context, '/login-mitra');
    } else {
      String msg = res.message;

      if (res.errors != null && res.errors!.isNotEmpty) {
        final firstKey = res.errors!.keys.first;
        final firstVal = res.errors![firstKey];
        if (firstVal is List && firstVal.isNotEmpty) {
          msg = firstVal.first.toString();
        } else if (firstVal is String) {
          msg = firstVal;
        }
      }

      setState(() {
        _errorMessage = msg;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
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
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Usaha / Pemilik",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Nomor HP",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
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
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "DAFTAR",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
