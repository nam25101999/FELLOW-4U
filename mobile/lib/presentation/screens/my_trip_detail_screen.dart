import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'payment_screen.dart';

class MyTripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;
  const MyTripDetailScreen({super.key, required this.trip});

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
        title: Text('Trip Detail', style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.neutral700),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    trip['imageUrl'] ?? 'http://127.0.0.1:8080/uploads/location/images.jpg',
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      Text(' ${trip['location']}', style: AppTypography.caption.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                Positioned(
                  top: 80.h,
                  right: 24.w,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 35.r,
                      backgroundImage: NetworkImage(trip['guideAvatar'] ?? 'https://ui-avatars.com/api/?name=Emmy'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildDetailItem('Date', trip['date']),
            _buildDetailItem('Time', trip['time']),
            _buildDetailItem('Guide', trip['guide'], isGuide: true),
            _buildDetailItem('Number of Travelers', '${trip['travelers'] ?? 2}'),
            SizedBox(height: 16.h),
            Text('Attractions', style: AppTypography.subtitle2),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _buildAttractionTag('Ho Guom'),
                _buildAttractionTag('Ho Hoan Kiem'),
                _buildAttractionTag('Pho 12 Pho Kim Ma'),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fee', style: AppTypography.h3),
                Text('\$${trip['fee'] ?? '20.00'}', style: AppTypography.h3.copyWith(color: AppColors.primary)),
              ],
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: _buildOutlineButton('Chat', Icons.chat_bubble_outline),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildOutlineButton('Pay', Icons.payment, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen()));
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isGuide = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body2.copyWith(color: AppColors.neutral700)),
          Text(
            value,
            style: AppTypography.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: isGuide ? AppColors.primary : AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionTag(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral100),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 14, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(name, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(String label, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            SizedBox(width: 8.w),
            Text(label, style: AppTypography.button.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
