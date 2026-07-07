import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroPageData> _pages = [
    IntroPageData(
      title: 'আপনার হিসাবকে করুন সহজ',
      subtitle: 'পার্সোনাল এবং বিজনেস লেনদেন ট্র্যাক করুন এক নিমিষেই।',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.primary,
    ),
    IntroPageData(
      title: 'অ্যাডভান্সড অ্যাকাউন্টিং',
      subtitle: 'ডাবল-এন্ট্রি এবং সিম্পল মোড - আপনার প্রয়োজন অনুযায়ী বেছে নিন।',
      icon: Icons.analytics_rounded,
      color: AppColors.secondary,
    ),
    IntroPageData(
      title: 'রিপোর্ট এবং বিশ্লেষণ',
      subtitle: 'আপনার আয়-ব্যয়ের স্বচ্ছ ধারণা পেতে গ্রাফ এবং রিপোর্ট দেখুন।',
      icon: Icons.bar_chart_rounded,
      color: AppColors.accent,
    ),
  ];

  void _onDone() async {
    // Navigate to Login/Setup
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(IntroPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 100, color: page.color),
          ),
          const SizedBox(height: 60),
          Text(
            page.title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.subtitle,
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == _pages.length - 1) {
                  _onDone();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'শুরু করুন' : 'পরবর্তী',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class IntroPageData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  IntroPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
