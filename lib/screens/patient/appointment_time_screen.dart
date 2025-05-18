import 'package:flutter/material.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import 'appointment_confirmation_screen.dart';

class AppointmentTimeScreen extends StatefulWidget {
  final String appointmentType;
  final DateTime appointmentDate;
  final String? department;
  final String? vaccinationType;

  const AppointmentTimeScreen({
    Key? key,
    required this.appointmentType,
    required this.appointmentDate,
    this.department,
    this.vaccinationType,
  }) : super(key: key);

  @override
  State<AppointmentTimeScreen> createState() => _AppointmentTimeScreenState();
}

class _AppointmentTimeScreenState extends State<AppointmentTimeScreen> {
  String? _selectedTimeSlot;

  // This would ideally be fetched from an API based on the selected date and department/vaccination
  final List<String> _availableTimeSlots = [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
  ];

  void _onTimeSlotSelected(String timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  void _proceedToBookAppointment() {
    if (_selectedTimeSlot != null) {
      // Construct the appointment data
      final appointmentData = {
        'appointmentType': widget.appointmentType,
        'appointmentDate': widget.appointmentDate,
        'appointmentTime': _selectedTimeSlot,
        if (widget.department != null) 'department': widget.department,
        if (widget.vaccinationType != null) 'vaccinationType': widget.vaccinationType,
      };

      // Navigate to confirmation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentConfirmationScreen(
            appointmentData: appointmentData,
          ),
        ),
      );
    }
  }

  String _getScreenTitle() {
    if (widget.appointmentType == 'vaccination') {
      return 'Vaccination: ${widget.vaccinationType}';
    } else if (widget.appointmentType == 'virtual') {
      return 'Virtual: ${widget.department}';
    } else {
      return 'Physical: ${widget.department}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getScreenTitle(),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Time',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose an available time slot for your appointment',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Date: ${widget.appointmentDate.day}/${widget.appointmentDate.month}/${widget.appointmentDate.year}',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _availableTimeSlots.length,
                  itemBuilder: (context, index) {
                    final timeSlot = _availableTimeSlots[index];
                    final bool isSelected = timeSlot == _selectedTimeSlot;

                    return InkWell(
                      onTap: () => _onTimeSlotSelected(timeSlot),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            timeSlot,
                            style: AppTheme.bodyStyle.copyWith(
                              color:
                                  isSelected ? Colors.white : AppTheme.textPrimaryColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: 'Book Appointment',
                onPressed: _selectedTimeSlot != null ? _proceedToBookAppointment : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}