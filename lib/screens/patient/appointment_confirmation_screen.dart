import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../localization/app_localizations.dart';
import '../../constants/departments.dart';
import '../../constants/vaccinations.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentConfirmationScreen({
    Key? key,
    required this.appointmentData,
  }) : super(key: key);

  String _formatDateTime() {
    final date = appointmentData['appointmentDate'] as DateTime;
    final time = appointmentData['appointmentTime'] as String;
    
    return '${date.day}/${date.month}/${date.year} at $time';
  }

  String _getAppointmentTitle(BuildContext context) {
    final type = appointmentData['appointmentType'] as String;
    
    if (type == 'vaccination') {
      return '${AppLocalizations.of(context).translate('vaccination')}: ${AppLocalizations.of(context).translate(VaccinationConstants.getTranslationKey(appointmentData['vaccinationType']))}';
    } else if (type == 'virtual') {
      return '${AppLocalizations.of(context).translate('virtual')}: ${AppLocalizations.of(context).translate(DepartmentConstants.getTranslationKey(appointmentData['department']))}';
    } else {
      return '${AppLocalizations.of(context).translate('physical')}: ${AppLocalizations.of(context).translate(DepartmentConstants.getTranslationKey(appointmentData['department']))}';
    }
  }

  Widget _buildAppointmentDetails(BuildContext context) {
    final iconData = appointmentData['appointmentType'] == 'virtual'
        ? Icons.videocam_rounded
        : appointmentData['appointmentType'] == 'physical'
            ? Icons.person_rounded
            : Icons.healing_rounded;

    final iconColor = appointmentData['appointmentType'] == 'virtual'
        ? AppTheme.primaryColor
        : appointmentData['appointmentType'] == 'physical'
            ? Colors.blue
            : Colors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getAppointmentTitle(context),
              style: AppTheme.subheadingStyle.copyWith(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(),
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.amber,
                  width: 1,
                ),
              ),
              child: Text(
                AppLocalizations.of(context).translate('pending_confirmation'),
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).translate('pending_confirmation_desc'),
                    style: AppTheme.bodySmallStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context).translate('appointment_success_booked'),
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).translate('appointment_success_desc'),
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildAppointmentDetails(context),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(AppLocalizations.of(context).translate('back_to_home')),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}