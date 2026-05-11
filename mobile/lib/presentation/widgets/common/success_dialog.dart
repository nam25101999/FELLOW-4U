import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  static void show(BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    debugPrint("SuccessDialog.show được gọi: $title");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        debugPrint("SuccessDialog builder đang chạy");
        return SuccessDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("SuccessDialog build method đang chạy");
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 20.0, offset: const Offset(0.0, 10.0)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 50.w,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTypography.body2.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text('DONE', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
