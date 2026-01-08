import 'package:flutter/material.dart';
import '../core/storage/app_prefs.dart';

// ganti import sesuai nama page kamu:
import '../pages/onboarding/splash_page.dart';
// import '../pages/onboarding/onboarding_page.dart';
import '../pages/auth/role_page.dart';

class AppGatePage extends StatelessWidget {
  const AppGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AppPrefs.isOnboardingDone(),
      builder: (context, snap) {
        if (!snap.hasData) {
          // loading singkat (bisa diganti splash minimal)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final done = snap.data!;
        if (done) {
          return const RolePage(); // ✅ langsung pilih peran
        } else {
          // opsi 1: langsung onboarding
          // return const OnboardingPage();

          // opsi 2: kalau kamu mau splash dulu baru onboarding,
          // lebih enak: SplashPage-nya yang navigate ke onboarding.
          return const SplashPage();
        }
      },
    );
  }
}
