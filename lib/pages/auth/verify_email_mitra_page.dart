import 'package:flutter/material.dart';
import 'dart:async';
import 'reset_password_mitra_page.dart';

class VerifyEmailMitraPage extends StatefulWidget {
  final String email;
  const VerifyEmailMitraPage({super.key, required this.email});

  @override
  State<VerifyEmailMitraPage> createState() => _VerifyEmailMitraPageState();
}

class _VerifyEmailMitraPageState extends State<VerifyEmailMitraPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

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

  void _submitCode() {
    String code = _controllers.map((e) => e.text).join();

    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan masukkan 4 digit kode.")),
      );
      return;
    }

    // SUCCESS → redirect to reset password
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordMitraPage(email: widget.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    String seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Verifikasi Email Anda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            const Text("Kode dikirim ke email:",
                style: TextStyle(fontSize: 15)),
            Text(widget.email,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                return SizedBox(
                  width: 60,
                  height: 70,
                  child: TextField(
                    controller: _controllers[i],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 25),

            GestureDetector(
              onTap: _canResend
                  ? () {
                      _startTimer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kode dikirim ulang!")),
                      );
                    }
                  : null,
              child: Text(
                _canResend ? "Kirim Ulang Kode" : "Tunggu...",
                style: TextStyle(
                  color: _canResend ? Colors.blueAccent : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Kode kedaluwarsa dalam $minutes:$seconds",
              style: const TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submitCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Verifikasi",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
