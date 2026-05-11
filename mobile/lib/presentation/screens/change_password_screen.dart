import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/services/profile_service.dart';
import '../widgets/common/success_dialog.dart';
import '../widgets/common/error_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ProfileService _profileService = ProfileService();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _retypeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSave() async {
    final currentPassword = _currentController.text;
    final newPassword = _newController.text;
    final retypePassword = _retypeController.text;

    // 1. Kiểm tra bỏ trống
    if (currentPassword.isEmpty || newPassword.isEmpty || retypePassword.isEmpty) {
      ErrorDialog.show(context, message: 'Vui lòng nhập đầy đủ các trường mật khẩu.');
      return;
    }

    // 2. Kiểm tra khớp mật khẩu
    if (newPassword != retypePassword) {
      ErrorDialog.show(context, message: 'Mật khẩu mới và mật khẩu nhập lại không khớp.');
      return;
    }

    // 3. Kiểm tra độ mạnh mật khẩu (Giống bên SignUp)
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegex.hasMatch(newPassword)) {
      ErrorDialog.show(context, message: 'Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm cả chữ và số.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _profileService.changePassword(currentPassword, newPassword);
      if (mounted) {
        SuccessDialog.show(
          context,
          title: 'Thành công',
          message: 'Mật khẩu của bạn đã được thay đổi thành công!',
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Change Password', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: Text('SAVE', style: AppTypography.button.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),
                _buildPasswordField('Current Password', controller: _currentController),
                SizedBox(height: 24.h),
                _buildPasswordField('New Password', controller: _newController),
                SizedBox(height: 24.h),
                _buildPasswordField('Retype New Password', controller: _retypeController),
              ],
            ),
          ),
    );
  }

  Widget _buildPasswordField(String label, {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
        TextField(
          controller: controller,
          obscureText: true,
          style: AppTypography.body1.copyWith(color: AppColors.neutral900),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral300)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            hintText: '••••••',
          ),
        ),
      ],
    );
  }
}
