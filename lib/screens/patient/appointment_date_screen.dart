import 'package:flutter/material.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../components/date_picker_component.dart';
import '../../theme/theme.dart';
import 'appointment_time_screen.dart';

class AppointmentDateScreen extends StatefulWidget {
  final String appointmentType;

  const AppointmentDateScreen({
    Key? key,
    required this.appointmentType,
  }) : super(key: key);

  @override
  State<AppointmentDateScreen> createState() => _AppointmentDateScreenState();
}

class _AppointmentDateScreenState extends State<AppointmentDateScreen> {
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    // Initialize with tomorrow as default
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    
    // Ensure the selected date is not on a weekend
    if (_selectedDate.weekday == 6) { // Saturday
      _selectedDate = _selectedDate.add(const Duration(days: 2));
    } else if (_selectedDate.weekday == 7) { // Sunday
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    }
  }
  
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }
  
  void _proceedToNextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentTimeScreen(
          appointmentType: widget.appointmentType,
          appointmentDate: _selectedDate,
        ),
      ),
    );
  }

  String _getAppointmentTypeTitle() {
    switch (widget.appointmentType) {
      case 'virtual':
        return 'Virtual Appointment';
      case 'physical':
        return 'Physical Appointment';
      case 'vaccination':
        return 'Vaccination';
      default:
        return 'Appointment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppointmentTypeTitle(),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a preferred date for your appointment',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: DatePickerComponent(
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  onDateSelected: _onDateSelected,
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: 'Continue',
                onPressed: _proceedToNextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}