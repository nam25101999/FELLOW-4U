import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/auth_header.dart';
import 'sign_up_screen.dart';
import 'main_screen.dart';
import 'forgot_password_screen.dart';
import '../../data/services/auth_service.dart';
import '../widgets/common/success_dialog.dart';
import '../widgets/common/error_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ErrorDialog.show(
        context,
        title: 'Empty Fields',
        message: 'Vui lòng nhập đầy đủ email và mật khẩu để tiếp tục.',
      );
      return;
    }
    debugPrint("Bắt đầu đăng nhập với: ${_emailController.text}");
    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      debugPrint("Đăng nhập thành công, chuẩn bị hiện Dialog");
      
      if (mounted) {
        SuccessDialog.show(
          context,
          title: 'Welcome Back!',
          message: 'Chào mừng trở lại, ${response['email']}!',
          onConfirm: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Login Failed',
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

  Widget _buildSocialIcon(Color color, IconData icon) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24.w,
      ),
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
                    // 2. Title "Sign In"
                    Text(
                      'Sign In',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // 3. Welcome text
                    Text(
                      'Welcome back, Yoo Jin',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 4. Form Fields
                    _buildTextField('Email', hint: 'yoojin@gmail.com', controller: _emailController),
                    SizedBox(height: 24.h),
                    
                    _buildTextField('Password', hint: '••••••', isPassword: true, controller: _passwordController),
                    SizedBox(height: 16.h),
                    
                    // 5. Forgot Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Forgot Password',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 6. Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
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
                              'SIGN IN',
                              style: AppTypography.button.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 7. Social Sign In
                    Center(
                      child: Text(
                        'or sign in with',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Facebook Placeholder
                        _buildSocialIcon(const Color(0xFF3B5998), Icons.facebook),
                        SizedBox(width: 16.w),
                        // KakaoTalk Placeholder (Yellow)
                        _buildSocialIcon(const Color(0xFFFFE812), Icons.chat_bubble),
                        SizedBox(width: 16.w),
                        // LINE Placeholder (Green)
                        _buildSocialIcon(const Color(0xFF00B900), Icons.textsms),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // 8. Sign Up Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.body2.copyWith(color: AppColors.neutral500),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign Up',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
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
