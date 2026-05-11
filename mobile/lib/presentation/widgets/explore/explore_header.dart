import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../screens/search_screen.dart';

class ExploreHeader extends StatelessWidget {
  final String location;
  final String temperature;
  final IconData weatherIcon;
  final String? headerImageUrl;

  const ExploreHeader({
    super.key,
    this.location = 'Da Nang',
    this.temperature = '26°C',
    this.weatherIcon = Icons.wb_cloudy_outlined,
    this.headerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: DecorationImage(
          image: NetworkImage(headerImageUrl ?? 'http://127.0.0.1:8080/uploads/location/tải xuống (7).jpg'),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              SizedBox(width: 4.w),
              Text(
                location,
                style: AppTypography.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Explore',
                style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 34.sp),
              ),
              Row(
                children: [
                  Icon(weatherIcon, color: Colors.white, size: 40),
                  SizedBox(width: 8.w),
                  Text(
                    temperature,
                    style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 32.sp),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
