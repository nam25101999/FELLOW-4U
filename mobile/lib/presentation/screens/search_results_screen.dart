import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import '../../data/services/explore_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ExploreService _exploreService = ExploreService();
  ExploreResponse? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _exploreService.searchData(widget.query);
      setState(() {
        _data = data;
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGuidesSection(),
                        _buildToursSection(),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 28),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.query,
                          style: AppTypography.body1,
                        ),
                      ),
                      const Icon(Icons.cancel, color: AppColors.neutral400, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.neutral700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidesSection() {
    final guides = _data?.bestGuides ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Guides in ${widget.query}'),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              return Container(
                width: 150.w,
                margin: EdgeInsets.only(right: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        guide.avatarUrl ?? '',
                        height: 150.h,
                        width: 150.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text('${guide.firstName} ${guide.lastName}', style: AppTypography.subtitle2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.primary),
                        Text(guide.location ?? '', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToursSection() {
    final tours = _data?.featuredTours ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tours in ${widget.query}'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          itemCount: tours.length,
          itemBuilder: (context, index) {
            final tour = tours[index];
            return Container(
              margin: EdgeInsets.only(bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.network(
                      tour.imageUrl,
                      height: 180.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tour.title, style: AppTypography.subtitle1),
                      const Icon(Icons.favorite_border, color: AppColors.primary),
                    ],
                  ),
                  Text('\$${tour.price}', style: AppTypography.h3.copyWith(color: AppColors.primary)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.h3),
          Text('SEE MORE', style: AppTypography.caption.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterModal(),
    );
  }
}

class FilterModal extends StatelessWidget {
  const FilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Filters', style: AppTypography.h3),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              _buildTab('Guides', true),
              SizedBox(width: 12.w),
              _buildTab('Tours', false),
            ],
          ),
          SizedBox(height: 24.h),
          Text('Date', style: AppTypography.subtitle2),
          TextField(
            decoration: InputDecoration(
              hintText: 'mm/dd/yy',
              prefixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          SizedBox(height: 24.h),
          Text('Guide\'s Language', style: AppTypography.subtitle2),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildTag('Vietnamese', true),
              _buildTag('English', false),
              _buildTag('Korean', false),
              _buildTag('Spanish', false),
              _buildTag('French', false),
            ],
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: const Text('APPLY FILTERS', style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.neutral200),
      ),
      child: Text(
        label,
        style: AppTypography.body1.copyWith(color: isSelected ? Colors.white : AppColors.neutral700),
      ),
    );
  }

  Widget _buildTag(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.neutral200),
      ),
      child: Text(label, style: AppTypography.caption),
    );
  }
}
