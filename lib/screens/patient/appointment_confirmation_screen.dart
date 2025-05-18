import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentConfirmationScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  String _formatDateTime() {
    final date = appointmentData['appointmentDate'] as DateTime;
    final time = appointmentData['appointmentTime'] as String;
    
    return '${date.day}/${date.month}/${date.year} at $time';
  }

  String _getAppointmentTitle() {
    final type = appointmentData['appointmentType'] as String;
    
    if (type == 'vaccination') {
      return 'Vaccination: ${appointmentData['vaccinationType']}';
    } else if (type == 'virtual') {
      return 'Virtual Appointment: ${appointmentData['department']}';
    } else {
      return 'Physical Appointment: ${appointmentData['department']}';
    }
  }

  Widget _buildAppointmentDetails() {
    final iconData = appointmentData['appointmentType'] == 'virtual'
        ? Icons.videocam_rounded
        : appointmentData['appointmentType'] == 'physical'
            ? Icons.person_rounded
            : Icons.healing_rounded;

    final iconColor = appointmentData['appointmentType'] == 'virtual'
        ? AppTheme.primaryColor
        : appointmentData['appointmentType'] == 'physical'
            ? Colors.blue
            : Colors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getAppointmentTitle(),
              style: AppTheme.subheadingStyle.copyWith(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(),
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.amber,
                  width: 1,
                ),
              ),
              child: Text(
                'Pending Confirmation',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your appointment is pending confirmation. You will receive a notification once confirmed.',
                    style: AppTheme.bodySmallStyle,
                  ),
                ),
              ],
            ),
            if (appointmentData['appointmentId'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Appointment ID: ${appointmentData['appointmentId']}',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Appointment Successfully Booked!',
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your appointment has been booked and is pending confirmation',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildAppointmentDetails(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navigate back to home and clear the stack
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Back to Home'),
                ),
                const SizedBox(height: 8),  // Added bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}