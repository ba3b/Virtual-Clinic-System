import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../components/time_slot_selector.dart';
import '../../theme/theme.dart';
import 'appointment_summary_screen.dart';

class AppointmentTimeScreen extends StatefulWidget {
  final String appointmentType;
  final DateTime appointmentDate;

  const AppointmentTimeScreen({
    Key? key,
    required this.appointmentType,
    required this.appointmentDate,
  }) : super(key: key);

  @override
  State<AppointmentTimeScreen> createState() => _AppointmentTimeScreenState();
}

class _AppointmentTimeScreenState extends State<AppointmentTimeScreen> {
  String? _selectedTimeId;
  final List<TimeSlot> _morningSlots = [];
  final List<TimeSlot> _afternoonSlots = [];
  final List<TimeSlot> _eveningSlots = [];

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    // Generate morning slots (8:00 AM - 12:00 PM)
    for (int hour = 8; hour < 12; hour++) {
      final id = '$hour:00';
      final time = hour < 12
          ? '$hour:00 AM'
          : '${hour - 12 == 0 ? 12 : hour - 12}:00 PM';
      
      // Randomly set some slots as unavailable for demo purposes
      final isAvailable = DateTime.now().millisecondsSinceEpoch % (hour + 1) != 0;
      
      _morningSlots.add(TimeSlot(
        id: id,
        time: time,
        isAvailable: isAvailable,
      ));
      
      // Add half-hour slots
      final halfHourId = '$hour:30';
      final halfHourTime = hour < 12
          ? '$hour:30 AM'
          : '${hour - 12 == 0 ? 12 : hour - 12}:30 PM';
      
      final halfHourAvailable = DateTime.now().millisecondsSinceEpoch % (hour + 2) != 0;
      
      _morningSlots.add(TimeSlot(
        id: halfHourId,
        time: halfHourTime,
        isAvailable: halfHourAvailable,
      ));
    }
    
    // Generate afternoon slots (12:00 PM - 4:00 PM)
    for (int hour = 12; hour < 16; hour++) {
      final id = '$hour:00';
      final time = hour < 12
          ? '$hour:00 AM'
          : '${hour - 12 == 0 ? 12 : hour - 12}:00 PM';
      
      final isAvailable = DateTime.now().millisecondsSinceEpoch % (hour + 1) != 0;
      
      _afternoonSlots.add(TimeSlot(
        id: id,
        time: time,
        isAvailable: isAvailable,
      ));
      
      // Add half-hour slots
      final halfHourId = '$hour:30';
      final halfHourTime = hour < 12
          ? '$hour:30 AM'
          : '${hour - 12 == 0 ? 12 : hour - 12}:30 PM';
      
      final halfHourAvailable = DateTime.now().millisecondsSinceEpoch % (hour + 2) != 0;
      
      _afternoonSlots.add(TimeSlot(
        id: halfHourId,
        time: halfHourTime,
        isAvailable: halfHourAvailable,
      ));
    }
    
    // Generate evening slots (4:00 PM - 8:00 PM)
    for (int hour = 16; hour < 20; hour++) {
      final id = '$hour:00';
      final time = hour < 12
          ? '$hour:00 AM'
          : '${hour - 12 == 0 ? 12 : hour - 12}:00 PM';
      
      final isAvailable = DateTime.now().millisecondsSinceEpoch % (hour + 1) != 0;
      
      _eveningSlots.add(TimeSlot(
        id: id,
        time: time,
        isAvailable: isAvailable,
      ));
      
      // Add half-hour slots
      final halfHourId = '$hour:30';
      final halfHourTime = hour < 12
          ? '$hour:30 AM'
          : '${hour - 12 == 0 ? 12 : hour - 12}:30 PM';
      
      final halfHourAvailable = DateTime.now().millisecondsSinceEpoch % (hour + 2) != 0;
      
      _eveningSlots.add(TimeSlot(
        id: halfHourId,
        time: halfHourTime,
        isAvailable: halfHourAvailable,
      ));
    }
  }

  void _onTimeSelected(TimeSlot timeSlot) {
    setState(() {
      _selectedTimeId = timeSlot.id;
    });
  }

  void _proceedToNextStep() {
    if (_selectedTimeId != null) {
      final selectedTimeSlot = [
        ..._morningSlots,
        ..._afternoonSlots,
        ..._eveningSlots,
      ].firstWhere((slot) => slot.id == _selectedTimeId);
      
      // Parse time from the slot
      final String timeStr = selectedTimeSlot.time;
      final bool isPM = timeStr.contains('PM');
      final List<String> timeParts = timeStr
          .replaceAll(' AM', '')
          .replaceAll(' PM', '')
          .split(':');
      
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      
      // Convert to 24-hour format
      if (isPM && hour < 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }
      
      // Create appointment date time
      final DateTime appointmentDateTime = DateTime(
        widget.appointmentDate.year,
        widget.appointmentDate.month,
        widget.appointmentDate.day,
        hour,
        minute,
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentSummaryScreen(
            appointmentType: widget.appointmentType,
            appointmentDateTime: appointmentDateTime,
          ),
        ),
      );
    }
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
                'Select Time',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(widget.appointmentDate),
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning',
                        style: AppTheme.subheadingStyle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TimeSlotSelector(
                        timeSlots: _morningSlots,
                        onTimeSelected: _onTimeSelected,
                        selectedTimeId: _selectedTimeId,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Afternoon',
                        style: AppTheme.subheadingStyle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TimeSlotSelector(
                        timeSlots: _afternoonSlots,
                        onTimeSelected: _onTimeSelected,
                        selectedTimeId: _selectedTimeId,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Evening',
                        style: AppTheme.subheadingStyle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TimeSlotSelector(
                        timeSlots: _eveningSlots,
                        onTimeSelected: _onTimeSelected,
                        selectedTimeId: _selectedTimeId,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: 'Continue',
                onPressed: _selectedTimeId != null ? _proceedToNextStep : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}