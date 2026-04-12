import 'package:flutter/material.dart';
import '../../core/storage/app_prefs.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Layanan Aman & Terpercaya",
      "desc":
          "Bekerja sama dengan mitra terbaik untuk memberikan layanan berkualitas tinggi dan menjamin kepuasan pelanggan setiap saat."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Pesan Mudah & Praktis",
      "desc":
          "Pesan layanan cuci mobil kapan saja dan di mana saja hanya dalam beberapa klik."
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Mitra Terverifikasi",
      "desc":
          "Mitra kami telah terverifikasi dan siap memberikan layanan terbaik untuk kendaraan Anda."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () async {
                            await AppPrefs.setOnboardingDone();
                            if (context.mounted) Navigator.pushNamed(context, '/role');
                          },
                          child: const Text(
                            "Lewati",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: constraints.maxHeight * 0.58,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: onboardingData.length,
                          onPageChanged: (index) =>
                              setState(() => currentIndex = index),
                          itemBuilder: (_, index) {
                            final item = onboardingData[index];

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(item["image"]!,
                                    height: 240, fit: BoxFit.contain),
                                const SizedBox(height: 25),
                                Text(
                                  item["title"]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    item["desc"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? Colors.blueAccent
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (currentIndex == onboardingData.length - 1) {
                              await AppPrefs.setOnboardingDone();
                              if (context.mounted) Navigator.pushNamed(context, '/role');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            currentIndex == onboardingData.length - 1
                                ? "Mulai"
                                : "Lanjut",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
