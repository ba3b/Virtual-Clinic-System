import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/auth_service.dart';
import 'package:virtual_clinic_system/firebase_options.dart';
import 'package:virtual_clinic_system/localization/app_localizations.dart';
import 'package:virtual_clinic_system/localization/locale_provider.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'theme/theme.dart';
import 'screens/auth/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load saved language preference before building the app.
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  // Set Firebase Auth language to match the saved locale.
  FirebaseAuth.instance.setLanguageCode(localeProvider.locale.languageCode);

  runApp(MyApp(localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  final LocaleProvider localeProvider;

  const MyApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        StreamProvider<UserId?>.value(
          value: AuthService().user,
          initialData: null,
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'Virtual Clinic System',
            debugShowCheckedModeBanner: false,
            // ─── Locale ───
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            // ─── Localization delegates ───
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // ─── Theme (font switches based on locale) ───
            theme: AppTheme.lightTheme(localeProvider.locale),
            home: const LoadingScreen(),
          );
        },
      ),
    );
  }
}
