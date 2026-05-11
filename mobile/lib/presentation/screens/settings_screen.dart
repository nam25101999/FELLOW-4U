import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import 'edit_profile_screen.dart';
import 'sign_in_screen.dart';
import 'language_screen.dart';
import 'payment_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'feedback_screen.dart';
import 'usage_screen.dart';
import '../../data/services/profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

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
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.settings, style: AppTypography.h3.copyWith(color: AppColors.neutral900)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24.w),
                child: _buildUserCard(),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingItem(
                      icon: Icons.notifications_none,
                      title: l10n.notifications,
                      trailing: Switch(
                        value: _notificationsEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _notificationsEnabled = value),
                      ),
                    ),
                    _buildSettingItem(
                      icon: Icons.language, 
                      title: l10n.languages, 
                      hasArrow: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
                    ),
                    _buildSettingItem(
                      icon: Icons.payment, 
                      title: l10n.payment, 
                      hasArrow: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentSettingsScreen())),
                    ),
                    _buildSettingItem(
                      icon: Icons.privacy_tip_outlined, 
                      title: l10n.privacyPolicy, 
                      hasArrow: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                    ),
                    _buildSettingItem(
                      icon: Icons.email_outlined, 
                      title: l10n.feedback, 
                      hasArrow: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                    ),
                    _buildSettingItem(
                      icon: Icons.help_outline, 
                      title: l10n.usage, 
                      hasArrow: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsageScreen())),
                    ),
                    
                    SizedBox(height: 40.h),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          l10n.signOut,
                          style: AppTypography.body1.copyWith(color: AppColors.neutral500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: NetworkImage(_userProfile?['avatarUrl'] ?? 'https://ui-avatars.com/api/?name=User&background=random'),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_userProfile?['firstName'] ?? ''} ${_userProfile?['lastName'] ?? ''}'.trim().isEmpty 
                      ? 'User' 
                      : '${_userProfile?['firstName'] ?? ''} ${_userProfile?['lastName'] ?? ''}', 
                  style: AppTypography.subtitle1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(_userProfile?['role'] ?? 'Traveler', style: AppTypography.caption.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('EDIT PROFILE', style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 10.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, Widget? trailing, bool hasArrow = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neutral900),
      title: Text(title, style: AppTypography.body1.copyWith(color: AppColors.neutral900)),
      trailing: trailing ?? (hasArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      onTap: onTap,
    );
  }
}
