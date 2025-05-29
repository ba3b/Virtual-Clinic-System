import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/firestore_service.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../models/user_model.dart';
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
  bool _isLoading = true;
  List<String> _availableTimeSlots = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAvailableTimeSlots();
  }

  Future<void> _fetchAvailableTimeSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final dbService = DatabaseService(uid: user.uid);
      final availableSlots = await dbService.getAvailableTimeSlots(
        widget.appointmentDate,
        widget.appointmentType,
        widget.department,
      );

      setState(() {
        _availableTimeSlots = availableSlots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading time slots: $e';
        _isLoading = false;
      });
    }
  }

  void _onTimeSlotSelected(String timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  Future<void> _proceedToBookAppointment() async {
    if (_selectedTimeSlot == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final dbService = DatabaseService(uid: user.uid);
      
      final appointmentId = await dbService.createAppointment(
        patientId: user.uid,
        appointmentDate: widget.appointmentDate,
        appointmentTime: _selectedTimeSlot!,
        appointmentType: widget.appointmentType,
        department: widget.department,
        vaccinationType: widget.vaccinationType,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      final appointmentData = {
        'appointmentId': appointmentId,
        'appointmentType': widget.appointmentType,
        'appointmentDate': widget.appointmentDate,
        'appointmentTime': _selectedTimeSlot,
        if (widget.department != null) 'department': widget.department,
        if (widget.vaccinationType != null) 'vaccinationType': widget.vaccinationType,
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentConfirmationScreen(
            appointmentData: appointmentData,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error booking appointment: $e';
        _isLoading = false;
      });
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
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _fetchAvailableTimeSlots,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_availableTimeSlots.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy,
                          color: AppTheme.textSecondaryColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No available time slots for this date.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Try another date'),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
              if (!_isLoading)
                CommonButton(
                  text: 'Book Appointment',
                  onPressed: _selectedTimeSlot != null ? _proceedToBookAppointment : () {},
                )
              else
                const SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Processing...'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}