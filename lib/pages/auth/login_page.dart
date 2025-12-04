// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isObscure = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

//                 const SizedBox(height: 10),

//                 // 🔙 Back Button → ke halaman role
//                 IconButton(
//                   icon: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: Colors.blueAccent,
//                   ),
//                   onPressed: () => Navigator.pushReplacementNamed(context, '/role'),
//                 ),

//                 const SizedBox(height: 20),

//                 // ⭐ Header Icon (Mobil)
//                 Center(
//                   child: Container(
//                     width: 95,
//                     height: 95,
//                     padding: const EdgeInsets.all(18),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Image.asset(
//                       "assets/images/icon.png",
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 // ⭐ Title
//                 const Center(
//                   child: Text(
//                     "Selamat Datang",
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1976D2),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 const Center(
//                   child: Text(
//                     "Masuk untuk melanjutkan",
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Color(0xFF1976D2),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // ⭐ Input Email
//                 const Text(
//                   "Alamat Email",
//                   style: TextStyle(
//                     color: Color(0xFF1976D2),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     hintText: "example@gmail.com",
//                     prefixIcon: const Icon(Icons.email_outlined),
//                     filled: true,
//                     fillColor: Colors.blue.shade50.withOpacity(0.3),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ⭐ Input Password
//                 const Text(
//                   "Kata Sandi",
//                   style: TextStyle(
//                     color: Color(0xFF1976D2),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 TextField(
//                   controller: _passwordController,
//                   obscureText: _isObscure,
//                   decoration: InputDecoration(
//                     hintText: "Masukan kata sandi anda",
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     filled: true,
//                     fillColor: Colors.blue.shade50.withOpacity(0.3),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isObscure
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                       ),
//                       onPressed: () =>
//                           setState(() => _isObscure = !_isObscure),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/forgot-password');
//                     },
//                     child: const Text(
//                       "Lupa kata sandi?",
//                       style: TextStyle(
//                         color: Colors.blueAccent,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // ⭐ Login Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: () {
//                       if (_emailController.text.isNotEmpty &&
//                           _passwordController.text.isNotEmpty) {
//                         Navigator.pushReplacementNamed(context, '/home');
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Harap isi semua kolom."),
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text(
//                       "LOG IN",
//                       style: TextStyle(
//                         fontSize: 17,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 // ⭐ Sign Up Link → menuju /signup
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Belum punya akun? "),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, '/signup');
//                       },
//                       child: const Text(
//                         "Daftar sekarang",
//                         style: TextStyle(
//                           color: Colors.blueAccent,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:carwashgo/features/auth/data/auth_api.dart';
import 'package:carwashgo/features/auth/models/auth_response.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua kolom.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.login(
        email: email,
        password: password,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }

    // backend kamu kirim: "status": "success" / "error"
    if (res.status == 'success') {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;

      setState(() {
        _errorMessage = res.message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                // 🔙 Back Button → ke halaman role
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/role'),
                ),

                const SizedBox(height: 20),

                // ⭐ Header Icon (Mobil)
                Center(
                  child: Container(
                    width: 95,
                    height: 95,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/images/icon.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ⭐ Title
                const Center(
                  child: Text(
                    "Selamat Datang",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    "Masuk untuk melanjutkan",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ❗ Error message dari API
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

                // ⭐ Input Email
                const Text(
                  "Alamat Email",
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "example@gmail.com",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.blue.shade50.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ⭐ Input Password
                const Text(
                  "Kata Sandi",
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: "Masukan kata sandi anda",
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.blue.shade50.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
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

                // ⭐ Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
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
                            "LOG IN",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // ⭐ Sign Up Link → menuju /signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        "Daftar sekarang",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

