import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/auth_service.dart';
import 'package:virtual_clinic_system/firebase_options.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'theme/theme.dart';
import 'screens/auth/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode("en");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserId?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Virtual Clinic System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoadingScreen(),
      ),
    );
  }
}
