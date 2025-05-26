import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> prescriptionData;

  const PrescriptionDetailScreen({
    Key? key,
    required this.prescriptionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = prescriptionData['createdAt'] as DateTime;
    final DateTime expiryDate = createdAt.add(const Duration(days: 7));
    final int daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    final bool isExpiringSoon = daysUntilExpiry <= 2;
    final bool isExpired = daysUntilExpiry < 0;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Prescription Details',
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrescriptionHeader(createdAt, isExpired, isExpiringSoon,
                daysUntilExpiry, expiryDate),
            const SizedBox(height: 24),
            _buildMedicationDetails(),
            const SizedBox(height: 24),
            _buildDoctorInfo(),
            const SizedBox(height: 24),
            _buildValidityInfo(createdAt, expiryDate, isExpired, isExpiringSoon,
                daysUntilExpiry),
            const SizedBox(height: 24),
            _buildImportantNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionHeader(DateTime createdAt, bool isExpired,
      bool isExpiringSoon, int daysUntilExpiry, DateTime expiryDate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [
                  AppTheme.errorColor.withOpacity(0.1),
                  AppTheme.errorColor.withOpacity(0.05)
                ]
              : isExpiringSoon
                  ? [
                      AppTheme.errorColor.withOpacity(0.1),
                      AppTheme.errorColor.withOpacity(0.05)
                    ]
                  : [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05)
                    ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired
              ? AppTheme.errorColor.withOpacity(0.3)
              : isExpiringSoon
                  ? AppTheme.errorColor.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isExpired
                    ? AppTheme.errorColor
                    : isExpiringSoon
                        ? AppTheme.errorColor
                        : AppTheme.primaryColor)
                .withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isExpired
                        ? [
                            AppTheme.errorColor,
                            AppTheme.errorColor.withOpacity(0.8)
                          ]
                        : isExpiringSoon
                            ? [
                                AppTheme.errorColor,
                                AppTheme.errorColor.withOpacity(0.8)
                              ]
                            : [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.8)
                              ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isExpired
                              ? AppTheme.errorColor
                              : isExpiringSoon
                                  ? AppTheme.errorColor
                                  : AppTheme.primaryColor)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isExpired ? Icons.warning : Icons.medication_liquid,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prescriptionData['medicationDetails'] ??
                          'Unknown Medication',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 20,
                        color: isExpired
                            ? AppTheme.errorColor
                            : isExpiringSoon
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.errorColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'EXPIRED',
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isExpiringSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.errorColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'EXPIRES ${daysUntilExpiry == 0 ? 'TODAY' : 'IN ${daysUntilExpiry}D'}',
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.successColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppTheme.successColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ACTIVE',
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.calendar_today_outlined,
                'Issued Date',
                DateFormat('MMM dd, yyyy').format(createdAt),
              ),
              _buildInfoItem(
                Icons.access_time_outlined,
                'Valid Until',
                DateFormat('MMM dd, yyyy').format(expiryDate),
                textColor: isExpired
                    ? AppTheme.errorColor
                    : isExpiringSoon
                        ? AppTheme.errorColor
                        : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value,
      {Color? textColor}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: textColor ?? AppTheme.textSecondaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTheme.bodySmallStyle.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor ?? AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMedicationDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medication_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Medication Details',
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailItem('Medication',
              prescriptionData['medicationDetails'] ?? 'Not specified'),
          const SizedBox(height: 20),
          Text(
            'Dosage Instructions',
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Text(
              prescriptionData['dosageInstructions'] ??
                  'No instructions provided',
              style: AppTheme.bodyStyle.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Prescribed By',
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${prescriptionData['doctorName'] ?? 'Unknown Doctor'}',
                      style: AppTheme.subheadingStyle.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prescriptionData['doctorSpecialty'] ?? 'General Medicine',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verified Doctor',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidityInfo(DateTime createdAt, DateTime expiryDate,
      bool isExpired, bool isExpiringSoon, int daysUntilExpiry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isExpired
            ? AppTheme.errorColor.withOpacity(0.05)
            : isExpiringSoon
                ? AppTheme.errorColor.withOpacity(0.05)
                : AppTheme.successColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired
              ? AppTheme.errorColor.withOpacity(0.3)
              : isExpiringSoon
                  ? AppTheme.errorColor.withOpacity(0.3)
                  : AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired ? Icons.error_outline : Icons.schedule_outlined,
                color: isExpired
                    ? AppTheme.errorColor
                    : isExpiringSoon
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Prescription Validity',
                style: AppTheme.subheadingStyle.copyWith(
                  color: isExpired
                      ? AppTheme.errorColor
                      : isExpiringSoon
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issued Date',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(createdAt),
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expiry Date',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(expiryDate),
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isExpired ? AppTheme.errorColor : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isExpired
                  ? AppTheme.errorColor.withOpacity(0.1)
                  : isExpiringSoon
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isExpired
                      ? Icons.error
                      : isExpiringSoon
                          ? Icons.warning
                          : Icons.check_circle,
                  color: isExpired
                      ? AppTheme.errorColor
                      : isExpiringSoon
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isExpired
                        ? 'This prescription has expired and is no longer valid.'
                        : isExpiringSoon
                            ? 'This prescription expires ${daysUntilExpiry == 0 ? 'today' : 'in $daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'}'}.'
                            : 'This prescription is valid for ${daysUntilExpiry} more day${daysUntilExpiry == 1 ? '' : 's'}.',
                    style: AppTheme.bodyStyle.copyWith(
                      color: isExpired
                          ? AppTheme.errorColor
                          : isExpiringSoon
                              ? AppTheme.errorColor
                              : AppTheme.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.amber[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Important Notes',
                style: AppTheme.subheadingStyle.copyWith(
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNoteItem(
            Icons.warning_amber_rounded,
            'Take medication exactly as prescribed by your doctor.',
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.access_time,
            'Complete the full course even if you feel better.',
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.child_care,
            'Keep out of reach of children.',
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.thermostat,
            'Store at room temperature unless specified otherwise.',
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.phone,
            'Contact your doctor if you experience any side effects.',
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.amber[700],
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.amber[800],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
