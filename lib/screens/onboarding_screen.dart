import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> _pages(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      {
        "image": "assets/logo_en.png", // cover
        "title": loc.onboardTitle1,
        "desc": loc.onboardDesc1,
      },
      {
        "image": "assets/onboard_add.png", //
        "title": loc.onboardTitle2,
        "desc": loc.onboardDesc2,
      },
      {
        "image": "assets/onboard_cloud.png", // 
        "title": loc.onboardTitle3,
        "desc": loc.onboardDesc3,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7EFEA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, idx) {
                  final p = pages[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (p["image"] != null)
                          Image.asset(
                            p["image"]!,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        const SizedBox(height: 36),
                        Text(
                          p["title"] ?? "",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: const Color(0xFFB17250),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          p["desc"] ?? "",
                          style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  decoration: BoxDecoration(
                    color: _currentPage == i ? const Color(0xFFB17250) : Colors.brown.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB17250),
                  minimumSize: const Size(180, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _currentPage == pages.length - 1
                    ? widget.onFinish
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                child: Text(
                  _currentPage == pages.length - 1
                      ? AppLocalizations.of(context)!.onboardStart
                      : AppLocalizations.of(context)!.next ?? "Next",
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
