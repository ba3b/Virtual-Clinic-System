import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../theme/theme.dart';

class StaffAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final String patientName;
  final String? doctorName;
  final VoidCallback onTap;
  final VoidCallback? onAssignDoctor;
  final VoidCallback? onVerify;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const StaffAppointmentCard({
    Key? key,
    required this.appointment,
    required this.patientName,
    this.doctorName,
    required this.onTap,
    this.onAssignDoctor,
    this.onVerify,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (appointment.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'upcoming':
        return AppTheme.primaryColor;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
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
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAppointmentIcon(),
                      color: _getStatusColor(),
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
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status[0].toUpperCase() + appointment.status.substring(1),
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
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
              if (doctorName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Doctor: $doctorName',
                      style: AppTheme.bodySmallStyle,
                    ),
                  ],
                ),
              ] else if (appointment.status.toLowerCase() == 'pending' && 
                         onAssignDoctor != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onAssignDoctor,
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Assign Doctor'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
              if (appointment.status.toLowerCase() == 'pending' && 
                  (onVerify != null || onEdit != null || onDelete != null)) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onVerify != null)
                      IconButton(
                        onPressed: onVerify,
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Verify',
                        color: AppTheme.successColor,
                      ),
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        color: Colors.blue,
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        color: AppTheme.errorColor,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}