import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName; 
  final DateTime appointmentDate;
  final String appointmentType; 
  final String status; 
  final VoidCallback? onTap;

  const AppointmentCard({
    Key? key,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentType,
    required this.status,
    this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getAppointmentTypeColor() {
    switch (appointmentType.toLowerCase()) {
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
    switch (appointmentType.toLowerCase()) {
      case 'virtual':
        return Icons.videocam_rounded;
      case 'physical':
        return Icons.person_rounded;
      case 'vaccination':
        return Icons.vaccines_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  String _getAppointmentTypeLabel() {
    switch (appointmentType.toLowerCase()) {
      case 'virtual':
        return 'Virtual Consultation';
      case 'physical':
        return 'Physical Consultation';
      case 'vaccination':
        return 'Vaccination';
      default:
        return 'Appointment';
    }
  }

  String _getSubtitle() {
    if (appointmentType.toLowerCase() == 'vaccination') {
      return doctorName; 
    } else {
      return doctorName; 
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool _isUpcoming() {
    return (status.toLowerCase() == 'pending' || status.toLowerCase() == 'approved') &&
           appointmentDate.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = _isUpcoming();
    final typeColor = _getAppointmentTypeColor();
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUpcoming ? typeColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
          ),
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
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAppointmentIcon(),
                        color: typeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getAppointmentTypeLabel(),
                            style: AppTheme.subheadingStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSubtitle(),
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
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
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd').format(appointmentDate),
                              style: AppTheme.bodySmallStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy').format(appointmentDate),
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 20,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('h:mm a').format(appointmentDate),
                              style: AppTheme.bodySmallStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            Text(
                              _getTimeUntilAppointment(),
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUpcoming && appointmentType.toLowerCase() == 'virtual') ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          color: Colors.green[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Virtual Meeting Available',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  String _getTimeUntilAppointment() {
    final now = DateTime.now();
    final difference = appointmentDate.difference(now);
    
    if (difference.isNegative) {
      if (difference.inDays < -1) {
        return '${difference.inDays.abs()} days ago';
      } else if (difference.inHours < -1) {
        return '${difference.inHours.abs()} hours ago';
      } else {
        return 'Recently';
      }
    } else {
      if (difference.inDays > 0) {
        return 'In ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hours';
      } else {
        return 'Soon';
      }
    }
  }
}
