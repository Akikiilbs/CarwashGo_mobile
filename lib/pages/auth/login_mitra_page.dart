// import 'package:flutter/material.dart';

// class LoginMitraPage extends StatefulWidget {
//   const LoginMitraPage({super.key});

//   @override
//   State<LoginMitraPage> createState() => _LoginMitraPageState();
// }

// class _LoginMitraPageState extends State<LoginMitraPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isObscure = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _goToRole() {
//     // replace with role so back won't return here
//     Navigator.pushReplacementNamed(context, '/role');
//   }

//   void _login() {
//     if (_emailController.text.isNotEmpty &&
//         _passwordController.text.isNotEmpty) {
//       // TODO: real auth
//       Navigator.pushReplacementNamed(context, '/mitra-home');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Harap isi semua kolom")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // BACK BUTTON → clear and go back to role (replacement)
//               IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new,
//                     color: Colors.blueAccent),
//                 onPressed: _goToRole,
//               ),

//               const SizedBox(height: 10),

//               // ICON MITRA
//               Center(
//                 child: Container(
//                   width: 70,
//                   height: 70,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE3F2FD),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.directions_car_filled_rounded,
//                     size: 40,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // TITLE
//               const Center(
//                 child: Text(
//                   "Login Mitra",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 6),

//               const Center(
//                 child: Text(
//                   "Masuk sebagai mitra untuk melanjutkan layanan",
//                   style: TextStyle(fontSize: 14, color: Colors.black54),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // EMAIL FIELD
//               const Text(
//                 "Alamat Email",
//                 style: TextStyle(
//                   color: Colors.blueAccent,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   hintText: "mitra@example.com",
//                   prefixIcon:
//                       const Icon(Icons.email_outlined, color: Colors.blueAccent),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),

//               const SizedBox(height: 20),

//               // PASSWORD FIELD
//               const Text(
//                 "Kata Sandi",
//                 style: TextStyle(
//                   color: Colors.blueAccent,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: _isObscure,
//                 decoration: InputDecoration(
//                   hintText: "Masukkan kata sandi anda",
//                   prefixIcon:
//                       const Icon(Icons.lock_outline, color: Colors.blueAccent),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isObscure ? Icons.visibility_off : Icons.visibility,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () => setState(() => _isObscure = !_isObscure),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 6),

//               // Forgot password
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(context, '/forgot-password-mitra');
//                   },
//                   child: const Text(
//                     "Lupa kata sandi?",
//                     style: TextStyle(
//                       color: Colors.blueAccent,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // LOGIN BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: _login,
//                   child: const Text(
//                     "LOGIN MITRA",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               // REGISTER LINK -> pergi ke signup-mitra (replacement so stack clean)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Belum punya akun? "),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushReplacementNamed(context, '/signup-mitra');
//                     },
//                     child: const Text(
//                       "Daftar",
//                       style: TextStyle(
//                         color: Colors.blueAccent,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),
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

class LoginMitraPage extends StatefulWidget {
  const LoginMitraPage({super.key});

  @override
  State<LoginMitraPage> createState() => _LoginMitraPageState();
}

class _LoginMitraPageState extends State<LoginMitraPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  bool _isLoading = false;
  String? _errorMessage;

  final _authApi = AuthApi();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToRole() {
    Navigator.pushReplacementNamed(context, '/role');
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua kolom")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.loginPartner(
        email: email,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );

      Navigator.pushReplacementNamed(context, '/mitra-home');
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.blueAccent),
                onPressed: _goToRole,
              ),

              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 40,
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Login Mitra",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Center(
                child: Text(
                  "Masuk sebagai mitra untuk melanjutkan layanan",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 14),

              const Text(
                "Alamat Email",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "mitra@example.com",
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              const Text(
                "Kata Sandi",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "Masukkan kata sandi anda",
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot-password-mitra');
                  },
                  child: const Text(
                    "Lupa kata sandi?",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
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
                          "LOGIN MITRA",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/signup-mitra');
                    },
                    child: const Text(
                      "Daftar",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
