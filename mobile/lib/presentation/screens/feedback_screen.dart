import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/common/success_dialog.dart';
import '../../data/services/profile_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  bool _isSubmitting = false;

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
        title: Text(l10n.feedback, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help you?', style: AppTypography.h3),
            SizedBox(height: 8.h),
            Text('Tell us about your experience or report an issue.', style: AppTypography.body2.copyWith(color: AppColors.neutral500)),
            SizedBox(height: 32.h),
            TextField(
              controller: _feedbackController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.neutral200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.neutral200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () async {
                if (_feedbackController.text.isNotEmpty) {
                  setState(() => _isSubmitting = true);
                  try {
                    await _profileService.submitFeedback(_feedbackController.text);
                    if (mounted) {
                      SuccessDialog.show(
                        context,
                        title: 'Thank You!',
                        message: 'Your feedback has been submitted successfully.',
                        onConfirm: () => Navigator.pop(context),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('SUBMIT', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
