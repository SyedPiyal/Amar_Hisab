import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../auth/provider/auth_provider.dart';

class SecurityPasswordScreen extends StatefulWidget {
  const SecurityPasswordScreen({super.key});

  @override
  State<SecurityPasswordScreen> createState() => _SecurityPasswordScreenState();
}

class _SecurityPasswordScreenState extends State<SecurityPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _biometricEnabled = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthProvider>().updatePassword(_newPasswordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পাসওয়ার্ড আপডেট করা হয়েছে')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'নিরাপত্তা ও পাসওয়ার্ড',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'পাসওয়ার্ড পরিবর্তন',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'বর্তমান পাসওয়ার্ড',
                controller: _oldPasswordController,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'নতুন পাসওয়ার্ড',
                controller: _newPasswordController,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'নতুন পাসওয়ার্ড নিশ্চিত করুন',
                controller: _confirmPasswordController,
                validator: (val) {
                  if (val != _newPasswordController.text) return 'পাসওয়ার্ড মিলেনি';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'পাসওয়ার্ড আপডেট করুন',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                ),
              ),
              // const SizedBox(height: 48),
              // Text(
              //   'অন্যান্য নিরাপত্তা',
              //   style: GoogleFonts.hindSiliguri(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: AppColors.textPrimary,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // _buildSecurityToggle(
              //   'বায়োমেট্রিক লগইন',
              //   'ফিংগারপ্রিন্ট বা ফেস আইডি ব্যবহার করুন',
              //   _biometricEnabled,
              //   (val) => setState(() => _biometricEnabled = val),
              // ),
              // const SizedBox(height: 32),
              // OutlinedButton(
              //   onPressed: () {},
              //   style: OutlinedButton.styleFrom(
              //     minimumSize: const Size(double.infinity, 50),
              //     side: const BorderSide(color: AppColors.error),
              //     foregroundColor: AppColors.error,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: Text(
              //     'সকল ডিভাইস থেকে লগ আউট করুন',
              //     style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator ?? (val) => val!.isEmpty ? 'পাসওয়ার্ড দিন' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.hindSiliguri(fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildSecurityToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.hindSiliguri(fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
