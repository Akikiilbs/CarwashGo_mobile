import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/storage/app_prefs.dart';
import '../features/auth/data/auth_api.dart';
import '../providers/user_provider.dart';

// ganti import sesuai nama page kamu:
import '../pages/onboarding/splash_page.dart';
import '../pages/auth/role_page.dart';
import '../pages/home/home_page.dart';
import '../pages/mitra/home_mitra_page.dart';

class AppGatePage extends StatefulWidget {
  const AppGatePage({super.key});

  @override
  State<AppGatePage> createState() => _AppGatePageState();
}

class _AppGatePageState extends State<AppGatePage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Cek Onboarding
    final onboardingDone = await AppPrefs.isOnboardingDone();
    if (!onboardingDone) {
      if (mounted) _navigateToSplash();
      return;
    }

    // 2. Cek Session
    final authApi = AuthApi();
    final hasToken = await authApi.hasToken();

    if (!hasToken) {
      if (mounted) _navigateToRole();
      return;
    }

    // 3. Ambil data User (Auto login)
    try {
      final authResponse = await authApi.fetchMe();
      if (authResponse.isSuccess && authResponse.user != null) {
        final user = authResponse.user!;
        if (mounted) {
          context.read<UserProvider>().setUser(
                id: user.id,
                name: user.name ?? '',
                email: user.email ?? '',
                phone: user.phone ?? '',
                role: user.role ?? '',
                address: user.address ?? '',
                profilePhotoUrl: user.profilePhotoUrl ?? '',
                latitude: user.latitude,
                longitude: user.longitude,
              );

          // Redirect berdasarkan role
          if (user.role == 'partner') {
            _navigateToPartnerHome();
          } else {
            _navigateToCustomerHome();
          }
        }
      } else {
        // Token invalid atau expired
        await authApi.logout(); // hapus token lokal
        if (mounted) _navigateToRole();
      }
    } catch (e) {
      debugPrint("❌ Auto-login error: $e");
      // Fallback ke role selection jika gagal fetch (misal internet mati)
      // Namun untuk "Stay Logged In" yang bandel, kadang lebih baik stay di halaman loading 
      // atau coba lagi. Tapi untuk sekarang kita arahkan ke RolePage saja.
      if (mounted) _navigateToRole();
    }
  }

  void _navigateToSplash() {
    Navigator.pushReplacementNamed(context, '/splash');
  }

  void _navigateToRole() {
    Navigator.pushReplacementNamed(context, '/role');
  }

  void _navigateToCustomerHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _navigateToPartnerHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/mitra-home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 16),
            Text("Checking session...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
