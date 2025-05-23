import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../theme/theme.dart';

class DoctorAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final String patientName;
  final VoidCallback onTap;
  
  const DoctorAppointmentCard({
    Key? key,
    required this.appointment,
    required this.patientName,
    required this.onTap,
  }) : super(key: key);

  Color _getTypeColor() {
    switch (appointment.type.toLowerCase()) {
      case 'virtual':
        return AppTheme.primaryColor;
      case 'physical':
        return Colors.blue;
      case 'vaccination':
        return Colors.green;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getAppointmentIcon() {
    switch (appointment.type.toLowerCase()) {
      case 'virtual':
        return Icons.videocam_rounded;
      case 'physical':
        return Icons.person_rounded;
      case 'vaccination':
        return Icons.healing_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAppointmentIcon(),
                      color: _getTypeColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${appointment.type[0].toUpperCase()}${appointment.type.substring(1)} Appointment',
                          style: AppTheme.subheadingStyle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Patient: $patientName',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        if (appointment.department != null)
                          Text(
                            'Department: ${appointment.department}',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        if (appointment.vaccinationType != null)
                          Text(
                            'Vaccine: ${appointment.vaccinationType}',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(appointment.dateTime),
                        style: AppTheme.bodySmallStyle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(appointment.dateTime),
                        style: AppTheme.bodySmallStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
