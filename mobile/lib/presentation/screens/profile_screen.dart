import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/models/profile_models.dart';
import '../../data/services/profile_service.dart';
import 'settings_screen.dart';
import 'my_photos_screen.dart';
import 'my_journeys_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _userProfile;
  List<UserPhoto> _photos = [];
  List<UserJourney> _journeys = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userProfile = await _profileService.getUserProfile();
      final photos = await _profileService.getPhotos();
      final journeys = await _profileService.getJourneys();
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _photos = photos;
          _journeys = journeys;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint(e.toString());
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        // 1. Upload to server
        final imageUrl = await _profileService.uploadImage(image);
        // 2. Update user profile
        await _profileService.updateProfile({
          'firstName': _userProfile?['firstName'],
          'lastName': _userProfile?['lastName'],
          'avatarUrl': imageUrl,
        });
        // 3. Reload data
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        _buildSectionHeader(
                          'My Photos', 
                          onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPhotosScreen())),
                        ),
                        SizedBox(height: 16.h),
                        _photos.isEmpty 
                          ? const Text('Chưa có ảnh nào') 
                          : _buildPhotoGrid(),
                        SizedBox(height: 32.h),
                        _buildSectionHeader(
                          'My Journeys', 
                          onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyJourneysScreen())),
                        ),
                        SizedBox(height: 16.h),
                        _journeys.isEmpty 
                          ? const Text('Chưa có chuyến đi nào')
                          : _buildJourneyList(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Photo
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Avatar and Info
        Positioned(
          bottom: -50.h,
          left: 24.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45.r,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42.r,
                      backgroundImage: NetworkImage(_userProfile?['avatarUrl'] ?? 'https://ui-avatars.com/api/?name=User&background=random'),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 16.w),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_userProfile?['firstName'] ?? ''} ${_userProfile?['lastName'] ?? ''}'.trim().isEmpty 
                          ? 'User' 
                          : '${_userProfile?['firstName'] ?? ''} ${_userProfile?['lastName'] ?? ''}',
                      style: AppTypography.h3.copyWith(color: AppColors.neutral900),
                    ),
                    Text(_userProfile?['email'] ?? 'email@example.com', style: AppTypography.body2.copyWith(color: AppColors.neutral500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: onSeeAll,
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) return const SizedBox();
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(_photos[0].imageUrl, height: 160.h, fit: BoxFit.cover),
          ),
        ),
        if (_photos.length > 1) SizedBox(width: 8.w),
        if (_photos.length > 1)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(_photos[1].imageUrl, height: 76.h, width: double.infinity, fit: BoxFit.cover),
                ),
                if (_photos.length > 2) SizedBox(height: 8.h),
                if (_photos.length > 2)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(_photos[2].imageUrl, height: 76.h, width: double.infinity, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildJourneyList() {
    return Column(
      children: _journeys.map((journey) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: _buildJourneyCard(
          journey.title,
          journey.location,
          journey.date,
          journey.imageUrls.isNotEmpty ? journey.imageUrls[0] : 'https://via.placeholder.com/150',
          journey.likeCount,
        ),
      )).toList(),
    );
  }

  Widget _buildJourneyCard(String title, String location, String date, String imageUrl, int likeCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Image.network(imageUrl, height: 180.h, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                    const Icon(Icons.more_horiz, color: AppColors.neutral500),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.w, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(location, style: AppTypography.caption.copyWith(color: AppColors.primary)),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                    Row(
                      children: [
                        Icon(Icons.favorite_border, size: 16.w, color: Colors.pink),
                        SizedBox(width: 4.w),
                        Text('$likeCount Likes', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
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
