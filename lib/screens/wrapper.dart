import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/screens/auth/intro_screen.dart';
import 'package:virtual_clinic_system/screens/patient/patient_home_screen.dart';
import 'package:virtual_clinic_system/screens/doctor/doctor_home_screen.dart';
import 'package:virtual_clinic_system/screens/staff/staff_home_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isLoading = true;
  Widget? _destination;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserId?>(context);

    if (user == null) {
      setState(() {
        _isLoading = false;
        _destination = const IntroScreen();
      });
    } else {
      _loadUserData(user);
    }
  }

  Future<void> _loadUserData(UserId user) async {
    try {
      UserModel userModel = await DatabaseService(uid: user.uid).getUserDetails(user.uid);
      
      Widget destinationScreen;
      
      if (userModel is PatientModel) {
        destinationScreen = const PatientHomeScreen();
      } else if (userModel is DoctorModel) {
        destinationScreen = const DoctorHomeScreen();
      } else if (userModel is StaffModel) {
        destinationScreen = const StaffHomeScreen();
      } else {
        destinationScreen = const PatientHomeScreen();
        debugPrint('Warning: Unknown user type detected!');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _destination = destinationScreen;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _destination = const IntroScreen();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _destination ?? const IntroScreen();
  }
}