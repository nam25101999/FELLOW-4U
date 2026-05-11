import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import '../../data/services/explore_service.dart';
import 'tour_detail_screen.dart';
import 'package:intl/intl.dart';

class TopJourneysScreen extends StatefulWidget {
  const TopJourneysScreen({super.key});

  @override
  State<TopJourneysScreen> createState() => _TopJourneysScreenState();
}

class _TopJourneysScreenState extends State<TopJourneysScreen> {
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
        _tours = data.topJourneys;
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
      appBar: AppBar(
        title: Text('Top Journeys', style: AppTypography.h3),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: _tours.length,
              itemBuilder: (context, index) {
                final tour = _tours[index];
                return _buildTourCard(tour);
              },
            ),
    );
  }

  Widget _buildTourCard(Tour tour) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour)),
      ),
      child: Container(
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
              child: Image.network(
                tour.imageUrl,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 200.h, color: Colors.grey[200]),
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
                          style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${tour.price.toStringAsFixed(2)}',
                        style: AppTypography.h3.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.neutral500),
                      SizedBox(width: 4.w),
                      Text(
                        tour.startDate != null 
                          ? DateFormat('MMM dd, yyyy').format(DateTime.parse(tour.startDate!)) 
                          : 'Jan 30, 2020',
                        style: AppTypography.caption
                      ),
                      SizedBox(width: 16.w),
                      const Icon(Icons.access_time, size: 14, color: AppColors.neutral500),
                      SizedBox(width: 4.w),
                      Text(tour.duration ?? '3 days', style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
