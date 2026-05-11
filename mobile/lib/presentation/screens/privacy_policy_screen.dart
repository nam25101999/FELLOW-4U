import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.privacyPolicy, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Terms of Service', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
              style: AppTypography.body2.copyWith(color: AppColors.neutral700, height: 1.5),
            ),
            SizedBox(height: 24.h),
            Text('2. Privacy Policy', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Text(
              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
              style: AppTypography.body2.copyWith(color: AppColors.neutral700, height: 1.5),
            ),
            SizedBox(height: 24.h),
            Text('3. Data Collection', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Text(
              'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
              style: AppTypography.body2.copyWith(color: AppColors.neutral700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
