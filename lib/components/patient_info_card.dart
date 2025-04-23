import 'package:flutter/material.dart';
import '../models/patient_detail_model.dart';
import '../theme/theme.dart';

class PatientInfoCard extends StatelessWidget {
  final PatientDetailModel patient;
  final VoidCallback? onViewMedicalHistory;
  
  const PatientInfoCard({
    Key? key,
    required this.patient,
    this.onViewMedicalHistory,
  }) : super(key: key);

  String _calculateAge() {
    final DateTime now = DateTime.now();
    int age = now.year - patient.dateOfBirth.year;
    if (now.month < patient.dateOfBirth.month || 
        (now.month == patient.dateOfBirth.month && now.day < patient.dateOfBirth.day)) {
      age--;
    }
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        patient.name,
                        style: AppTheme.subheadingStyle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient ID: ${patient.patientId}',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            '${_calculateAge()} years',
                            Icons.cake_outlined,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            patient.gender,
                            patient.gender.toLowerCase() == 'male'
                                ? Icons.male_outlined
                                : Icons.female_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildContactInfo(),
            const SizedBox(height: 16),
            if (patient.allergies != null && patient.allergies!.isNotEmpty)
              _buildAllergiesSection(),
            if (onViewMedicalHistory != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onViewMedicalHistory,
                icon: const Icon(Icons.history),
                label: const Text('View Medical History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmallStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: AppTheme.subheadingStyle.copyWith(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _buildContactRow(Icons.phone_outlined, patient.phoneNumber),
        const SizedBox(height: 8),
        _buildContactRow(Icons.email_outlined, patient.email),
        const SizedBox(height: 8),
        _buildContactRow(Icons.location_on_outlined, patient.address),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Colors.amber,
            ),
            const SizedBox(width: 8),
            Text(
              'Allergies',
              style: AppTheme.subheadingStyle.copyWith(
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: patient.allergies!.map((allergy) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Text(
                allergy,
                style: AppTheme.bodySmallStyle.copyWith(
                  color: Colors.amber[800],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}