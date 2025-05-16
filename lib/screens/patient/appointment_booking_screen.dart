import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import 'appointment_date_screen.dart';
import 'appointment_type_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String? initialType;

  const AppointmentBookingScreen({
    Key? key, 
    this.initialType,
  }) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  @override
  void initState() {
    super.initState();
    
    // If an initial type is provided, navigate directly to date selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialType != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDateScreen(
              appointmentType: widget.initialType!,
            ),
          ),
        );
      } else {
        // Otherwise, navigate to type selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AppointmentTypeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Book Appointment',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}