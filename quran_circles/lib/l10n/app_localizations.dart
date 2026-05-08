import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appName => 'حلقات القرآن';
  String get dashboard => 'لوحة التحكم';
  String get circles => 'الحلقات';
  String get students => 'الطلاب';
  String get memorization => 'الحفظ';
  String get reports => 'التقارير';
  String get messages => 'الرسائل';
  String get settings => 'الإعدادات';
  String get login => 'دخول';
  String get logout => 'تسجيل خروج';
  String get add => 'إضافة';
  String get save => 'حفظ';
  String get cancel => 'إلغاء';
  String get delete => 'حذف';
  String get search => 'بحث';
  String get noData => 'لا توجد بيانات';
  String get loading => 'جاري التحميل...';
  String get errorOccurred => 'حدث خطأ';
  String get syncStatus => 'حالة المزامنة';
  String get allSynced => 'جميع الأجهزة متزامنة';
  String get studentName => 'اسم الطالب';
  String get phone => 'رقم الجوال';
  String get attendance => 'الحضور';
  String get present => 'حاضر';
  String get absent => 'غائب';
  String get late => 'متأخر';
  String get excused => 'معذور';
  String get newCircle => 'حلقة جديدة';
  String get newMessage => 'رسالة جديدة';
  String get backup => 'نسخ احتياطي';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
