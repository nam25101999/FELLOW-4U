import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DynamicPageHeader extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? subtitle;
  final String defaultImageUrl;

  static String get _uploadBaseUrl => 'http://127.0.0.1:8080/uploads/location';

  static String getImageForLocation(String location) {
    final city = location.toLowerCase();
    if (city.contains('da nang')) return '$_uploadBaseUrl/images.jpg';
    if (city.contains('hanoi') || city.contains('ha noi')) return '$_uploadBaseUrl/tải xuống.jpg';
    if (city.contains('saigon') || city.contains('ho chi minh')) return '$_uploadBaseUrl/tải xuống (3).jpg';
    if (city.contains('hue')) return '$_uploadBaseUrl/tải xuống (2).jpg';
    if (city.contains('sapa')) return '$_uploadBaseUrl/tải xuống (5).jpg';
    if (city.contains('phu quoc')) return '$_uploadBaseUrl/images (1).jpg';
    if (city.contains('hoi an')) return '$_uploadBaseUrl/tải xuống (1).jpg';
    if (city.contains('ha long') || city.contains('halong')) return '$_uploadBaseUrl/tải xuống (4).jpg';
    return '$_uploadBaseUrl/tải xuống (7).jpg';
  }

  const DynamicPageHeader({
    super.key,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.defaultImageUrl = 'http://127.0.0.1:8080/uploads/location/tải xuống (7).jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: DecorationImage(
          image: NetworkImage(imageUrl ?? defaultImageUrl),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
          ],
          Text(
            title,
            style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 34.sp),
          ),
        ],
      ),
    );
  }
}
