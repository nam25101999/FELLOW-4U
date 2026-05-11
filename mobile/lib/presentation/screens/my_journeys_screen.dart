import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/models/profile_models.dart';
import '../../data/services/profile_service.dart';

class MyJourneysScreen extends StatefulWidget {
  const MyJourneysScreen({super.key});

  @override
  State<MyJourneysScreen> createState() => _MyJourneysScreenState();
}

class _MyJourneysScreenState extends State<MyJourneysScreen> {
  final ProfileService _profileService = ProfileService();
  List<UserJourney> _journeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJourneys();
  }

  Future<void> _loadJourneys() async {
    try {
      final journeys = await _profileService.getJourneys();
      setState(() {
        _journeys = journeys;
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Journeys', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  _buildAddJourneyButton(),
                  SizedBox(height: 24.h),
                  ..._journeys.map((j) => Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: _buildJourneyCard(j),
                  )),
                ],
              ),
            ),
    );
  }

  Widget _buildAddJourneyButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, color: AppColors.primary),
      label: Text('Add Journey', style: AppTypography.button.copyWith(color: AppColors.primary)),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Widget _buildJourneyCard(UserJourney journey) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: journey.imageUrls.isNotEmpty 
              ? Image.network(journey.imageUrls[0], height: 180.h, width: double.infinity, fit: BoxFit.cover)
              : Container(height: 180.h, color: AppColors.neutral300, child: const Icon(Icons.image)),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(journey.title, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                    const Icon(Icons.more_horiz),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.w, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(journey.location, style: AppTypography.caption.copyWith(color: AppColors.primary)),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(journey.date, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                    Row(
                      children: [
                        Icon(Icons.favorite_border, size: 16.w, color: Colors.pink),
                        SizedBox(width: 4.w),
                        Text('${journey.likeCount} Likes', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
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
}
