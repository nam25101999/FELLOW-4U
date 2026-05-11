import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/services/profile_service.dart';
import '../widgets/common/success_dialog.dart';
import '../widgets/common/error_dialog.dart';
import 'change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (mounted) {
        setState(() {
          _firstNameController.text = profile['firstName'] ?? '';
          _lastNameController.text = profile['lastName'] ?? '';
          _avatarUrl = profile['avatarUrl'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await _profileService.updateProfile({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });
      if (mounted) {
        SuccessDialog.show(
          context,
          title: 'Thành công',
          message: 'Hồ sơ của bạn đã được cập nhật thành công!',
          onConfirm: () => Navigator.pop(context, true),
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
        title: Text('Edit Profile', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
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
        : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60.r,
                        backgroundImage: NetworkImage(_avatarUrl ?? 'https://ui-avatars.com/api/?name=User&background=random'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4.w,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20.w),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48.h),
                
                // Form
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('First Name', controller: _firstNameController),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildTextField('Last Name', controller: _lastNameController),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                _buildTextField('Password', controller: TextEditingController(text: '••••••'), isPassword: true, readOnly: true),
                
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                    child: Text('Change Password', style: AppTypography.body2.copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(String label, {required TextEditingController controller, bool isPassword = false, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
        TextField(
          controller: controller,
          obscureText: isPassword,
          readOnly: readOnly,
          style: AppTypography.body1.copyWith(color: AppColors.neutral900),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral300)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
