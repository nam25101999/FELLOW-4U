import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import '../../data/services/explore_service.dart';

class FeaturedToursScreen extends StatefulWidget {
  const FeaturedToursScreen({super.key});

  @override
  State<FeaturedToursScreen> createState() => _FeaturedToursScreenState();
}

class _FeaturedToursScreenState extends State<FeaturedToursScreen> {
  final ExploreService _exploreService = ExploreService();
  List<Tour> _tours = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTours();
  }

  Future<void> _fetchTours() async {
    try {
      final data = await _exploreService.getExploreData();
      setState(() {
        _tours = data.featuredTours;
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
                  padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tour = _tours[index];
                        return _buildTourCard(tour);
                      },
                      childCount: _tours.length,
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
              'http://127.0.0.1:8080/uploads/location/tải xuống (6).jpg',
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
                    'Plenty of amazing of tours are waiting for you',
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

  Widget _buildTourCard(Tour tour) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Stack(
              children: [
                Image.network(
                  tour.imageUrl,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 200.h, color: Colors.grey[200]),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: const Icon(Icons.bookmark_border, color: Colors.white),
                ),
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  child: Row(
                    children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tour.title,
                        style: AppTypography.subtitle1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.favorite_border, color: AppColors.primary, size: 20),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.neutral500),
                    SizedBox(width: 4.w),
                    Text(tour.startDate ?? 'Jan 30, 2020', style: AppTypography.caption),
                    SizedBox(width: 16.w),
                    const Icon(Icons.access_time, size: 14, color: AppColors.neutral500),
                    SizedBox(width: 4.w),
                    Text(tour.duration ?? '3 days', style: AppTypography.caption),
                    const Spacer(),
                    Text(
                      '\$${tour.price.toStringAsFixed(2)}',
                      style: AppTypography.h3.copyWith(color: AppColors.primary),
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
}
