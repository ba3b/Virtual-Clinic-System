import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../components/patient_info_card.dart';
import '../../components/prescription_form.dart';
import '../../models/appointment_model.dart';
import '../../models/patient_detail_model.dart';
import '../../theme/theme.dart';
import 'virtual_appointment_screen.dart';

class DoctorAppointmentDetailsScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final String patientName;

  const DoctorAppointmentDetailsScreen({
    Key? key,
    required this.appointment,
    required this.patientName,
  }) : super(key: key);

  @override
  State<DoctorAppointmentDetailsScreen> createState() => _DoctorAppointmentDetailsScreenState();
}

class _DoctorAppointmentDetailsScreenState extends State<DoctorAppointmentDetailsScreen> {
  bool _isLoadingPatient = true;
  bool _isSubmittingPrescription = false;
  PatientDetailModel? _patientDetail;
  final TextEditingController _diagnosisController = TextEditingController();
  bool _showPrescriptionForm = false;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientDetails() async {
    // Simulate API call to get patient details
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample patient data
    setState(() {
      _patientDetail = PatientDetailModel(
        patientId: widget.appointment.patientId,
        name: widget.patientName,
        email: 'patient@example.com',
        phoneNumber: '+966 50 123 4567',
        address: 'Taif, Saudi Arabia',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'Male',
        allergies: ['Penicillin', 'Pollen'],
        medicalHistory: 'Patient has a history of mild asthma and seasonal allergies.',
      );
      _isLoadingPatient = false;
    });
  }

  void _handleJoinVirtualMeeting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorVirtualAppointmentScreen(
          appointment: widget.appointment,
          patientName: widget.patientName,
        ),
      ),
    );
  }

  void _handleSubmitDiagnosis() {
    if (_diagnosisController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diagnosis saved successfully')),
      );
      
      setState(() {
        _showPrescriptionForm = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a diagnosis'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleSubmitPrescription(String medication, String dosage) async {
    setState(() {
      _isSubmittingPrescription = true;
    });
    
    // Simulate API call to save prescription
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isSubmittingPrescription = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription submitted successfully')),
      );
      
      // In a real app, you'd navigate back or update the UI
      Navigator.pop(context);
    }
  }

  void _handleViewMedicalHistory() {
    // Show a dialog or navigate to medical history screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical History'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _patientDetail?.medicalHistory ?? 'No medical history available',
                style: AppTheme.bodyStyle,
              ),
              const SizedBox(height: 16),
              const Text(
                'Past Appointments',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'The patient has had 3 previous appointments in the last 6 months.',
                style: AppTheme.bodyStyle,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Appointment Details',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoadingPatient
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppointmentHeader(),
                  const SizedBox(height: 24),
                  if (_patientDetail != null) ...[
                    PatientInfoCard(
                      patient: _patientDetail!,
                      onViewMedicalHistory: _handleViewMedicalHistory,
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildDiagnosisSection(),
                  const SizedBox(height: 24),
                  if (_showPrescriptionForm) ...[
                    PrescriptionForm(
                      onSubmit: _handleSubmitPrescription,
                      isLoading: _isSubmittingPrescription,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (!_showPrescriptionForm && widget.appointment.type.toLowerCase() == 'virtual' && 
                      widget.appointment.status.toLowerCase() == 'upcoming') ...[
                    CommonButton(
                      text: 'Join Virtual Meeting',
                      onPressed: _handleJoinVirtualMeeting,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAppointmentHeader() {
    IconData appointmentIcon;
    Color appointmentColor;
    
    switch (widget.appointment.type.toLowerCase()) {
      case 'virtual':
        appointmentIcon = Icons.videocam_rounded;
        appointmentColor = AppTheme.primaryColor;
        break;
      case 'physical':
        appointmentIcon = Icons.person_rounded;
        appointmentColor = Colors.blue;
        break;
      case 'vaccination':
        appointmentIcon = Icons.healing_rounded;
        appointmentColor = Colors.green;
        break;
      default:
        appointmentIcon = Icons.calendar_today_rounded;
        appointmentColor = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appointmentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appointmentColor.withOpacity(0.3),
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
                  color: appointmentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  appointmentIcon,
                  color: appointmentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.appointment.type[0].toUpperCase()}${widget.appointment.type.substring(1)} Appointment',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 18,
                        color: appointmentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.appointment.appointmentId}',
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
                  widget.appointment.status[0].toUpperCase() + widget.appointment.status.substring(1),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.calendar_today_outlined,
                'Date',
                DateFormat('MMM dd, yyyy').format(widget.appointment.dateTime),
              ),
              _buildInfoItem(
                Icons.access_time_rounded,
                'Time',
                DateFormat('hh:mm a').format(widget.appointment.dateTime),
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

  Color _getStatusColor() {
    switch (widget.appointment.status.toLowerCase()) {
      case 'upcoming':
        return AppTheme.primaryColor;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'pending':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
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

  Widget _buildDiagnosisSection() {
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
            'Patient Diagnosis',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _diagnosisController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your diagnosis and notes here...',
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
          const SizedBox(height: 16),
          CommonButton(
            text: 'Save Diagnosis',
            onPressed: _handleSubmitDiagnosis,
          ),
        ],
      ),
    );
  }
}