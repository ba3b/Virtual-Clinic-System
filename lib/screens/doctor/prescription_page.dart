import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/firestore_service.dart';
import '../../components/common_button.dart';
import '../../components/custom_text_field.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';

class PrescriptionPage extends StatefulWidget {
  final AppointmentModel appointment;
  final String patientName;

  const PrescriptionPage({
    Key? key,
    required this.appointment,
    required this.patientName,
  }) : super(key: key);

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _submitPrescription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) throw Exception('User not found');

      await DatabaseService(uid: user.uid).createPrescription(
        appointmentId: widget.appointment.appointmentId,
        patientId: widget.appointment.patientId,
        doctorId: user.uid,
        medicationDetails: _medicationController.text.trim(),
        dosageInstructions: _dosageController.text.trim(),
      );

      await DatabaseService(uid: user.uid)
          .updateAppointmentStatus(widget.appointment.appointmentId, 'completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription submitted successfully! Appointment completed.'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting prescription: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _skipPrescription() async {
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Prescription'),
        content: const Text(
          'Are you sure you want to complete this appointment without writing a prescription?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Skip Prescription'),
          ),
        ],
      ),
    );

    if (shouldSkip != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) throw Exception('User not found');

      await DatabaseService(uid: user.uid)
          .updateAppointmentStatus(widget.appointment.appointmentId, 'completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment completed successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing appointment: $e'),
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
        title: const Text('Write Prescription'),
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

              _buildPrescriptionForm(),
              const SizedBox(height: 32),

              _buildActionButtons(),
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
                    Icons.medical_services,
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
                        'Prescription for ${widget.patientName}',
                        style: AppTheme.subheadingStyle,
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
                    'Step 2 of 2',
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
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This prescription will be saved to the patient\'s medical records and the appointment will be marked as completed.',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: Colors.amber[800],
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

  Widget _buildPrescriptionForm() {
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
                  Icons.medication,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prescription Details',
                  style: AppTheme.subheadingStyle,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Medication Details *',
              hint: 'Enter medication name, strength, and form (e.g., Amoxicillin 500mg tablets)',
              controller: _medicationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medication details';
                }
                return null;
              },
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Dosage Instructions *',
              hint: 'Enter dosage frequency and instructions (e.g., Take 1 tablet twice daily with food)',
              controller: _dosageController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dosage instructions';
                }
                return null;
              },
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), 
      child: Column(
        children: [
          CommonButton(
            text: 'Complete & Submit Prescription',
            onPressed: _isSubmitting ? null : _submitPrescription,
            isLoading: _isSubmitting,
            backgroundColor: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          CommonButton(
            text: 'Complete Without Prescription',
            onPressed: _isSubmitting ? null : _skipPrescription,
            backgroundColor: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}