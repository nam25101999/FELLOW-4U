import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/auth_service.dart';
import '../widgets/auth_header.dart';
import 'sign_in_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu không khớp')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(widget.email, widget.otp, _passwordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
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

  Widget _buildTextField(String label, {String? hint, bool isPassword = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.subtitle2.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w600)),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: AppTypography.body1.copyWith(color: AppColors.neutral900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral500),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral300)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
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
          children: [
            const AuthHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text('Reset Password', style: AppTypography.h1),
                  SizedBox(height: 16.h),
                  Text(
                    'Set your new password to login.',
                    style: AppTypography.body2.copyWith(color: AppColors.neutral500),
                  ),
                  SizedBox(height: 40.h),
                  _buildTextField('New Password', hint: '••••••', isPassword: true, controller: _passwordController),
                  SizedBox(height: 24.h),
                  _buildTextField('Confirm Password', hint: '••••••', isPassword: true, controller: _confirmPasswordController),
                  SizedBox(height: 48.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('RESET PASSWORD', style: AppTypography.button.copyWith(color: Colors.white)),
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
