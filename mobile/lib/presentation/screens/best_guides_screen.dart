import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import '../../data/services/explore_service.dart';
import 'guide_detail_screen.dart';

class BestGuidesScreen extends StatefulWidget {
  const BestGuidesScreen({super.key});

  @override
  State<BestGuidesScreen> createState() => _BestGuidesScreenState();
}

class _BestGuidesScreenState extends State<BestGuidesScreen> {
  final ExploreService _exploreService = ExploreService();
  List<User> _guides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuides();
  }

  Future<void> _fetchGuides() async {
    try {
      final data = await _exploreService.getAllGuides();
      setState(() {
        _guides = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverHeader(),
                SliverPadding(
                  padding: EdgeInsets.all(24.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final guide = _guides[index];
                        return _buildGuideCard(guide);
                      },
                      childCount: _guides.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 280.h,
      automaticallyImplyLeading: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'http://127.0.0.1:8080/uploads/location/tải xuống (7).jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent, Colors.black45],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 80.h, 48.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Book your own private local Guide and explore the city',
                    style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 24.sp),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: -28.h,
              child: _buildSearchBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Hi, where do you want to explore?',
          hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral500),
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildGuideCard(User guide) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GuideDetailScreen(guide: guide)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  Image.network(
                    guide.avatarUrl ?? 'https://ui-avatars.com/api/?name=${guide.firstName}+${guide.lastName}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.person)),
                  ),
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            final rating = guide.rating ?? 0.0;
                            return Icon(
                              index < rating.floor() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 14.w,
                            );
                          }),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${guide.reviewCount ?? 0} Reviews',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 2.0,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text('${guide.firstName} ${guide.lastName}', style: AppTypography.subtitle2),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: AppColors.primary),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  guide.location ?? 'Danang, Vietnam',
                  style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
