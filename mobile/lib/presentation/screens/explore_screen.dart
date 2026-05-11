import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../core/network/dio_client.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/explore_service.dart';
import '../../data/models/explore_model.dart';
import '../widgets/explore/explore_header.dart';
import 'best_guides_screen.dart';
import 'featured_tours_screen.dart';
import 'tour_detail_screen.dart';
import 'guide_detail_screen.dart';
import 'search_screen.dart';
import 'top_journeys_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  final ExploreService _exploreService = ExploreService();
  final Dio _dio = DioClient().dio;
  ExploreResponse? _data;
  bool _isLoading = true;
  String? _error;
  
  String _currentLocation = "Da Nang";
  String _currentTemp = "26°C";
  String? _currentHeaderImage;

  String _getHeaderImageForLocation(String location) {
    const String uploadBaseUrl = 'http://127.0.0.1:8080/uploads/location';
    final city = location.toLowerCase();
    if (city.contains('da nang')) return '$uploadBaseUrl/images.jpg';
    if (city.contains('hanoi') || city.contains('ha noi')) return '$uploadBaseUrl/tải xuống.jpg';
    if (city.contains('saigon') || city.contains('ho chi minh')) return '$uploadBaseUrl/tải xuống (3).jpg';
    if (city.contains('hue')) return '$uploadBaseUrl/tải xuống (2).jpg';
    if (city.contains('phu quoc')) return '$uploadBaseUrl/images (1).jpg';
    if (city.contains('sapa')) return '$uploadBaseUrl/tải xuống (5).jpg';
    if (city.contains('ha long') || city.contains('halong')) return '$uploadBaseUrl/tải xuống (4).jpg';
    return '$uploadBaseUrl/tải xuống (7).jpg';
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _currentLocation = "Locating...";
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _currentLocation = "GPS Disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() => _currentLocation = "Permission Denied");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Fetch Weather after getting position
      _fetchWeather(position.latitude, position.longitude);

      if (kIsWeb) {
        try {
          final response = await _dio.get('https://api.bigdatacloud.net/data/reverse-geocode-client', queryParameters: {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'localityLanguage': 'en',
          });
          
          if (response.statusCode == 200) {
            String? city = response.data['city'] ?? response.data['locality'] ?? response.data['principalSubdivision'];
            if (city != null && city.isNotEmpty) {
              if (!mounted) return;
              setState(() {
                _currentLocation = city;
                _currentHeaderImage = _getHeaderImageForLocation(city);
              });
              return;
            }
          }
          if (!mounted) return;
          setState(() {
            _currentLocation = "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
            _currentHeaderImage = _getHeaderImageForLocation(_currentLocation);
          });
        } catch (e) {
          debugPrint("Web Geocoding failed: $e");
          if (!mounted) return;
          setState(() {
            _currentLocation = "Browser Location";
          });
        }
        return;
      }

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _currentLocation = placemarks[0].locality ?? placemarks[0].subAdministrativeArea ?? "Da Nang";
            _currentHeaderImage = _getHeaderImageForLocation(_currentLocation);
          });
        }
      } catch (geocodingError) {
        debugPrint("Geocoding failed: $geocodingError");
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Lỗi lấy vị trí: $e");
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final response = await _dio.get('https://api.open-meteo.com/v1/forecast', queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current_weather': true,
      });
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _currentTemp = "${response.data['current_weather']['temperature'].round()}°C";
        });
      }
    } catch (e) {
      debugPrint("Weather fetch failed: $e");
    }
  }

  Future<void> _fetchData() async {
    try {
      final data = await _exploreService.getExploreData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchData();
          await _getCurrentLocation();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ExploreHeader(
                    location: _currentLocation,
                    temperature: _currentTemp,
                    headerImageUrl: _currentHeaderImage,
                  ),
                  Positioned(
                    bottom: -28.h,
                    left: 24.w,
                    right: 24.w,
                    child: _buildSearchBar(),
                  ),
                ],
              ),
              SizedBox(height: 50.h),
              
              if (_data!.topJourneys.isNotEmpty) ...[
                _buildSectionHeader(
                  'Top Journeys',
                  showSeeMore: true,
                  onSeeMore: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TopJourneysScreen()),
                  ),
                ),
                _buildTopJourneys(_data!.topJourneys),
              ],
              
              if (_data!.bestGuides.isNotEmpty) ...[
                _buildSectionHeader(
                  'Best Guides',
                  showSeeMore: true,
                  onSeeMore: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BestGuidesScreen()),
                  ),
                ),
                _buildBestGuides(_data!.bestGuides),
              ],
              
              if (_data!.topExperiences.isNotEmpty) ...[
                _buildSectionHeader('Top Experiences', showSeeMore: false),
                _buildTopExperiences(_data!.topExperiences),
              ],
              
              if (_data!.featuredTours.isNotEmpty) ...[
                _buildSectionHeader(
                  'Featured Tours',
                  showSeeMore: true,
                  onSeeMore: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeaturedToursScreen()),
                  ),
                ),
                _buildFeaturedTours(_data!.featuredTours),
              ],

              if (_data!.travelNews.isNotEmpty) ...[
                _buildSectionHeader('Travel News', showSeeMore: true),
                _buildTravelNews(_data!.travelNews.take(3).toList()),
              ],
              
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        ),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              const Icon(Icons.search, color: AppColors.neutral500, size: 28),
              SizedBox(width: 12.w),
              Text(
                'Hi, where do you want to explore?',
                style: AppTypography.body1.copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool showSeeMore, VoidCallback? onSeeMore}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold, fontSize: 24.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showSeeMore)
            GestureDetector(
              onTap: onSeeMore,
              child: Text(
                'SEE MORE',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopJourneys(List<Tour> journeys) {
    return SizedBox(
      height: 320.h,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 24.w),
        scrollDirection: Axis.horizontal,
        itemCount: journeys.length,
        itemBuilder: (context, index) {
          final tour = journeys[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour)),
            ),
            child: Container(
              width: 240.w,
              margin: EdgeInsets.only(right: 20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Image.network(
                          tour.imageUrl,
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180.h,
                            color: AppColors.neutral200,
                            child: const Icon(Icons.image_not_supported, color: AppColors.neutral500),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Icon(Icons.bookmark_border, color: Colors.white, size: 28.sp),
                      ),
                      Positioned(
                        bottom: 12.h,
                        left: 12.w,
                        child: Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 14.sp)),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '1247 likes',
                              style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tour.title, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppColors.neutral500),
                            SizedBox(width: 4.w),
                            Text(
                              tour.startDate != null 
                                ? DateFormat('MMM dd, yyyy').format(DateTime.parse(tour.startDate!)) 
                                : 'Jan 30, 2020', 
                              style: AppTypography.caption.copyWith(color: AppColors.neutral500)
                            ),
                            SizedBox(width: 12.w),
                            const Icon(Icons.access_time, size: 14, color: AppColors.neutral500),
                            SizedBox(width: 4.w),
                            Text(tour.duration ?? '3 days', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text('\$${tour.price.toStringAsFixed(2)}', style: AppTypography.h3.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestGuides(List<User> guides) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.75,
      ),
      itemCount: guides.take(4).length,
      itemBuilder: (context, index) {
        final guide = guides[index];
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
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.neutral200,
                          child: const Icon(Icons.person, color: AppColors.neutral500),
                        ),
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
      },
    );
  }

  Widget _buildTopExperiences(List<Experience> experiences) {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 24.w),
        scrollDirection: Axis.horizontal,
        itemCount: experiences.length,
        itemBuilder: (context, index) {
          final exp = experiences[index];
          return Container(
            width: 140.w,
            margin: EdgeInsets.only(right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        exp.imageUrl,
                        height: 160.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160.h,
                          color: AppColors.neutral200,
                          child: const Icon(Icons.image_not_supported, color: AppColors.neutral500),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundImage: NetworkImage(exp.authorImageUrl),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(exp.title, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold), maxLines: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedTours(List<Tour> tours) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tours.length,
      itemBuilder: (context, index) {
        final tour = tours[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour)),
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
                  child: Image.network(
                    tour.imageUrl,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160.h,
                      color: AppColors.neutral200,
                      child: const Icon(Icons.image_not_supported, color: AppColors.neutral500),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tour.title, style: AppTypography.subtitle1, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(tour.duration ?? '3 days', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text('\$${tour.price.toStringAsFixed(2)}', style: AppTypography.h3.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTravelNews(List<TravelNews> newsList) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(news.title, style: AppTypography.subtitle1),
            Text(news.publishedDate, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                news.imageUrl,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180.h,
                  color: AppColors.neutral200,
                  child: const Icon(Icons.image_not_supported, color: AppColors.neutral500),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        );
      },
    );
  }
}
