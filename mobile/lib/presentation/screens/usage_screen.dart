import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';

class UsageScreen extends StatelessWidget {
  const UsageScreen({super.key});

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
        title: Text(l10n.usage, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          _buildUsageItem(
            '1. Find a Guide',
            'Browse our community of expert guides to find the perfect match for your trip.',
            Icons.person_search,
          ),
          SizedBox(height: 24.h),
          _buildUsageItem(
            '2. Book a Trip',
            'Select your desired dates and confirm your booking with ease.',
            Icons.book_online,
          ),
          SizedBox(height: 24.h),
          _buildUsageItem(
            '3. Enjoy your Journey',
            'Experience the local culture and create unforgettable memories.',
            Icons.explore,
          ),
          SizedBox(height: 24.h),
          _buildUsageItem(
            '4. Share Experiences',
            'Post photos and stories about your trip to inspire other travelers.',
            Icons.share,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24.w),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h),
              Text(description, style: AppTypography.body2.copyWith(color: AppColors.neutral700)),
            ],
          ),
        ),
      ],
    );
  }
}
