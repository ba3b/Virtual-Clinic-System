import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'custom_text_field.dart';

class PrescriptionForm extends StatefulWidget {
  final Function(String, String) onSubmit;
  final bool isLoading;
  
  const PrescriptionForm({
    Key? key,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _medicationController.text,
        _dosageController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prescription Details',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Medication Details',
            hint: 'Enter medication name and details',
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
            label: 'Dosage Instructions',
            hint: 'Enter dosage frequency and instructions',
            controller: _dosageController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter dosage instructions';
              }
              return null;
            },
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Submit Prescription'),
          ),
        ],
      ),
    );
  }
}