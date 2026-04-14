import 'package:flutter/material.dart';
import 'translations/en.dart';
import 'translations/ar.dart';

/// Main localization class for the Virtual Clinic System.
///
/// Usage in any widget:
/// ```dart
/// final loc = AppLocalizations.of(context);
/// Text(loc.translate('login'))  // or loc.tr('login')
/// ```
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  /// Convenience accessor from any widget's BuildContext.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Whether the current locale is Arabic (RTL).
  bool get isArabic => locale.languageCode == 'ar';

  /// Load the translation map for the current locale.
  Future<void> load() async {
    _localizedStrings =
        locale.languageCode == 'ar' ? arTranslations : enTranslations;
  }

  /// Translate a key. Returns the key itself if not found (useful for debugging).
  String translate(String key) => _localizedStrings[key] ?? key;

  /// Shorthand for [translate].
  String tr(String key) => translate(key);

  /// Translate a key with positional argument replacement.
  /// Replaces `{0}`, `{1}`, etc. with the provided args.
  /// Example: `trArgs('welcome_user', ['Mohammed'])` → "Welcome, Mohammed!"
  /// The translation string should use `{0}` as placeholder.
  String trArgs(String key, List<String> args) {
    String result = translate(key);
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('{$i}', args[i]);
    }
    return result;
  }

  /// The localization delegate used in [MaterialApp.localizationsDelegates].
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
