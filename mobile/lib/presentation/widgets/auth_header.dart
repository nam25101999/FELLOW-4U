import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 220.h,
      child: Stack(
        clipBehavior: Clip.hardEdge, // Đảm bảo không bị tràn ra ngoài che khuất phần dưới
        children: [
          // Nền xanh phẳng ở đỉnh trang
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 220.h,
              color: AppColors.primary,
            ),
          ),

          
          
          // Nét đứt (Vector 1)
          Positioned(
            top: 96.h,
            left: 92.w,
            child: SvgPicture.asset(
              AppAssets.signUpDashedLine,
              width: 209.w,
              height: 96.h,
            ),
          ),

          // Máy bay (Vector)
          Positioned(
            top: 49.h,
            left: 289.w,
            child: SvgPicture.asset(
              AppAssets.signUpPlane,
              width: 74.w,
              height: 49.h,
            ),
          ),

          // Đám mây (Vector 6)
          Positioned(
            top: 99.h,
            left: 215.w,
            child: SvgPicture.asset(
              AppAssets.signUpCloud,
              width: 57.w,
              height: 25.h,
              colorFilter: const ColorFilter.mode(
                Colors.black12,
                BlendMode.srcIn,
              ),
            ),
          ),

          // Logo vuông (Group 3)
          Positioned(
            top: 59.h,
            left: 32.w,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.signUpLogo,
                  width: 56.w,
                  height: 56.w,
                ),
              ),
            ),
          ),

          // Đường cong màu trắng (Rectangle 5)
          Positioned(
            top: 135.h, // Đè nhẹ lên viền dưới
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              AppAssets.signUpRectangle5,
              width: 375.w,
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    );
  }
}
