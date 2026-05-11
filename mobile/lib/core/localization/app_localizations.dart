import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'languages': 'Languages',
      'notifications': 'Notifications',
      'payment': 'Payment',
      'privacyPolicy': 'Privacy & Policies',
      'feedback': 'Feedback',
      'usage': 'Usage',
      'signOut': 'Sign out',
      'editProfile': 'Edit Profile',
      'myPhotos': 'My Photos',
      'myJourneys': 'My Journeys',
      'save': 'SAVE',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'password': 'Password',
      'changePassword': 'Change Password'
    },
    'vi': {
      'settings': 'Cài đặt',
      'languages': 'Ngôn ngữ',
      'notifications': 'Thông báo',
      'payment': 'Thanh toán',
      'privacyPolicy': 'Quyền riêng tư & Chính sách',
      'feedback': 'Phản hồi',
      'usage': 'Cách sử dụng',
      'signOut': 'Đăng xuất',
      'editProfile': 'Chỉnh sửa hồ sơ',
      'myPhotos': 'Ảnh của tôi',
      'myJourneys': 'Hành trình của tôi',
      'save': 'LƯU',
      'firstName': 'Tên',
      'lastName': 'Họ',
      'password': 'Mật khẩu',
      'changePassword': 'Đổi mật khẩu'
    },
  };

  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get languages => _localizedValues[locale.languageCode]!['languages']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get payment => _localizedValues[locale.languageCode]!['payment']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy']!;
  String get feedback => _localizedValues[locale.languageCode]!['feedback']!;
  String get usage => _localizedValues[locale.languageCode]!['usage']!;
  String get signOut => _localizedValues[locale.languageCode]!['signOut']!;
  String get editProfile => _localizedValues[locale.languageCode]!['editProfile']!;
  String get myPhotos => _localizedValues[locale.languageCode]!['myPhotos']!;
  String get myJourneys => _localizedValues[locale.languageCode]!['myJourneys']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get firstName => _localizedValues[locale.languageCode]!['firstName']!;
  String get lastName => _localizedValues[locale.languageCode]!['lastName']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get changePassword => _localizedValues[locale.languageCode]!['changePassword']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
