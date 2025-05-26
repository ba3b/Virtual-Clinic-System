import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../api/firestore_service.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import 'diagnosis_writing_page.dart';
import 'virtual_appointment_screen.dart';
import 'dart:async';

class DoctorAppointmentDetailsScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final String patientName;

  const DoctorAppointmentDetailsScreen({
    Key? key,
    required this.appointment,
    required this.patientName,
  }) : super(key: key);

  @override
  State<DoctorAppointmentDetailsScreen> createState() =>
      _DoctorAppointmentDetailsScreenState();
}

class _DoctorAppointmentDetailsScreenState
    extends State<DoctorAppointmentDetailsScreen> {
  bool _isLoadingPatient = true;
  PatientModel? _patientDetail;
  Timer? _timeCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
    _startTimeMonitoring(); // Add this line
  }

  @override
  void dispose() {
    _timeCheckTimer?.cancel(); // Add this line
    super.dispose();
  }

  // Add this new method
  void _startTimeMonitoring() {
    _timeCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild and re-evaluate _canJoinVirtualMeeting()
        });
      }
    });
  }

  Future<void> _loadPatientDetails() async {
    try {
      final patientData =
          await DatabaseService(uid: widget.appointment.patientId)
              .getUserDetails(widget.appointment.patientId);

      if (mounted) {
        setState(() {
          _patientDetail = patientData as PatientModel;
          _isLoadingPatient = false;
        });
      }
    } catch (e) {
      print('Error loading patient details: $e');
      if (mounted) {
        setState(() {
          _isLoadingPatient = false;
        });
      }
    }
  }

  bool _canJoinVirtualMeeting() {
    if (widget.appointment.type.toLowerCase() != 'virtual') {
      return false;
    }
    if (widget.appointment.status.toLowerCase() != 'approved') {
      return false;
    }
    
    final now = DateTime.now();
    final appointmentTime = widget.appointment.dateTime;
    final windowEnd = appointmentTime.add(const Duration(minutes: 20));
    
    // Allow joining from appointment time to 20 minutes after
    return !now.isBefore(appointmentTime) && now.isBefore(windowEnd);
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

  void _handleViewMedicalHistory() async {
    try {
      // Fetch from database
      final medicalHistory =
          await DatabaseService(uid: widget.appointment.patientId)
              .getPatientMedicalHistory(widget.appointment.patientId);

      if (medicalHistory.isEmpty) {
        _showEmptyMedicalHistoryDialog();
        return;
      }

      _showMedicalHistoryDialog(medicalHistory);
    } catch (e) {
      print('Error loading medical history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading medical history: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showMedicalHistoryDialog(List<Map<String, dynamic>> medicalHistory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.history, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Medical History'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: medicalHistory.isEmpty
              ? const Center(
                  child: Text('No medical history available'),
                )
              : ListView.builder(
                  itemCount: medicalHistory.length,
                  itemBuilder: (context, index) {
                    final entry = medicalHistory[index];
                    final timestamp = entry['timestamp'];
                    final description =
                        entry['description'] as String? ?? 'No description';
                    final type = entry['type'] as String? ?? 'diagnosis';

                    DateTime? entryDate;
                    if (timestamp is Timestamp) {
                      entryDate = timestamp.toDate();
                    } else if (timestamp is DateTime) {
                      entryDate = timestamp;
                    } else if (timestamp is String) {
                      try {
                        entryDate = DateTime.parse(timestamp);
                      } catch (e) {
                        print('Error parsing timestamp: $e');
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  type == 'diagnosis'
                                      ? Icons.medical_services
                                      : Icons.note_alt,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type.toUpperCase(),
                                  style: AppTheme.bodySmallStyle.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (entryDate != null)
                                  Text(
                                    '${entryDate.day}/${entryDate.month}/${entryDate.year}',
                                    style: AppTheme.bodySmallStyle.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: AppTheme.bodyStyle,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

  void _showEmptyMedicalHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical History'),
        content: const Text('No medical history available for this patient.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleWriteDiagnosis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisWritingPage(
          appointment: widget.appointment,
          patientName: widget.patientName,
        ),
      ),
    );
  }

  bool _canWriteDiagnosis() {
    if (widget.appointment.status.toLowerCase() != 'approved') {
      return false;
    }

    final now = DateTime.now();
    final appointmentTime = widget.appointment.dateTime;

    return !now.isBefore(appointmentTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
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
                  // Join Virtual Meeting Button (if applicable)
                  if (_canJoinVirtualMeeting()) ...[
                    CommonButton(
                      text: 'Join Virtual Meeting',
                      onPressed: _handleJoinVirtualMeeting,
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Appointment Info Component
                  _AppointmentInfoCard(appointment: widget.appointment),
                  const SizedBox(height: 16),

                  // Patient Details Component
                  if (_patientDetail != null)
                    _PatientDetailsCard(patient: _patientDetail!),
                  const SizedBox(height: 24),

                  // Action Buttons
                  CommonButton(
                    text: 'View Medical History',
                    onPressed: _handleViewMedicalHistory,
                    backgroundColor: Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  // Only show Write Diagnosis if appointment is approved
                  if (_canWriteDiagnosis())
                    CommonButton(
                      text: 'Write Diagnosis',
                      onPressed: _handleWriteDiagnosis,
                      backgroundColor: AppTheme.primaryColor,
                    ),
                ],
              ),
            ),
    );
  }
}

class _AppointmentInfoCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentInfoCard({required this.appointment});

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

  Color _getStatusColor() {
    switch (appointment.status.toLowerCase()) {
      case 'approved':
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

  IconData _getTypeIcon() {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(),
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
                        style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${appointment.appointmentId}',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status[0].toUpperCase() +
                        appointment.status.substring(1),
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
                  '${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year}',
                ),
                _buildInfoItem(
                  Icons.access_time_rounded,
                  'Time',
                  '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}',
                ),
                _buildInfoItem(
                  Icons.timer_outlined,
                  'Duration',
                  '20 mins',
                ),
              ],
            ),
          ],
        ),
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
}

class _PatientDetailsCard extends StatelessWidget {
  final PatientModel patient;

  const _PatientDetailsCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient ID: ${patient.userId}',
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
              children: [
                Expanded(
                  child: _buildDetailItem('Age', '25 years'), // Placeholder
                ),
                Expanded(
                  child: _buildDetailItem('Gender', 'Male'), // Placeholder
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailItem('Phone', patient.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
