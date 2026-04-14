import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import '../../api/firestore_service.dart';
import '../../models/user_model.dart';
import '../../localization/app_localizations.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> prescriptionData;

  const PrescriptionDetailScreen({
    Key? key,
    required this.prescriptionData,
  }) : super(key: key);

  @override
  State<PrescriptionDetailScreen> createState() => _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pharmacyRegIdController = TextEditingController();
  final _medicationDetailsController = TextEditingController();
  final _priceController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPharmacyFormVisible = false;

  String get prescriptionStatus => widget.prescriptionData['status'] ?? 'active';
  bool get hasPharmacyDetails => widget.prescriptionData['pharmacyRegistrationId'] != null;

  @override
  void initState() {
    super.initState();
    if (hasPharmacyDetails) {
      _pharmacyRegIdController.text = widget.prescriptionData['pharmacyRegistrationId'] ?? '';
      _medicationDetailsController.text = widget.prescriptionData['pharmacyMedicationDetails'] ?? '';
      _priceController.text = widget.prescriptionData['priceInSAR']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _pharmacyRegIdController.dispose();
    _medicationDetailsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = widget.prescriptionData['createdAt'] as DateTime;
    final DateTime expiryDate = createdAt.add(const Duration(days: 7));
    final int daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    final bool isExpiringSoon = daysUntilExpiry <= 2;
    final bool isExpired = daysUntilExpiry < 0 || prescriptionStatus == 'expired';

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('prescription_details'),
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
            if (hasPharmacyDetails || _isPharmacyFormVisible) ...[
              _buildPharmacySection(),
              const SizedBox(height: 24),
            ],
            if (!hasPharmacyDetails && prescriptionStatus == 'active') ...[
              _buildPharmacyButton(),
              const SizedBox(height: 24),
            ],
            _buildValidityInfo(createdAt, expiryDate, isExpired, isExpiringSoon, daysUntilExpiry),
            const SizedBox(height: 24),
            _buildImportantNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isPharmacyFormVisible = true;
          });
        },
        icon: const Icon(Icons.local_pharmacy),
        label: Text(AppLocalizations.of(context).translate('fill_pharmacy_details')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacySection() {
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
                Icons.local_pharmacy,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).translate('pharmacy_information'),
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (hasPharmacyDetails) ...[
            _buildPharmacyDisplayInfo(),
          ] else ...[
            _buildPharmacyForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildPharmacyDisplayInfo() {
    return Column(
      children: [
        _buildDetailItem(AppLocalizations.of(context).translate('pharmacy_reg_id'), widget.prescriptionData['pharmacyRegistrationId'] ?? ''),
        const SizedBox(height: 16),
        _buildDetailItem(AppLocalizations.of(context).translate('medication_details'), widget.prescriptionData['pharmacyMedicationDetails'] ?? ''),
        const SizedBox(height: 16),
        _buildDetailItem(AppLocalizations.of(context).translate('price'), '${widget.prescriptionData['priceInSAR']?.toStringAsFixed(2) ?? '0.00'} SAR'),
      ],
    );
  }

  Widget _buildPharmacyForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _pharmacyRegIdController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('pharmacy_reg_id_label'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context).translate('pharmacy_reg_id_empty');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _medicationDetailsController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('medication_details_label'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.medication),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context).translate('medication_details_empty');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('price_sar_label'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: 'SAR',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context).translate('price_empty');
              }
              final price = double.tryParse(value.trim());
              if (price == null || price <= 0) {
                return AppLocalizations.of(context).translate('invalid_price');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _isPharmacyFormVisible = false;
                    });
                  },
                  child: Text(AppLocalizations.of(context).translate('cancel')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPharmacyDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(AppLocalizations.of(context).translate('received')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitPharmacyDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<UserId?>(context, listen: false);
      if (user == null) throw Exception('User not logged in');

      final price = double.parse(_priceController.text.trim());

      await DatabaseService(uid: user.uid).updatePrescriptionPharmacyDetails(
        prescriptionId: widget.prescriptionData['prescriptionId'],
        pharmacyRegistrationId: _pharmacyRegIdController.text.trim(),
        pharmacyMedicationDetails: _medicationDetailsController.text.trim(),
        priceInSAR: price,
      );

      widget.prescriptionData['pharmacyRegistrationId'] = _pharmacyRegIdController.text.trim();
      widget.prescriptionData['pharmacyMedicationDetails'] = _medicationDetailsController.text.trim();
      widget.prescriptionData['priceInSAR'] = price;
      widget.prescriptionData['status'] = 'expired';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('pharmacy_details_updated')),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _isPharmacyFormVisible = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      widget.prescriptionData['medicationDetails'] ??
                          AppLocalizations.of(context).translate('unknown_medication'),
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
                              prescriptionStatus == 'expired' ? AppLocalizations.of(context).translate('received_caps') : AppLocalizations.of(context).translate('expired_caps'),
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
                              daysUntilExpiry == 0 ? AppLocalizations.of(context).translate('expires_today_caps') : '${AppLocalizations.of(context).translate('expires_in_caps')} $daysUntilExpiry ${AppLocalizations.of(context).translate('days_short').toUpperCase()}',
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
                              AppLocalizations.of(context).translate('active_caps'),
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
                AppLocalizations.of(context).translate('issued_date'),
                DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode).format(createdAt),
              ),
              _buildInfoItem(
                Icons.access_time_outlined,
                AppLocalizations.of(context).translate('valid_until'),
                DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode).format(expiryDate),
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
                AppLocalizations.of(context).translate('medication_details'),
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailItem(AppLocalizations.of(context).translate('medication'),
              widget.prescriptionData['medicationDetails'] ?? AppLocalizations.of(context).translate('not_specified')),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).translate('dosage_instructions'),
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
              widget.prescriptionData['dosageInstructions'] ??
                  AppLocalizations.of(context).translate('no_instructions_provided'),
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
                AppLocalizations.of(context).translate('prescribed_by'),
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
                      '${AppLocalizations.of(context).translate('dr_prefix')} ${widget.prescriptionData['doctorName'] ?? AppLocalizations.of(context).translate('unknown_doctor')}',
                      style: AppTheme.subheadingStyle.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.prescriptionData['doctorSpecialty'] ?? AppLocalizations.of(context).translate('general_medicine'),
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
                            AppLocalizations.of(context).translate('verified_doctor'),
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
                AppLocalizations.of(context).translate('prescription_validity'),
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
                      AppLocalizations.of(context).translate('issued_date'),
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).languageCode).format(createdAt),
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
                      AppLocalizations.of(context).translate('expiry_date'),
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).languageCode).format(expiryDate),
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
                        ? prescriptionStatus == 'expired'
                            ? AppLocalizations.of(context).translate('prescription_received_msg')
                            : AppLocalizations.of(context).translate('prescription_expired_msg')
                        : isExpiringSoon
                            ? daysUntilExpiry == 0 ? AppLocalizations.of(context).translate('prescription_expires_today_msg') : '${AppLocalizations.of(context).translate('prescription_expires_in_msg')} $daysUntilExpiry ${AppLocalizations.of(context).translate('days')}'
                            : '${AppLocalizations.of(context).translate('prescription_valid_for_msg')} $daysUntilExpiry ${AppLocalizations.of(context).translate('days')}',
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
                AppLocalizations.of(context).translate('important_notes'),
                style: AppTheme.subheadingStyle.copyWith(
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNoteItem(
            Icons.warning_amber_rounded,
            AppLocalizations.of(context).translate('note_medication_exactly'),
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.access_time,
            AppLocalizations.of(context).translate('note_full_course'),
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.child_care,
            AppLocalizations.of(context).translate('note_children'),
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.thermostat,
            AppLocalizations.of(context).translate('note_store_room_temp'),
          ),
          const SizedBox(height: 12),
          _buildNoteItem(
            Icons.phone,
            AppLocalizations.of(context).translate('note_contact_doctor'),
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
