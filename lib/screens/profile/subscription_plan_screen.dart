import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'সাবস্ক্রিপশন প্ল্যান',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'আপনার জন্য সঠিক প্ল্যানটি বেছে নিন',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'এক্সক্লুসিভ সব ফিচার আনলক করুন এবং আপনার হিসাবকে আরও স্মার্ট করুন।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Toggle Monthly/Yearly
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleOption('মাসিক', !_isYearly),
                  _buildToggleOption('বার্ষিক (২০% ছাড়)', _isYearly),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Plans
            _buildPlanCard(
              title: 'ফ্রি (Free)',
              price: '৳ ০',
              subtitle: 'সব সময়ের জন্য ফ্রি',
              color: AppColors.textSecondary,
              features: [
                'বেসিক আয়-ব্যয় ট্র্যাকিং',
                'একটি মাত্র অ্যাকাউন্ট বা ক্যাশ বক্স',
                'সাপ্তাহিক রিপোর্ট',
                'কমিউনিটি সাপোর্ট',
              ],
              buttonText: 'বর্তমান প্ল্যান',
              isCurrent: true,
            ),
            const SizedBox(height: 24),
            _buildPlanCard(
              title: 'প্রো (Pro)',
              price: _isYearly ? '৳ ১,৯৯৯/বছর' : '৳ ১৯৯/মাস',
              subtitle: 'সবচেয়ে জনপ্রিয় চয়েস',
              color: AppColors.primary,
              features: [
                'আনলিমিটেড অ্যাকাউন্ট ও ক্যাশ বক্স',
                'অ্যাডভান্সড ডাবল-এন্ট্রি সিস্টেম',
                'ডিটেইলড পিডিএফ ও এক্সেল রিপোর্ট',
                'বাজেট ও লিমিট সেটআপ',
                'ব্যাকআপ ও রিস্টোর সুবিধা',
                'বিজ্ঞাপন মুক্ত অভিজ্ঞতা',
              ],
              buttonText: 'প্রো-তে আপগ্রেড করুন',
              isPopular: true,
            ),
            const SizedBox(height: 24),
            _buildPlanCard(
              title: 'বিজনেস (Business)',
              price: _isYearly ? '৳ ৪,৯৯৯/বছর' : '৳ ৪৯৯/মাস',
              subtitle: 'ব্যবসায়িক প্রয়োজনে',
              color: const Color(0xff1a1a1a),
              features: [
                'প্রো এর সকল সুবিধা',
                'মাল্টি-ইউজার ড্যাশবোর্ড',
                'ইনভেন্টরি ও স্টক ট্র্যাকিং',
                'কাস্টমার ও সাপ্লায়ার ম্যানেজমেন্ট',
                'ডেডিকেটেড সাপোর্ট টিম',
              ],
              buttonText: 'বিজনেস শুরু করুন',
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = (label.contains('বার্ষিক'))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required Color color,
    required List<String> features,
    required String buttonText,
    bool isCurrent = false,
    bool isPopular = false,
  }) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPopular ? AppColors.primary : AppColors.border,
              width: isPopular ? 2 : 1,
            ),
            boxShadow: [
              if (isPopular)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isCurrent ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: Text(
                'সেরা ডিল',
                style: GoogleFonts.hindSiliguri(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
