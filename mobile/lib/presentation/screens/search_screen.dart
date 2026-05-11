import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(String value) {
    if (value.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchResultsScreen(query: value)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 28),
              ),
              SizedBox(height: 24.h),
              Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onSubmitted: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Where you want to explore',
                    hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral500),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Popular destinations',
                style: AppTypography.subtitle2.copyWith(color: AppColors.neutral500),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: [
                  _buildDestinationTag('Danang, Vietnam'),
                  _buildDestinationTag('Ho Chi Minh, Vietnam'),
                  _buildDestinationTag('Venice, Italy'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationTag(String label) {
    return GestureDetector(
      onTap: () => _onSearch(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.neutral700),
        ),
      ),
    );
  }
}
