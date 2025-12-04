// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'reset_password_page.dart';

// class VerifyEmailPage extends StatefulWidget {
//   final String email;
//   const VerifyEmailPage({super.key, required this.email});

//   @override
//   State<VerifyEmailPage> createState() => _VerifyEmailPageState();
// }

// class _VerifyEmailPageState extends State<VerifyEmailPage> {
//   final List<TextEditingController> _controllers =
//       List.generate(4, (_) => TextEditingController());

//   Timer? _timer;
//   int _remainingSeconds = 60;
//   bool _canResend = false;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _remainingSeconds = 60;
//     _canResend = false;

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingSeconds == 0) {
//         timer.cancel();
//         setState(() => _canResend = true);
//       } else {
//         setState(() => _remainingSeconds--);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var c in _controllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   void _submitCode() {
//     String code = _controllers.map((e) => e.text).join();

//     if (code.length != 4) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Silakan masukkan 4 digit kode.")),
//       );
//       return;
//     }

//     // Simulasi verifikasi sukses
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Kode berhasil diverifikasi!")),
//     );

//     // 🔥 Arahkan ke halaman reset password (FIX)
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ResetPasswordPage(email: widget.email),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     String minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
//     String seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               "Verifikasi Email Anda",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 16),
//             Text(
//               "Kami telah mengirimkan kode 4 digit ke email:",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 15),
//             ),
//             Text(
//               widget.email,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//               ),
//             ),
//             const SizedBox(height: 30),

//             // ==========================
//             // INPUT OTP 4 DIGIT
//             // ==========================
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: List.generate(4, (i) {
//                 return SizedBox(
//                   width: 60,
//                   height: 70,
//                   child: TextField(
//                     controller: _controllers[i],
//                     keyboardType: TextInputType.number,
//                     maxLength: 1,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 22),
//                     decoration: InputDecoration(
//                       counterText: "",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       if (value.isNotEmpty && i < 3) {
//                         FocusScope.of(context).nextFocus();
//                       }
//                     },
//                   ),
//                 );
//               }),
//             ),

//             const SizedBox(height: 30),

//             // ==========================
//             // RESEND CODE
//             // ==========================
//             GestureDetector(
//               onTap: _canResend
//                   ? () {
//                       _startTimer();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Kode telah dikirim ulang."),
//                         ),
//                       );
//                     }
//                   : null,
//               child: Text(
//                 _canResend
//                     ? "Kirim Ulang Kode"
//                     : "Tidak menerima kode? Kirim ulang",
//                 style: TextStyle(
//                   fontWeight: _canResend ? FontWeight.bold : FontWeight.normal,
//                   color: _canResend ? Colors.blueAccent : Colors.black87,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 6),
//             Text(
//               "Kode kedaluwarsa dalam $minutes:$seconds",
//               style: const TextStyle(color: Colors.red),
//             ),

//             const SizedBox(height: 40),

//             // ==========================
//             // SUBMIT BUTTON
//             // ==========================
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: _submitCode,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   "Kirim",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:async';

import 'reset_password_page.dart';
import 'package:carwashgo/features/auth/data/auth_api.dart';
import 'package:carwashgo/features/auth/models/auth_response.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  final _authApi = AuthApi();

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 60;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _controllers.map((e) => e.text).join();

    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan masukkan 4 digit kode.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.verifyOtp(
        email: widget.email,
        otp: code,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }

    if (!mounted) return;

    if (res.status == 'success') {
      // verifikasi sukses → lanjut ke reset password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: widget.email),
        ),
      );
    } else {
      // tampilkan pesan error dari API
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

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.resendOtp(email: widget.email);
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
      _startTimer();
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
    String minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    String seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Verifikasi Email Anda",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "Kami telah mengirimkan kode 4 digit ke email:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            Text(
              widget.email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
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

            const SizedBox(height: 20),

            // ==========================
            // INPUT OTP 4 DIGIT
            // ==========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                return SizedBox(
                  width: 60,
                  height: 70,
                  child: TextField(
                    controller: _controllers[i],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && i < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // ==========================
            // RESEND CODE
            // ==========================
            GestureDetector(
              onTap: _canResend && !_isLoading ? _resendCode : null,
              child: Text(
                _canResend
                    ? "Kirim Ulang Kode"
                    : "Tidak menerima kode? Kirim ulang",
                style: TextStyle(
                  fontWeight: _canResend ? FontWeight.bold : FontWeight.normal,
                  color: _canResend ? Colors.blueAccent : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 6),
            Text(
              "Kode kedaluwarsa dalam $minutes:$seconds",
              style: const TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 40),

            // ==========================
            // SUBMIT BUTTON
            // ==========================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        "Kirim",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

