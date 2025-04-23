import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';

class AppointmentSummaryScreen extends StatefulWidget {
  final String appointmentType;
  final DateTime appointmentDateTime;

  const AppointmentSummaryScreen({
    super.key,
    required this.appointmentType,
    required this.appointmentDateTime,
  });

  @override
  State<AppointmentSummaryScreen> createState() => _AppointmentSummaryScreenState();
}

class _AppointmentSummaryScreenState extends State<AppointmentSummaryScreen> {
  bool _isSubmitting = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

  IconData _getAppointmentTypeIcon() {
    switch (widget.appointmentType) {
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

  Color _getAppointmentTypeColor() {
    switch (widget.appointmentType) {
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

  String _getDepartmentName() {
    switch (widget.appointmentType) {
      case 'virtual':
        return 'General Medicine';
      case 'physical':
        return 'Internal Medicine';
      case 'vaccination':
        return 'Immunization Center';
      default:
        return 'General Medicine';
    }
  }

  Future<void> _submitAppointment() async {
    setState(() {
      _isSubmitting = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isSubmitting = false;
    });
    
    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Booked'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.successColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your appointment has been booked successfully. The staff will review it and assign a doctor. You will receive a notification once confirmed.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog and navigate back to home
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Appointment Summary',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review Appointment Details',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Please review your appointment details before confirming',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAppointmentCard(),
                      const SizedBox(height: 24),
                      _buildAppointmentDetails(),
                      const SizedBox(height: 24),
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: 'Confirm Appointment',
                isLoading: _isSubmitting,
                onPressed: _submitAppointment,
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: 'Go Back',
                isOutlined: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard() {
    final Color typeColor = _getAppointmentTypeColor();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withOpacity(0.3),
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
                  color: typeColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getAppointmentTypeIcon(),
                  color: typeColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAppointmentTypeTitle(),
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 18,
                        color: typeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDepartmentName(),
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
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
                DateFormat('MMM dd, yyyy').format(widget.appointmentDateTime),
                typeColor,
              ),
              _buildInfoItem(
                Icons.access_time_rounded,
                'Time',
                DateFormat('hh:mm a').format(widget.appointmentDateTime),
                typeColor,
              ),
              _buildInfoItem(
                Icons.timer_outlined,
                'Duration',
                '30 mins',
                typeColor,
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

  Widget _buildAppointmentDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Details',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Department', _getDepartmentName()),
          _buildDetailRow('Doctor', 'Will be assigned by staff'),
          _buildDetailRow('Location', widget.appointmentType == 'virtual'
              ? 'Virtual Meeting'
              : 'King Faisal Medical Complex, Taif'),
          _buildDetailRow('Patient Name', 'Mohammed Hussein'),
          _buildDetailRow('Patient ID', 'P1234567'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes (Optional)',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Add any specific concerns or notes for the doctor',
            style: AppTheme.bodySmallStyle.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'E.g., Symptoms, duration, any questions you have...',
              hintStyle: AppTheme.bodySmallStyle.copyWith(
                color: AppTheme.textSecondaryColor.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}