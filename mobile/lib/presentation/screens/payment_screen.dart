import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/common/success_dialog.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

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
        title: Text('Payment', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildCardInfoStep(),
                _buildCheckOutStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 48.w),
      child: Row(
        children: [
          _buildStepCircle(0),
          Expanded(child: Container(height: 1.h, color: AppColors.neutral100, margin: EdgeInsets.symmetric(horizontal: 8.w))),
          _buildStepCircle(1),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.neutral200,
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(color: AppColors.neutral300),
          ),
          child: isActive ? Icon(Icons.check, color: Colors.white, size: 14.w) : null,
        ),
        SizedBox(height: 8.h),
        Text(
          step == 0 ? 'Payment Method' : 'Preview & Check out',
          style: AppTypography.caption.copyWith(
            color: isActive ? AppColors.primary : AppColors.neutral500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCardInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: AppColors.neutral500),
              SizedBox(width: 12.w),
              Text('Card Information', style: AppTypography.subtitle1),
            ],
          ),
          SizedBox(height: 32.h),
          _buildPaymentInput('Card Holder\'s Name', 'Card Holder\'s Name'),
          SizedBox(height: 24.h),
          _buildPaymentInput('Card Number', '0000 0000 0000 0000'),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(child: _buildPaymentInput('Expiration Date', 'mm/yy')),
              SizedBox(width: 24.w),
              Expanded(child: _buildPaymentInput('CVV', '000')),
            ],
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: Text('NEXT', style: AppTypography.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripSummaryCard(),
          SizedBox(height: 32.h),
          _buildPriceRow('Total', '\$20.00', isMain: true),
          _buildPriceRow('50% payment', '\$10.00', isSub: true),
          Text('(You just need to pay upfront 50%)', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: () {
              SuccessDialog.show(
                context,
                title: 'Success!',
                message: 'Thanks! Check out successfully.\nEnjoy your trip!',
                onConfirm: () => Navigator.pop(context),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: Text('CHECK OUT', style: AppTypography.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.subtitle2),
        SizedBox(height: 8.h),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body2.copyWith(color: AppColors.neutral200),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neutral100)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildTripSummaryCard() {
    return Container(
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
                  'http://127.0.0.1:8080/uploads/location/images.jpg',
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8.h,
                left: 8.w,
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 12),
                    Text(' Hanoi, Vietnam', style: AppTypography.caption.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: CircleAvatar(
                  radius: 24.r,
                  backgroundImage: const NetworkImage('https://ui-avatars.com/api/?name=Emmy'),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildSummaryRow('Date', 'Feb 2, 2020'),
                _buildSummaryRow('Time', '8:00AM - 10:00AM'),
                _buildSummaryRow('Guide', 'Emmy', isGuide: true),
                _buildSummaryRow('Number of Travelers', '2'),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    _buildAttractionTag('Ho Guom'),
                    _buildAttractionTag('Ho Hoan Kiem'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGuide = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.neutral700)),
          Text(value, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: isGuide ? AppColors.primary : null)),
        ],
      ),
    );
  }

  Widget _buildAttractionTag(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 10, color: AppColors.primary),
          Text(' $name', style: TextStyle(fontSize: 10.sp)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isMain = false, bool isSub = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isMain ? AppTypography.h3 : AppTypography.body2),
          Text(price, style: (isMain ? AppTypography.h3 : AppTypography.body2).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
