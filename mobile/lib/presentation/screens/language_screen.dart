import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/locale_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
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
        title: Text(l10n.languages, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          _buildLanguageItem(
            context,
            'English',
            const Locale('en'),
            localeProvider.locale.languageCode == 'en',
            localeProvider,
          ),
          Divider(height: 1, color: AppColors.neutral200),
          _buildLanguageItem(
            context,
            'Tiếng Việt',
            const Locale('vi'),
            localeProvider.locale.languageCode == 'vi',
            localeProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String title, Locale locale, bool isSelected, LocaleProvider provider) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.body1),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        provider.setLocale(locale);
      },
    );
  }
}
