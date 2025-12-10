// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/user_provider.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();

//   bool _isObscure = true;
//   bool _isObscureConfirm = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (!_formKey.currentState!.validate()) return;

//     // SIMPAN DATA USER
//     Provider.of<UserProvider>(context, listen: false).setUser(
//       name: _nameController.text.trim(),
//       email: _emailController.text.trim(),
//       phone: _phoneController.text.trim(),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Akun berhasil dibuat! Silakan login.")),
//     );

//     // ARAHKAN KE LOGIN
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       '/login',
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         title: const Text(
//           "Daftar Akun",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Form(
//             key: _formKey,

//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

//                 const SizedBox(height: 10),
//                 const Center(
//                   child: Text(
//                     "Buat Akun Baru",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueAccent,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 // =======================
//                 // NAMA LENGKAP
//                 // =======================
//                 const Text("Nama Lengkap"),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) =>
//                       value == null || value.isEmpty ? "Masukkan nama lengkap" : null,
//                 ),

//                 const SizedBox(height: 20),

//                 // =======================
//                 // NOMOR TELEPON
//                 // =======================
//                 const Text("Nomor Telepon"),
//                 TextFormField(
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                   decoration: const InputDecoration(
//                     prefixIcon: Icon(Icons.phone_iphone),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Masukkan nomor telepon";
//                     }
//                     if (value.length < 9) {
//                       return "Nomor tidak valid";
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // =======================
//                 // EMAIL
//                 // =======================
//                 const Text("Alamat Email"),
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     prefixIcon: Icon(Icons.email_outlined),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Masukkan email";
//                     }
//                     if (!value.contains("@")) {
//                       return "Format email tidak valid";
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // =======================
//                 // PASSWORD
//                 // =======================
//                 const Text("Kata Sandi"),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _isObscure,
//                   decoration: InputDecoration(
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isObscure ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isObscure = !_isObscure;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.length < 6) {
//                       return "Minimal 6 karakter";
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // =======================
//                 // KONFIRMASI PASSWORD
//                 // =======================
//                 const Text("Konfirmasi Kata Sandi"),
//                 TextFormField(
//                   controller: _confirmController,
//                   obscureText: _isObscureConfirm,
//                   decoration: InputDecoration(
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isObscureConfirm ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isObscureConfirm = !_isObscureConfirm;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value != _passwordController.text) {
//                       return "Password tidak sama";
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 30),

//                 // =======================
//                 // TOMBOL DAFTAR
//                 // =======================
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: _submit,
//                     child: const Text(
//                       "Daftar",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // LINK LOGIN
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Sudah punya akun? "),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamedAndRemoveUntil(
//                           context,
//                           '/login',
//                           (route) => false,
//                         );
//                       },
//                       child: const Text(
//                         "Masuk",
//                         style: TextStyle(
//                           color: Colors.blueAccent,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import 'package:carwashgo/features/auth/data/auth_api.dart';
import 'package:carwashgo/features/auth/models/auth_response.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isObscure = true;
  bool _isObscureConfirm = true;

  bool _isLoading = false;          // <-- status loading
  String? _errorMessage;            // <-- pesan error

  final _authApi = AuthApi();       // <-- pakai AuthApi.register()

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final passwordConfirmation = _confirmController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }

    if (!mounted) return;

    if (res.status == 'success') {
      // Simpan ke UserProvider (opsional, biar data user tersimpan di state)
      final userProv = Provider.of<UserProvider>(context, listen: false);
      if (res.user != null) {
        userProv.setUser(
          name: res.user!.name,
          email: res.user!.email,
          phone: res.user!.phone,
        );
      } else {
        userProv.setUser(
          name: name,
          email: email,
          phone: phone,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty
                ? res.message
                : 'Akun berhasil dibuat! Silakan login.',
          ),
        ),
      );

      // Setelah register → kembali ke halaman login
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } else {
      // Ambil pesan error validasi kalau ada
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
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Daftar Akun",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Buat Akun Baru",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 20),

                // =======================
                // NAMA LENGKAP
                // =======================
                const Text("Nama Lengkap"),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Masukkan nama lengkap" : null,
                ),

                const SizedBox(height: 20),

                // =======================
                // NOMOR TELEPON
                // =======================
                const Text("Nomor Telepon"),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_iphone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukkan nomor telepon";
                    }
                    if (value.length < 9) {
                      return "Nomor tidak valid";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =======================
                // EMAIL
                // =======================
                const Text("Alamat Email"),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukkan email";
                    }
                    if (!value.contains("@")) {
                      return "Format email tidak valid";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =======================
                // PASSWORD
                // =======================
                const Text("Kata Sandi"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Minimal 6 karakter";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =======================
                // KONFIRMASI PASSWORD
                // =======================
                const Text("Konfirmasi Kata Sandi"),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _isObscureConfirm,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureConfirm ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureConfirm = !_isObscureConfirm;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return "Password tidak sama";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // =======================
                // TOMBOL DAFTAR
                // =======================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Daftar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // LINK LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

