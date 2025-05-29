import 'package:flutter/material.dart';
import '../../api/firestore_service.dart';
import '../../components/common_button.dart';
import '../../components/custom_text_field.dart';
import '../../models/appointment_model.dart';
import '../../theme/theme.dart';
import 'prescription_page.dart';
import '../../components/eligibility_management_dialog.dart';

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
  List<String> _currentEligibility = [];
  bool _loadingEligibility = true;

  @override
  void initState() {
    super.initState();
    _loadPatientEligibility();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientEligibility() async {
    try {
      final eligibility = await DatabaseService(uid: widget.appointment.patientId)
          .getPatientEligibility(widget.appointment.patientId);
      
      if (mounted) {
        setState(() {
          _currentEligibility = eligibility;
          _loadingEligibility = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingEligibility = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading eligibility: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _openEligibilityDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EligibilityManagementDialog(
        patientId: widget.appointment.patientId,
        patientName: widget.patientName,
        currentEligibility: _currentEligibility,
      ),
    );

    if (result == true) {
      _loadPatientEligibility();
    }
  }

  Future<void> _saveDiagnosis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfoHeader(),
              const SizedBox(height: 24),

              _buildEligibilitySection(),
              const SizedBox(height: 24),

              _buildDiagnosisForm(),
              const SizedBox(height: 32),

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
                      'Write your diagnosis and update patient eligibility as needed. This will be saved to the patient\'s medical history.',
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

  Widget _buildEligibilitySection() {
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
                  Icons.admin_panel_settings,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Patient Eligibility Management',
                    style: AppTheme.subheadingStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_loadingEligibility)
              const Center(
                child: CircularProgressIndicator(),
              )
            else ...[
              Text(
                'Current Department Access (${_currentEligibility.length} departments):',
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              if (_currentEligibility.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_outlined,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No department access assigned. Patient cannot book appointments.',
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _currentEligibility.map((department) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            department,
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
                        'Tip: Update patient eligibility based on their condition, treatment progress, or referral needs.',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadingEligibility ? null : _openEligibilityDialog,
                  icon: Icon(
                    _loadingEligibility ? Icons.hourglass_empty : Icons.edit,
                    size: 18,
                  ),
                  label: Text(
                    _loadingEligibility ? 'Loading Eligibility...' : 'Manage Patient Eligibility',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: CommonButton(
        text: 'Continue to Prescription',
        onPressed: _isSubmitting ? null : _saveDiagnosis,
        isLoading: _isSubmitting,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}