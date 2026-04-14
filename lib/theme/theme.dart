import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1976D2); 
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF64B5F6); 
  static const Color backgroundColor = Color(0xFFF5F5F5); 
  static const Color surfaceColor = Colors.white; 
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color textPrimaryColor = Color(0xFF212121); 
  static const Color textSecondaryColor = Color(0xFF757575); 
  static const Color dividerColor = Color(0xFFEEEEEE); 

  /// Returns the appropriate font family based on locale.
  /// Arabic → IBMPlexSansArabic, English → Poppins.
  static String getFontFamily(Locale locale) {
    return locale.languageCode == 'ar' ? 'IBMPlexSansArabic' : 'Poppins';
  }

  // ─── Text styles (use these with the fontFamily parameter or via theme) ───

  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  /// Generates the light theme with the correct font family for the given locale.
  static ThemeData lightTheme([Locale locale = const Locale('en')]) {
    final fontFamily = getFontFamily(locale);

    final heading = headingStyle.copyWith(fontFamily: fontFamily);
    final subheading = subheadingStyle.copyWith(fontFamily: fontFamily);
    final body = bodyStyle.copyWith(fontFamily: fontFamily);
    final bodySmall = bodySmallStyle.copyWith(fontFamily: fontFamily);
    final buttonText = buttonTextStyle.copyWith(fontFamily: fontFamily);

    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      fontFamily: fontFamily,
      textTheme: TextTheme(
        displayLarge: heading,
        displayMedium: subheading,
        bodyLarge: body,
        bodyMedium: bodySmall,
        labelLarge: buttonText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText.copyWith(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        hintStyle: bodySmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}