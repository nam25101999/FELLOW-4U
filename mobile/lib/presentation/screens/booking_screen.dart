import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import 'add_attraction_screen.dart';
import '../widgets/common/success_dialog.dart';

class BookingScreen extends StatefulWidget {
  final User guide;
  const BookingScreen({super.key, required this.guide});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _travelers = 1;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeFromController = TextEditingController();
  final TextEditingController _timeToController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Danang');

  // Dummy attractions for the list
  final List<Map<String, dynamic>> _selectedAttractions = [
    {
      'name': 'Dragon Bridge',
      'imageUrl': 'http://127.0.0.1:8080/uploads/location/images.jpg',
      'isSelected': true,
    },
    {
      'name': 'Cham Museum',
      'imageUrl': 'http://127.0.0.1:8080/uploads/location/tải xuống (7).jpg',
      'isSelected': true,
    },
    {
      'name': 'My Khe Beach',
      'imageUrl': 'http://127.0.0.1:8080/uploads/location/images (1).jpg',
      'isSelected': true,
    },
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
        title: Text('Trip Information', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField('Date', 'mm/dd/yy', _dateController, Icons.calendar_today),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(child: _buildInputField('Time', 'From', _timeFromController, Icons.access_time)),
                SizedBox(width: 16.w),
                Expanded(child: _buildInputField('', 'To', _timeToController, Icons.access_time)),
              ],
            ),
            SizedBox(height: 24.h),
            _buildInputField('City', 'City', _cityController, Icons.location_on),
            SizedBox(height: 24.h),
            _buildTravelersSection(),
            SizedBox(height: 32.h),
            _buildAttractionsSection(),
            SizedBox(height: 48.h),
            ElevatedButton(
              onPressed: () {
                SuccessDialog.show(
                  context,
                  title: 'Booking Successful!',
                  message: 'Your trip request has been sent to the guide.\nPlease wait for confirmation.',
                  onConfirm: () => Navigator.pop(context),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text('DONE', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppTypography.subtitle2),
          SizedBox(height: 8.h),
        ],
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.neutral300, size: 20),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral200)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of travelers', style: AppTypography.subtitle2),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildCounterButton(Icons.arrow_drop_down, () {
              if (_travelers > 1) setState(() => _travelers--);
            }),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text('$_travelers', style: AppTypography.h3),
            ),
            _buildCounterButton(Icons.arrow_drop_up, () {
              setState(() => _travelers++);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _buildAttractionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attractions', style: AppTypography.subtitle2),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.2,
          ),
          itemCount: _selectedAttractions.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildAddButton();
            final attraction = _selectedAttractions[index - 1];
            return _buildAttractionCard(attraction);
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddAttractionScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text('Add New', style: AppTypography.caption.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionCard(Map<String, dynamic> attraction) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            attraction['imageUrl'],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.black26,
          ),
        ),
        Positioned(
          bottom: 8.h,
          left: 8.w,
          right: 8.w,
          child: Text(
            attraction['name'],
            style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (attraction['isSelected'])
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }
}
