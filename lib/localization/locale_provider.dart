import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the current app locale and persists the user's language choice.
///
/// Provided at the root of the widget tree via [ChangeNotifierProvider].
/// Any widget can read the current locale or switch languages:
///
/// ```dart
/// // Read
/// final isArabic = context.read<LocaleProvider>().isArabic;
///
/// // Switch
/// context.read<LocaleProvider>().setLocale(const Locale('ar'));
/// ```
class LocaleProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';

  Locale _locale = const Locale('en');

  /// The current app locale.
  Locale get locale => _locale;

  /// Whether the current locale is Arabic.
  bool get isArabic => _locale.languageCode == 'ar';

  /// Load the previously saved locale from SharedPreferences.
  /// Call this once during app startup (before runApp or in main).
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey) ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  /// Switch to a new locale and persist the choice.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }

  /// Toggle between English and Arabic.
  Future<void> toggleLocale() async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}
