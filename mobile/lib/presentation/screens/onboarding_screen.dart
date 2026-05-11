import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/onboarding_model.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    OnboardingModel(
      title: 'Find a local guide easily',
      description: 'With Fellow4U, you can find a local guide for you trip easily and explore as the way you want.',
      imagePath: AppAssets.onboarding198,
      imageWidth: 347.w,
      imageHeight: 466.h,
      imageTop: 30.h,
      imageRight: 0.w,
    ),
    OnboardingModel(
      title: 'Many tours around the world',
      description: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      imagePath: AppAssets.onboarding201,
      imageWidth: 380.w,
      imageHeight: 437.h,
      imageTop: 33.h,
      imageLeft: 0.w,
    ),
    OnboardingModel(
      title: 'Create a trip and get offers',
      description: 'Fellow4U helps you save time and get offers from hundred local guides that suit your trip.',
      imagePath: AppAssets.onboarding177,
      imageWidth: 344.w,
      imageHeight: 423.h,
      imageTop: 62.h,
      imageLeft: 0.w,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 4.h,
          width: _currentPage == index ? 24.w : 12.w,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.primary : AppColors.neutral300,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Stack(
                    children: [
                      // Hình ảnh SVG với tọa độ tùy chỉnh
                      Positioned(
                        top: item.imageTop,
                        left: item.imageLeft,
                        right: item.imageRight,
                        bottom: item.imageBottom,
                        child: SvgPicture.asset(
                          item.imagePath,
                          width: item.imageWidth,
                          height: item.imageHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // Phần Text (Tiêu đề & Mô tả)
                      Positioned(
                        left: 24.w,
                        right: 24.w,
                        bottom: 40.h, // Đẩy text lên trên indicator
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.h3.copyWith(
                                color: AppColors.neutral900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              item.description,
                              style: AppTypography.body2.copyWith(
                                color: AppColors.neutral500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Bottom Section (Indicator + SKIP / GET STARTED)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: [
                  if (_currentPage < _pages.length - 1) ...[
                    _buildPageIndicator(),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _onSkip,
                          child: Text(
                            'SKIP',
                            style: AppTypography.button.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Get Started Button on the last page
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _onSkip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'GET STARTED',
                          style: AppTypography.button.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
