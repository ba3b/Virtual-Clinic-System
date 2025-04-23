import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/appointment_edit_dialog.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../components/doctor_selector_dialog.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';

class StaffAppointmentDetailsScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final String patientName;
  final String? doctorName;
  final List<DoctorModel> availableDoctors;

  const StaffAppointmentDetailsScreen({
    super.key,
    required this.appointment,
    required this.patientName,
    this.doctorName,
    required this.availableDoctors,
  });

  @override
  State<StaffAppointmentDetailsScreen> createState() => _StaffAppointmentDetailsScreenState();
}

class _StaffAppointmentDetailsScreenState extends State<StaffAppointmentDetailsScreen> {
  late AppointmentModel _appointment;
  String? _doctorName;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _doctorName = widget.doctorName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Appointment Details',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentStatusCard(),
            const SizedBox(height: 24),
            _buildPatientInfo(),
            const SizedBox(height: 24),
            _buildDoctorAssignment(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStatusCard() {
    IconData appointmentIcon;
    Color statusColor;
    
    // Set icon based on appointment type
    switch (_appointment.type.toLowerCase()) {
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
    
    // Set color based on appointment status
    switch (_appointment.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
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

    return Container(
      padding: const EdgeInsets.all(16),
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
                      '${_appointment.type[0].toUpperCase()}${_appointment.type.substring(1)} Appointment',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 18,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${_appointment.appointmentId}',
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _appointment.status[0].toUpperCase() + _appointment.status.substring(1),
                  style: AppTheme.bodySmallStyle.copyWith(
                    color: statusColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.calendar_today_outlined,
                'Date',
                DateFormat('MMM dd, yyyy').format(_appointment.dateTime),
              ),
              _buildInfoItem(
                Icons.access_time_rounded,
                'Time',
                DateFormat('hh:mm a').format(_appointment.dateTime),
              ),
              _buildInfoItem(
                Icons.timer_outlined,
                'Duration',
                '30 mins',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          label,
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

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Patient Information',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', widget.patientName),
          _buildInfoRow('Patient ID', _appointment.patientId),
          _buildInfoRow('Appointment Type', _appointment.type),
          _buildInfoRow('Contact', '+966 50 123 4567'), // Sample data
          _buildInfoRow('Email', 'patient@example.com'), // Sample data
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildDoctorAssignment() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Doctor Assignment',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          if (_doctorName != null) ...[
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _doctorName!,
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'General Medicine', // Sample data
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_appointment.status.toLowerCase() == 'pending') ...[
                  IconButton(
                    onPressed: _assignDoctor,
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    tooltip: 'Reassign Doctor',
                  ),
                ],
              ],
            ),
          ] else ...[
            if (_appointment.type.toLowerCase() != 'vaccination') ...[
              // For non-vaccination appointments, show assign doctor button
              Row(
                children: [
                  const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No doctor assigned yet',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  CommonButton(
                    text: 'Assign Doctor',
                    onPressed: _assignDoctor,
                    backgroundColor: Colors.blue,
                    width: 150,
                  ),
                ],
              ),
            ] else ...[
              // For vaccination appointments, no doctor assignment needed
              Row(
                children: [
                  const Icon(
                    Icons.healing_outlined,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Vaccination appointment - no doctor assignment needed',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_appointment.status.toLowerCase() != 'pending') {
      // No actions for non-pending appointments
      return Container();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CommonButton(
                text: 'Verify Appointment',
                onPressed: _verifyAppointment,
                backgroundColor: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonButton(
                text: 'Edit Details',
                onPressed: _editAppointment,
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CommonButton(
          text: 'Delete Appointment',
          onPressed: _deleteAppointment,
          backgroundColor: AppTheme.errorColor,
        ),
      ],
    );
  }

  void _assignDoctor() {
    showDialog(
      context: context,
      builder: (context) => DoctorSelectorDialog(
        doctors: widget.availableDoctors,
        onDoctorSelected: (doctor) {
          // Update the appointment with the selected doctor
          setState(() {
            _appointment = _appointment.copyWith(doctorId: doctor.userId);
            _doctorName = doctor.name;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor "${doctor.name}" assigned successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
      ),
    );
  }

  void _verifyAppointment() {
    if (_appointment.type.toLowerCase() != 'vaccination' && _appointment.doctorId == null) {
      // For non-vaccination appointments, a doctor must be assigned
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign a doctor before verifying the appointment'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Appointment'),
        content: const Text(
          'Are you sure you want to verify this appointment? This will confirm the appointment and notify the patient.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Update the appointment status
              setState(() {
                _appointment = _appointment.copyWith(status: 'upcoming');
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment verified successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              
              // Go back to previous screen
              Navigator.pop(context, _appointment);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.successColor,
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _editAppointment() {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditDialog(
        appointment: _appointment,
        onAppointmentUpdated: (newDateTime) {
          // Update the appointment with the new date and time
          setState(() {
            _appointment = _appointment.copyWith(dateTime: newDateTime);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
      ),
    );
  }

  void _deleteAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text(
          'Are you sure you want to delete this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Return to previous screen with delete flag
              Navigator.pop(context, 'delete');
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment deleted successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}