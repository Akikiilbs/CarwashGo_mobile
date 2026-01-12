import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textOffset = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _logoController.forward().then((_) => _textController.forward());
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F8AFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Image.asset(
                  'assets/images/carwashgo_logo1.png',
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 15),
            FadeTransition(
              opacity: _textOpacity,
              child: const Text(
                "Solusi Cuci Mobil Praktis dan Cepat",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 60),

            // ================================
            // TOMBOL MULAI (WAJIB DITEKAN USER)
            // ================================
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/onboarding');
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 25,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  "Mulai",
                  style: TextStyle(
                    color: Color(0xFF5AA9E6),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
