import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/auth_header.dart';
import 'sign_in_screen.dart';
import 'main_screen.dart'; 
import '../../data/services/auth_service.dart';
import '../widgets/common/success_dialog.dart';
import '../widgets/common/error_dialog.dart';

enum UserRole { traveler, guide }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  UserRole _selectedRole = UserRole.traveler;
  final _authService = AuthService();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 1. Kiểm tra bỏ trống
    if (email.isEmpty || password.isEmpty || _firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ErrorDialog.show(
        context,
        title: 'Missing Info',
        message: 'Vui lòng điền tất cả các trường thông tin bắt buộc.',
      );
      return;
    }

    // 2. Kiểm tra định dạng Email
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(email)) {
      ErrorDialog.show(
        context,
        title: 'Invalid Email',
        message: 'Định dạng email không hợp lệ. Vui lòng nhập đúng (VD: example@gmail.com).',
      );
      return;
    }

    // 3. Kiểm tra mật khẩu mạnh (Ít nhất 8 ký tự, có chữ và số)
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      ErrorDialog.show(
        context,
        title: 'Weak Password',
        message: 'Mật khẩu phải có ít nhất 8 ký tự, bao gồm cả chữ cái và chữ số.',
      );
      return;
    }

    debugPrint("Bắt đầu đăng ký cho: $email");
    if (password != _confirmPasswordController.text) {
      ErrorDialog.show(
        context,
        title: 'Password Mismatch',
        message: 'Mật khẩu xác nhận không khớp. Vui lòng kiểm tra lại.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        role: _selectedRole == UserRole.traveler ? 'TRAVELER' : 'GUIDE',
      );
      debugPrint("Đăng ký thành công, chuẩn bị hiện Dialog");

      if (mounted) {
        SuccessDialog.show(
          context,
          title: 'Success!',
          message: 'Đăng ký thành công! Đang chuyển đến trang đăng nhập.',
          onConfirm: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Sign Up Failed',
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Xây dựng một custom underline input field
  Widget _buildTextField(String label, {String? hint, bool isPassword = false, TextEditingController? controller}) {
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
          obscureText: isPassword,
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Reusable Header
              const AuthHeader(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    // 2. Title "Sign Up" with underline
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign Up',
                          style: AppTypography.h1.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4.h),
                          width: 100.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.blue, // Màu xanh dương như thiết kế
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // 3. Radio Buttons (Role)
                    Row(
                      children: [
                        Radio<UserRole>(
                          value: UserRole.traveler,
                          groupValue: _selectedRole,
                          activeColor: AppColors.primary,
                          onChanged: (UserRole? value) {
                            setState(() {
                              if (value != null) _selectedRole = value;
                            });
                          },
                        ),
                        Text(
                          'Traveler',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 24.w),
                        Radio<UserRole>(
                          value: UserRole.guide,
                          groupValue: _selectedRole,
                          activeColor: AppColors.primary,
                          onChanged: (UserRole? value) {
                            setState(() {
                              if (value != null) _selectedRole = value;
                            });
                          },
                        ),
                        Text(
                          'Guide',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 4. Form Fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField('First Name', hint: 'Yoo', controller: _firstNameController),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField('Last Name', hint: 'Jin', controller: _lastNameController),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    
                    _buildTextField('Country', hint: 'Country'),
                    SizedBox(height: 24.h),
                    
                    _buildTextField('Email', hint: 'Type email', controller: _emailController),
                    SizedBox(height: 24.h),
                    
                    _buildTextField('Password', hint: 'Type password', isPassword: true, controller: _passwordController),
                    SizedBox(height: 8.h),
                    Text(
                      'At least 8 characters, including letters and numbers',
                      style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                    ),
                    SizedBox(height: 24.h),
                    
                    _buildTextField('Confirm Password', hint: '••••••', isPassword: true, controller: _confirmPasswordController),
                    SizedBox(height: 32.h),

                    // 5. Footer (Terms, Button, Sign In Link)
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                          children: [
                            const TextSpan(text: 'By Signing Up, you agree to our '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: _isLoading 
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'SIGN UP',
                              style: AppTypography.button.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.body2.copyWith(color: AppColors.neutral500),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
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
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
