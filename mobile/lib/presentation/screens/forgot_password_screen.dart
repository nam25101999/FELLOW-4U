import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/auth_header.dart';
import 'sign_in_screen.dart';
import 'otp_verification_screen.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập email')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã OTP đã được gửi qua email!')),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: _emailController.text),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, {String? hint, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.subtitle2.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(
          controller: controller,
          style: AppTypography.body1.copyWith(color: AppColors.neutral900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral500),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    'Forgot Password',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Input your email, we will send you an instruction to reset your password.',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.neutral500,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildTextField('Email', hint: 'yoojin@gmail.com', controller: _emailController),
                  SizedBox(height: 48.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'SEND',
                            style: AppTypography.button.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                    ),
                  ),
                  SizedBox(height: 100.h),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.body2.copyWith(color: AppColors.neutral500),
                        children: [
                          const TextSpan(text: 'Back to '),
                          TextSpan(
                            text: 'Sign In',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const SignInScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
