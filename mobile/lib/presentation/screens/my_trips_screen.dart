import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/services/explore_service.dart';
import '../../data/services/booking_service.dart';
import 'tour_detail_screen.dart';
import 'create_trip_screen.dart';
import 'my_trip_detail_screen.dart';
import 'payment_screen.dart';
import '../widgets/common/dynamic_page_header.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ExploreService _exploreService = ExploreService();
  final BookingService _bookingService = BookingService();
  
  List<Tour> _wishList = [];
  List<Booking> _currentBookings = [];
  List<Booking> _nextBookings = [];
  List<Booking> _pastBookings = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final exploreData = await _exploreService.getExploreData();
      final current = await _bookingService.getBookingsByStatus('CURRENT');
      final next = await _bookingService.getBookingsByStatus('NEXT');
      final past = await _bookingService.getBookingsByStatus('PAST');
      final likedTours = await _exploreService.getLikedTours();

      if (!mounted) return;
      setState(() {
        _wishList = likedTours;
        _currentBookings = current;
        _nextBookings = next;
        _pastBookings = past;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching trips: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentTrips(),
                _buildNextTrips(),
                _buildPastTrips(),
                _buildWishList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateTripScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return DynamicPageHeader(
      title: 'My Trips',
      subtitle: 'Your journey awaits',
      imageUrl: DynamicPageHeader.getImageForLocation('Da Nang'),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.neutral500,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.primary,
        ),
        tabs: const [
          Tab(text: 'Current Trips'),
          Tab(text: 'Next Trips'),
          Tab(text: 'Past Trips'),
          Tab(text: 'Wish List'),
        ],
      ),
    );
  }

  Widget _buildCurrentTrips() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_currentBookings.isEmpty) return const Center(child: Text('No current trips'));
    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: _currentBookings.length,
      itemBuilder: (context, index) => _buildTripCard(_currentBookings[index], showMarkFinished: true),
    );
  }

  Widget _buildNextTrips() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_nextBookings.isEmpty) return const Center(child: Text('No upcoming trips'));
    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: _nextBookings.length,
      itemBuilder: (context, index) => _buildTripCard(_nextBookings[index], buttons: ['Detail', 'Chat', 'Pay']),
    );
  }

  Widget _buildPastTrips() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_pastBookings.isEmpty) return const Center(child: Text('No past trips'));
    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: _pastBookings.length,
      itemBuilder: (context, index) => _buildTripCard(_pastBookings[index], buttons: ['Detail']),
    );
  }

  Widget _buildWishList() {
    if (_wishList.isEmpty) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: _wishList.length,
      itemBuilder: (context, index) {
        final tour = _wishList[index];
        return _buildWishListCard(tour);
      },
    );
  }

  Widget _buildTripCard(
    Booking booking, {
    bool showMarkFinished = false,
    List<String>? buttons,
    String? status,
  }) {
    final tripData = {
      'title': booking.tripTitle,
      'location': booking.location,
      'date': booking.date,
      'time': booking.timeSlot,
      'guide': booking.guideName,
      'guideAvatar': booking.guideAvatarUrl,
      'imageUrl': DynamicPageHeader.getImageForLocation(booking.location),
      'travelers': booking.travelers,
      'fee': booking.totalFee.toStringAsFixed(2)
    };

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyTripDetailScreen(trip: tripData))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Image.network(
                    tripData['imageUrl'] as String,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160.h,
                      width: double.infinity,
                      color: AppColors.primary.withOpacity(0.15),
                      child: Icon(Icons.landscape_outlined, size: 48.sp, color: AppColors.primary.withOpacity(0.4)),
                    ),
                  ),
                ),
                if (showMarkFinished)
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20.r)),
                      child: Row(
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 16),
                          SizedBox(width: 4.w),
                          Text('Mark Finished', style: AppTypography.caption.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                if (status != null)
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20.r)),
                      child: Text(status, style: AppTypography.caption.copyWith(color: Colors.white)),
                    ),
                  ),
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      SizedBox(width: 4.w),
                      Text(tripData['location'] as String, style: AppTypography.caption.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tripData['title'] as String, style: AppTypography.subtitle1),
                        SizedBox(height: 8.h),
                        _buildInfoRow(Icons.calendar_today, tripData['date'] as String),
                        _buildInfoRow(Icons.access_time, tripData['time'] as String),
                        _buildInfoRow(Icons.person, tripData['guide'] as String),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: CircleAvatar(radius: 35.r, backgroundImage: NetworkImage(tripData['guideAvatar'] as String)),
                  ),
                ],
              ),
            ),
            if (buttons != null)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Row(
                  children: buttons.map((b) => _buildActionButton(b, tripData)).toList(),
                ),
              ),
            if (showMarkFinished)
               Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Row(children: [_buildActionButton('Detail', tripData)],),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.neutral300),
          SizedBox(width: 8.w),
          Text(text, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Map<String, dynamic> tripData) {
    IconData icon;
    if (label == 'Detail') icon = Icons.info_outline;
    else if (label == 'Chat') icon = Icons.chat_bubble_outline;
    else if (label == 'Pay') icon = Icons.payment;
    else icon = Icons.info;

    return GestureDetector(
      onTap: () {
        if (label == 'Detail') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyTripDetailScreen(trip: tripData)));
        } else if (label == 'Pay') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen()));
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 14),
            SizedBox(width: 4.w),
            Text(label, style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWishListCard(Tour tour) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour))),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Image.network(tour.imageUrl, height: 160.h, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tour.title, style: AppTypography.subtitle1),
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 14)),
                      SizedBox(width: 8.w),
                      Text('1247 likes', style: AppTypography.caption),
                      const Spacer(),
                      Text('\$${tour.price.toStringAsFixed(2)}', style: AppTypography.subtitle1.copyWith(color: AppColors.primary)),
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
