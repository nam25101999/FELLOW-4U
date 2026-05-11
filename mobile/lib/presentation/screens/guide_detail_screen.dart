import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import 'booking_screen.dart';

class GuideDetailScreen extends StatefulWidget {
  final User guide;
  const GuideDetailScreen({super.key, required this.guide});

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfo(),
                  SizedBox(height: 24.h),
                  _buildIntroduction(),
                  SizedBox(height: 24.h),
                  _buildVideoSection(),
                  SizedBox(height: 24.h),
                  _buildPriceTable(),
                  SizedBox(height: 32.h),
                  _buildExperiencesSection(),
                  SizedBox(height: 32.h),
                  _buildReviewsSection(),
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.network(
          'http://127.0.0.1:8080/uploads/location/images.jpg',
          height: 180.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40.h,
          left: 24.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        Positioned(
          bottom: -40.h,
          left: 24.w,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4.w),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                widget.guide.avatarUrl ?? '',
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.person)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 50.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.guide.firstName} ${widget.guide.lastName}', style: AppTypography.h3),
                Row(
                  children: [
                    ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                    SizedBox(width: 8.w),
                    Text('127 Reviews', style: AppTypography.caption),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingScreen(guide: widget.guide)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              child: Text('CHOOSE THIS GUIDE', style: AppTypography.button.copyWith(color: Colors.white, fontSize: 12.sp)),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          children: [
            _buildLangTag('Vietnamese'),
            _buildLangTag('English'),
            _buildLangTag('Korean'),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 16),
            SizedBox(width: 4.w),
            Text(widget.guide.location ?? 'Danang, Vietnam', style: AppTypography.caption.copyWith(color: AppColors.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildLangTag(String lang) {
    return Text(lang, style: AppTypography.caption.copyWith(color: AppColors.neutral500));
  }

  Widget _buildIntroduction() {
    return Text(
      widget.guide.bio ?? 'Short introduction: Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
      style: AppTypography.body2.copyWith(color: AppColors.neutral700),
    );
  }

  Widget _buildVideoSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.network(
            'http://127.0.0.1:8080/uploads/location/tải xuống (1).jpg',
            height: 200.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 32),
        ),
      ],
    );
  }

  Widget _buildPriceTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral100),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildPriceRow('1 - 3 Travelers', '\$10/hour'),
          _buildPriceRow('4 - 6 Travelers', '\$14/hour'),
          _buildPriceRow('7 - 9 Travelers', '\$17/hour', isLast: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body2.copyWith(color: AppColors.neutral700)),
          Text(price, style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExperiencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Experiences', style: AppTypography.subtitle1),
        SizedBox(height: 16.h),
        _buildExperienceCard('2 Hour Bicycle Tour exploring Hoi An', 'http://127.0.0.1:8080/uploads/location/tải xuống (3).jpg'),
        SizedBox(height: 24.h),
        _buildExperienceCard('Food tour in Danang', 'http://127.0.0.1:8080/uploads/location/tải xuống (5).jpg'),
      ],
    );
  }

  Widget _buildExperienceCard(String title, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Image.network(imageUrl, height: 160.h, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subtitle2),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                        Text(' Danang, Vietnam', style: AppTypography.caption),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 14, color: AppColors.primary),
                        Text(' 1224 Likes', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: AppTypography.subtitle1),
            Text('SEE MORE', style: AppTypography.caption.copyWith(color: AppColors.primary)),
          ],
        ),
        SizedBox(height: 16.h),
        _buildReviewItem('Pena Valdez', 'https://ui-avatars.com/api/?name=Pena+Valdez'),
        _buildReviewItem('Daehyun', 'https://ui-avatars.com/api/?name=Daehyun'),
      ],
    );
  }

  Widget _buildReviewItem(String name, String avatar) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24.r, backgroundImage: NetworkImage(avatar)),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.subtitle2),
                  Row(
                    children: [
                      ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 12)),
                      SizedBox(width: 8.w),
                      Text('Jan 22, 2020', style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text.',
            style: AppTypography.body2.copyWith(color: AppColors.neutral700),
          ),
        ],
      ),
    );
  }
}
