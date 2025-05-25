import 'package:flutter/material.dart';
import '../../api/firestore_service.dart';
import '../../components/common_button.dart';
import '../../components/custom_text_field.dart';
import '../../models/appointment_model.dart';
import '../../theme/theme.dart';
import 'prescription_page.dart';

class DiagnosisWritingPage extends StatefulWidget {
  final AppointmentModel appointment;
  final String patientName;

  const DiagnosisWritingPage({
    Key? key,
    required this.appointment,
    required this.patientName,
  }) : super(key: key);

  @override
  State<DiagnosisWritingPage> createState() => _DiagnosisWritingPageState();
}

class _DiagnosisWritingPageState extends State<DiagnosisWritingPage> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _saveDiagnosis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save diagnosis to medical history using the correct format
      await DatabaseService(uid: widget.appointment.patientId)
          .addDiagnosisToMedicalHistory(
        patientId: widget.appointment.patientId,
        diagnosis: _diagnosisController.text.trim(),
        appointmentId: widget.appointment.appointmentId,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagnosis saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Navigate to prescription page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionPage(
              appointment: widget.appointment,
              patientName: widget.patientName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving diagnosis: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Write Diagnosis'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient and Appointment Info Header
              _buildPatientInfoHeader(),
              const SizedBox(height: 24),

              // Diagnosis Form
              _buildDiagnosisForm(),
              const SizedBox(height: 32),

              // Action Button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnosis for ${widget.patientName}',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Appointment: ${widget.appointment.appointmentId}',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Step 1 of 2',
                    style: AppTheme.bodySmallStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Write your diagnosis and observations. This will be saved to the patient\'s medical history.',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Patient Diagnosis',
                  style: AppTheme.subheadingStyle,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Diagnosis & Observations *',
              hint: 'Enter your diagnosis, findings, and medical observations...',
              controller: _diagnosisController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a diagnosis';
                }
                if (value.length < 10) {
                  return 'Please provide a more detailed diagnosis (at least 10 characters)';
                }
                return null;
              },
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Include symptoms, examination findings, test results, and your clinical assessment.',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), // Better alignment
      child: CommonButton(
        text: 'Continue to Prescription',
        onPressed: _isSubmitting ? null : _saveDiagnosis,
        isLoading: _isSubmitting,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}