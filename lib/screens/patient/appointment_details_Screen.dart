import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/firestore_service.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _cancelAppointment() async {
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

      final appointmentId = widget.appointmentData['appointmentId'] as String;
      
      await DatabaseService(uid: user.uid).cancelAppointment(appointmentId);
      
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cancelling appointment: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime() {
    final date = widget.appointmentData['appointmentDate'] as DateTime;
    
    return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hourFormatted = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    final minuteFormatted = minute.toString().padLeft(2, '0');
    
    return '$hourFormatted:$minuteFormatted $period';
  }

  String _getAppointmentTitle() {
    final type = widget.appointmentData['appointmentType'] as String;
    
    if (type == 'vaccination') {
      return 'Vaccination: ${widget.appointmentData['vaccinationType']}';
    } else if (type == 'virtual') {
      return 'Virtual Appointment: ${widget.appointmentData['department']}';
    } else {
      return 'Physical Appointment: ${widget.appointmentData['department']}';
    }
  }

  Widget _buildStatusChip() {
    final status = widget.appointmentData['status'] as String;
    
    late final Color color;
    late final IconData icon;
    
    switch (status) {
      case AppointmentModel.statusPending:
        color = Colors.amber;
        icon = Icons.pending_outlined;
        break;
      case AppointmentModel.statusApproved:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case AppointmentModel.statusRejected:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case AppointmentModel.statusCompleted:
        color = Colors.blue;
        icon = Icons.task_alt;
        break;
      case AppointmentModel.statusCancelled:
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            status.substring(0, 1).toUpperCase() + status.substring(1),
            style: AppTheme.bodyStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _canCancelAppointment() {
    final status = widget.appointmentData['status'] as String;
    final appointmentDate = widget.appointmentData['appointmentDate'] as DateTime;
    
    // Can cancel if pending and at least 24 hours before the appointment
    return status == AppointmentModel.statusPending && 
           appointmentDate.difference(DateTime.now()).inHours > 24;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentType = widget.appointmentData['appointmentType'] as String;
    
    final iconData = appointmentType == 'virtual'
        ? Icons.videocam_rounded
        : appointmentType == 'physical'
            ? Icons.person_rounded
            : Icons.healing_rounded;

    final iconColor = appointmentType == 'virtual'
        ? AppTheme.primaryColor
        : appointmentType == 'physical'
            ? Colors.blue
            : Colors.green;
            
    final status = widget.appointmentData['status'] as String;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Appointment Details',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              _buildStatusChip(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailItem(
                icon: Icons.person_outline,
                title: 'Doctor',
                value: widget.appointmentData['doctorName'] as String? ?? 'Not assigned yet',
              ),
              _buildDetailItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Appointment ID',
                value: widget.appointmentData['appointmentId'] as String,
              ),
              if (status == AppointmentModel.statusApproved && appointmentType == 'virtual')
                _buildDetailItem(
                  icon: Icons.videocam_outlined,
                  title: 'Join Virtual Appointment',
                  value: 'Click to join',
                  isButton: true,
                  onTap: () {
                    // Navigate to virtual meeting room
                  },
                ),
              const Spacer(),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_canCancelAppointment())
                _isLoading
                    ? const CircularProgressIndicator()
                    : CommonButton(
                        text: 'Cancel Appointment',
                        onPressed: _cancelAppointment,
                        backgroundColor: Colors.red,
                      ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isButton = false,
    VoidCallback? onTap,
  }) {
    final content = Row(
      children: [
        Icon(
          icon,
          color: isButton ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodySmallStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: AppTheme.bodyStyle.copyWith(
                  color: isButton ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                  fontWeight: isButton ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (isButton)
          const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.primaryColor,
            size: 16,
          ),
      ],
    );
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: isButton
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: content,
              ),
            )
          : content,
    );
  }
}