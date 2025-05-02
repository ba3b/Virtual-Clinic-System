import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/screens/auth/intro_screen.dart';
import 'package:virtual_clinic_system/screens/patient/patient_home_screen.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId?>(context);
    if(user == null){
      return const IntroScreen();
    }
    else {
      print(user.uid);
      //TODO: Add logic to check user type and navigate to the appropriate screen by UserType
      return const PatientHomeScreen();
    }
  }
}