import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import 'home_screen.dart'; 
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate initialization or loading
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background Elements (Mây, Máy bay, Lá cây, v.v.)
          // Lưu ý: Các Positioned dưới đây được đặt ngẫu nhiên vì các file SVG 
          // xuất ra từng thành phần rời rạc. Bạn cần điều chỉnh lại top, bottom, 
          // left, right để chúng khớp hoàn toàn với thiết kế Figma.
          Positioned(
            top: 550.h,
            left: 235.w,
            child: SvgPicture.asset(
              AppAssets.splashVectorMinus1,
              width: 115.w,
              height: 218.h,
            ), 
          ),
          Positioned(
            top: 692.h,
            right: 0.w,
            child: SvgPicture.asset(
              AppAssets.splashVector4,
              width: 376.w,
              height: 121.h,
            ), 
          ),
          Positioned(
            top: 626.h,
            left: 45.w,
            child: SvgPicture.asset(
              AppAssets.splashGroup1,
              width: 52.w,
              height: 176.h,
            ),
          ),
          Positioned(
            top: 674.h,
            left: 175.w,
            child: SvgPicture.asset(
              AppAssets.splashGroupMinus1,
              width: 140.w,
              height: 70.h,
            ),
          ),
          Positioned(
            top: 690.h,
            left: 6.w,
            child: SvgPicture.asset(
              AppAssets.splashGroup,
              width: 31.w,
              height: 110.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 165.h,
            left: 0.w,
            child: SvgPicture.asset(
              AppAssets.splashVector1,
              width: 209.w,
              height: 96.h,
            ), 
          ),
          Positioned(
            top: 102.h,
            left:-10.w,
            child: SvgPicture.asset(
              AppAssets.splashVector2,
              width: 85.w,
              height: 34.h,
            ), 
          ),
          
          Positioned(
            top: 106.h,
            left: 206.w,
            child: SvgPicture.asset(
              AppAssets.splashVector,
              width: 120.w,
              height: 52.h,
            ), 
          ),
          // Các Vector khác
          
          Positioned(
            top: 42.h,
            left: 265.w,
            child: SvgPicture.asset(
              AppAssets.splashVector5,
              width: 106.w,
              height: 47.h,
            ), 
          ),
          Positioned(
            top: 149.h,
            left: 227.w,
            child: SvgPicture.asset(
              AppAssets.splashVector6,
              width: 75.w,
              height: 33.h,
            ), 
          ),

          // Logo chính giữa
          Center(
            child: SvgPicture.asset(
              AppAssets.splashLogo,
              width: 205.w,
              height: 84.76.h,
            ),
          ),
        ],
      ),
    );
  }
}
