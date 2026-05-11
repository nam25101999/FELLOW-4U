import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AddAttractionScreen extends StatefulWidget {
  const AddAttractionScreen({super.key});

  @override
  State<AddAttractionScreen> createState() => _AddAttractionScreenState();
}

class _AddAttractionScreenState extends State<AddAttractionScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Dummy suggestions
  final List<String> _suggestions = [
    'Cong Coffee',
    'Cong Hoa Market',
    'Cong Cho',
    'Cong Church'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutral700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Attractions', style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('DONE', style: AppTypography.button.copyWith(color: AppColors.primary, fontSize: 12.sp)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return _buildSuggestionItem(_suggestions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Type a Place',
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () {},
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(text, style: AppTypography.body1.copyWith(color: AppColors.neutral700)),
    );
  }
}
