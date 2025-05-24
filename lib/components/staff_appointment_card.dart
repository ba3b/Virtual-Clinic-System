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
  final VoidCallback? onReject;
  
  const StaffAppointmentCard({
    Key? key,
    required this.appointment,
    required this.patientName,
    this.doctorName,
    required this.onTap,
    this.onAssignDoctor,
    this.onVerify,
    this.onReject,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (appointment.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'upcoming':
        return AppTheme.primaryColor;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
      case 'rejected':
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

  String _getAppointmentTitle() {
    if (appointment.type.toLowerCase() == 'vaccination') {
      return 'Vaccination Appointment';
    }
    return '${appointment.type[0].toUpperCase()}${appointment.type.substring(1)} Appointment';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getAppointmentIcon(),
                      color: _getStatusColor(),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getAppointmentTitle(),
                          style: AppTheme.subheadingStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Patient: $patientName',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 15,
                          ),
                        ),
                        if (appointment.department != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Department: ${appointment.department}',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (appointment.type == AppointmentModel.typeVaccination && 
                            appointment.vaccinationType != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Vaccine: ${appointment.vaccinationType}',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      appointment.status[0].toUpperCase() + appointment.status.substring(1),
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('MMM dd, yyyy').format(appointment.dateTime),
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('hh:mm a').format(appointment.dateTime),
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (doctorName != null) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 18,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Assigned Doctor: $doctorName',
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (appointment.status.toLowerCase() == 'pending') ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    // For vaccination appointments, show Verify button
                    if (appointment.type == AppointmentModel.typeVaccination && onVerify != null) ...[
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: onVerify,
                          icon: const Icon(Icons.verified_outlined, size: 20),
                          label: const Text('Verify'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ]
                    // For other appointments, show Assign Doctor button
                    else if (onAssignDoctor != null) ...[
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: onAssignDoctor,
                          icon: const Icon(Icons.person_add_outlined, size: 20),
                          label: const Text('Assign Doctor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (onReject != null)
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ] else if (doctorName == null && onAssignDoctor != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Doctor assignment required',
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: onAssignDoctor,
                        child: const Text('Assign'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}