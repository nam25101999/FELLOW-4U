import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/profile_service.dart';
import 'add_card_screen.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final ProfileService _profileService = ProfileService();
  List<dynamic> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final cards = await _profileService.getCards();
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCard(String id) async {
    try {
      await _profileService.deleteCard(id);
      _loadCards();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.payment, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved Cards', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                if (_cards.isEmpty)
                  const Expanded(child: Center(child: Text('Chưa có thẻ nào được lưu.')))
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _cards.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final method = _cards[index];
                        return _buildCardItem(
                          method['id'],
                          method['name'], 
                          method['identifier'], 
                          method['provider'],
                          method['type']
                        );
                      },
                    ),
                  ),
                SizedBox(height: 32.h),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddCardScreen()),
                    );
                    if (result == true) {
                      _loadCards();
                    }
                  },
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: Text('Add New Payment Method', style: AppTypography.button.copyWith(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCardItem(String id, String title, String subtitle, String provider, String type) {
    IconData iconData = Icons.credit_card;
    Color iconColor = AppColors.primary;

    if (type == 'WALLET') {
      iconData = Icons.account_balance_wallet;
      switch (provider) {
        case 'MOMO':
          iconColor = const Color(0xFFA50064); // MoMo Pink
          break;
        case 'ZALOPAY':
          iconColor = const Color(0xFF0068FF); // ZaloPay Blue
          break;
        default:
          iconColor = Colors.orange;
      }
    } else {
      iconColor = provider == 'VISA' ? Colors.blue : Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor, size: 32.w),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.neutral500),
            onSelected: (val) {
              if (val == 'delete') {
                _deleteCard(id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Remove Method', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
