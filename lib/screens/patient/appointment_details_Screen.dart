import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import 'virtual_appointment_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isVirtual = appointmentData['appointmentType'].toString().toLowerCase() == 'virtual';
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Appointment Details',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentStatusCard(context),
            const SizedBox(height: 24),
            _buildAppointmentDetailsSection(),
            const SizedBox(height: 24),
            _buildDoctorInfoSection(),
            const SizedBox(height: 32),
            CommonButton(
              text: isVirtual ? 'Join Virtual Appointment' : 'Navigate to Hospital',
              onPressed: () {
                if (isVirtual) {
                  // Navigate to virtual appointment screen with messaging capability
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VirtualAppointmentScreen(
                        appointmentData: appointmentData,
                      ),
                    ),
                  );
                } else {
                  // Handle physical appointment navigation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigation functionality will be implemented next'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            CommonButton(
              text: 'Reschedule Appointment',
              isOutlined: true,
              onPressed: () {
                // TODO: Handle rescheduling
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rescheduling functionality will be implemented next'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CommonButton(
              text: 'Cancel Appointment',
              isOutlined: true,
              backgroundColor: AppTheme.errorColor.withOpacity(0.5),
              textColor: AppTheme.errorColor,
              onPressed: () {
                // TODO: Handle cancellation
                _showCancelConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStatusCard(BuildContext context) {
    final DateTime appointmentDate = appointmentData['appointmentDate'];
    final String status = appointmentData['status'];
    final String appointmentType = appointmentData['appointmentType'];
    
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'upcoming':
        statusColor = AppTheme.primaryColor;
        break;
      case 'completed':
        statusColor = AppTheme.successColor;
        break;
      case 'cancelled':
        statusColor = AppTheme.errorColor;
        break;
      default:
        statusColor = AppTheme.primaryColor;
    }

    IconData appointmentIcon;
    switch (appointmentType.toLowerCase()) {
      case 'virtual':
        appointmentIcon = Icons.videocam_rounded;
        break;
      case 'physical':
        appointmentIcon = Icons.person_rounded;
        break;
      case 'vaccination':
        appointmentIcon = Icons.healing_rounded;
        break;
      default:
        appointmentIcon = Icons.calendar_today_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  appointmentIcon,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${appointmentType} Appointment',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 18,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                      style: AppTheme.bodyStyle.copyWith(
                        color: statusColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.calendar_today_outlined,
                'Date',
                DateFormat('MMM dd, yyyy').format(appointmentDate),
                statusColor,
              ),
              _buildInfoItem(
                Icons.access_time_rounded,
                'Time',
                DateFormat('hh:mm a').format(appointmentDate),
                statusColor,
              ),
              _buildInfoItem(
                Icons.timer_outlined,
                'Duration',
                '30 mins',
                statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTheme.bodySmallStyle.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Details',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 16),
        _buildDetailItem('Appointment ID', '#APT12345'),
        _buildDetailItem('Department', 'General Medicine'),
        _buildDetailItem(
          'Location',
          appointmentData['appointmentType'].toString().toLowerCase() == 'virtual'
              ? 'Virtual Meeting (Zoom)'
              : 'King Faisal Medical Complex, Taif',
        ),
        _buildDetailItem('Booked On', 'April 20, 2025'),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Doctor Information',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${appointmentData['doctorName']}',
                    style: AppTheme.subheadingStyle.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'General Medicine',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: AppTheme.bodySmallStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(120 reviews)',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment canceled successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(
              'Yes, Cancel',
              style: TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}