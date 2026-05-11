import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/services/profile_service.dart';
import '../widgets/common/success_dialog.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> with SingleTickerProviderStateMixin {
  final _profileService = ProfileService();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  late TabController _tabController;
  String _cardType = 'VISA';
  String _walletProvider = 'MOMO';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _saveMethod() async {
    if (_numberController.text.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      if (_tabController.index == 0) {
        // Saving Card
        String maskedNumber = '**** ${_numberController.text.substring(_numberController.text.length - 4)}';
        await _profileService.addCard({
          'name': '$_cardType $maskedNumber',
          'identifier': maskedNumber,
          'provider': _cardType,
          'type': 'CARD',
        });
      } else {
        // Saving Wallet
        await _profileService.addCard({
          'name': '$_walletProvider Wallet',
          'identifier': _numberController.text,
          'provider': _walletProvider,
          'type': 'WALLET',
        });
      }

      if (mounted) {
        SuccessDialog.show(
          context,
          title: 'Thành công',
          message: 'Phương thức thanh toán đã được liên kết.',
          onConfirm: () => Navigator.pop(context, true),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: Text('Add Payment Method', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral500,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'BANK CARD'),
            Tab(text: 'E-WALLET'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCardForm(),
          _buildWalletForm(),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          _buildTextField('Card Holder Name', _holderController, hint: 'E.g. NAM NGUYEN'),
          SizedBox(height: 16.h),
          _buildTextField('Card Number', _numberController, hint: '16-digit number', keyboardType: TextInputType.number),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildTextField('Expiry Date', _expiryController, hint: 'MM/YY')),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildDropdown('Card Type', _cardType, ['VISA', 'MASTERCARD'], (val) => setState(() => _cardType = val!)),
              ),
            ],
          ),
          const Spacer(),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildWalletForm() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          _buildDropdown('Wallet Provider', _walletProvider, ['MOMO', 'ZALOPAY', 'VNPAY', 'SHOPEEPAY'], (val) => setState(() => _walletProvider = val!)),
          SizedBox(height: 16.h),
          _buildTextField('Phone Number', _numberController, hint: 'Linked phone number', keyboardType: TextInputType.phone),
          const Spacer(),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : _saveMethod,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('LINK METHOD', style: AppTypography.button.copyWith(color: Colors.white)),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body2.copyWith(color: AppColors.neutral500)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.neutral200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body2.copyWith(color: AppColors.neutral500)),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          items: items.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
