import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/tour_action_service.dart';
import '../../data/models/explore_model.dart';

class TourDetailScreen extends StatefulWidget {
  final Tour tour;
  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  final TourActionService _actionService = TourActionService();
  int _currentDay = 1;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _actionService.getTourStatus(widget.tour.id);
    if (mounted) {
      setState(() {
        _isLiked = status['liked'] ?? false;
        _isBookmarked = status['bookmarked'] ?? false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final result = await _actionService.toggleLike(widget.tour.id);
    if (mounted) {
      setState(() => _isLiked = result);
    }
  }

  Future<void> _toggleBookmark() async {
    final result = await _actionService.toggleBookmark(widget.tour.id);
    if (mounted) {
      setState(() => _isBookmarked = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitlePrice(),
                      SizedBox(height: 16.h),
                      _buildReviewAndProvider(),
                      SizedBox(height: 24.h),
                      _buildSummaryCard(),
                      SizedBox(height: 32.h),
                      _buildScheduleSection(),
                      SizedBox(height: 32.h),
                      _buildPriceSection(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Image.network(
          widget.tour.imageUrl,
          height: 300.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40.h,
          left: 24.w,
          right: 24.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircularButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
              Row(
                children: [
                  _buildCircularButton(Icons.share, _showShareDialog),
                  SizedBox(width: 12.w),
                  _buildCircularButton(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    _toggleLike,
                    iconColor: _isLiked ? Colors.red : Colors.white,
                  ),
                  SizedBox(width: 12.w),
                  _buildCircularButton(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    _toggleBookmark,
                    iconColor: _isBookmarked ? Colors.amber : Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: index == 0 ? 20.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: index == 0 ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onTap, {Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildTitlePrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.tour.title,
            style: AppTypography.h3.copyWith(fontSize: 24.sp),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${widget.tour.price.toStringAsFixed(2)}', style: AppTypography.h3.copyWith(color: AppColors.primary)),
            Text('\$480.00', style: AppTypography.caption.copyWith(decoration: TextDecoration.lineThrough)),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewAndProvider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
            SizedBox(width: 8.w),
            Text('145 Reviews', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Text('Provider', style: AppTypography.body2.copyWith(color: AppColors.neutral500)),
            SizedBox(width: 12.w),
            Text('dulichviet', style: AppTypography.body2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: AppTypography.subtitle1),
          SizedBox(height: 16.h),
          _buildSummaryRow('Itinerary', widget.tour.title),
          _buildSummaryRow('Duration', widget.tour.duration ?? '3 days'),
          _buildSummaryRow('Departure Date', widget.tour.startDate ?? 'Feb 12'),
          _buildSummaryRow('Departure Place', 'Da Nang'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
          Text(value, style: AppTypography.body2),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map_outlined, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text('Schedule', style: AppTypography.subtitle1),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildDayTab(1),
            SizedBox(width: 12.w),
            _buildDayTab(2),
          ],
        ),
        SizedBox(height: 24.h),
        _buildTimelineItem('6:00 AM', 'Departure from Da Nang and head to Ba Na Hills.'),
        _buildTimelineItem('10:00 AM', 'Visit Golden Bridge and French Village.'),
        _buildTimelineItem('1:00 PM', 'Lunch and explore the Linh Ung Pagoda.'),
        _buildTimelineItem('8:00 PM', 'Check-in hotel and free time.'),
      ],
    );
  }

  Widget _buildDayTab(int day) {
    bool isSelected = _currentDay == day;
    return GestureDetector(
      onTap: () => setState(() => _currentDay = day),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.neutral200),
        ),
        child: Text(
          'Day $day',
          style: TextStyle(color: isSelected ? Colors.white : AppColors.neutral700, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String time, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
              Container(width: 2.w, height: 40.h, color: AppColors.neutral100),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: AppTypography.body1.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text(desc, style: AppTypography.body2.copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text('Price', style: AppTypography.subtitle1),
          ],
        ),
        SizedBox(height: 16.h),
        _buildPriceRow('Adult (>10 years old)', '\$${widget.tour.price}'),
        _buildPriceRow('Child (5 - 10 years old)', '\$${(widget.tour.price * 0.8).toStringAsFixed(0)}'),
        _buildPriceRow('Child (<5 years old)', 'Free'),
      ],
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.neutral100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body2),
          Text(price, style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
          child: Text('BOOK THIS TOUR', style: AppTypography.button.copyWith(color: Colors.white)),
        ),
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share on', style: AppTypography.subtitle1),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareItem('Facebook', Icons.facebook, Colors.blue),
                  _buildShareItem('Twitter', Icons.telegram, Colors.lightBlue),
                  _buildShareItem('WhatsApp', Icons.chat, Colors.green),
                  _buildShareItem('Email', Icons.email, Colors.red),
                ],
              ),
              SizedBox(height: 32.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTypography.button.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        SizedBox(height: 8.h),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
