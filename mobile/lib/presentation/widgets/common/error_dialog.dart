import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
  });

  static void show(BuildContext context, {
    String title = 'Error',
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50.w,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTypography.h3.copyWith(color: Colors.red),
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
                if (onConfirm != null) onConfirm!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text('TRY AGAIN', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
