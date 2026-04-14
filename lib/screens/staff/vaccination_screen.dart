import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/components/custom_app_bar.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';
import 'package:virtual_clinic_system/localization/app_localizations.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DatabaseService _databaseService;
  final Map<String, TextEditingController> _vaccineTypeControllers =
      {}; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final user = Provider.of<UserId?>(context, listen: false);
    _databaseService = DatabaseService(uid: user?.uid ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _vaccineTypeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<AppointmentModel> _filterTodayVaccinations(
      List<AppointmentModel> appointments) {
    final today = DateTime.now();
    return appointments.where((appointment) {
      return appointment.type.toLowerCase() == 'vaccination' &&
          appointment.status.toLowerCase() == 'approved' &&
          isSameDay(appointment.dateTime, today);
    }).toList();
  }

  List<AppointmentModel> _filterCompletedVaccinations(
      List<AppointmentModel> appointments) {
    final today = DateTime.now();
    return appointments.where((appointment) {
      return appointment.type.toLowerCase() == 'vaccination' &&
          appointment.status.toLowerCase() == 'completed' &&
          isSameDay(appointment.dateTime, today);
    }).toList();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('manage_vaccinations'),
        backgroundColor: AppTheme.primaryColor,
        showBackButton: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.today_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context).translate('today')),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context).translate('completed')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _databaseService.getVaccinationAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading vaccinations',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: AppTheme.errorColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allVaccinations = snapshot.data ?? [];
                final todayVaccinations =
                    _filterTodayVaccinations(allVaccinations);
                final completedVaccinations =
                    _filterCompletedVaccinations(allVaccinations);

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVaccinationsList(todayVaccinations, true),
                    _buildVaccinationsList(completedVaccinations, false),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationsList(
      List<AppointmentModel> appointments, bool isToday) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isToday ? Icons.today_rounded : Icons.check_circle_rounded,
                  size: 50,
                  color: AppTheme.primaryColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isToday
                    ? AppLocalizations.of(context).translate('no_vaccinations_today')
                    : AppLocalizations.of(context).translate('no_completed_vaccinations'),
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isToday
                    ? AppLocalizations.of(context).translate('all_vaccinations_completed')
                    : AppLocalizations.of(context).translate('completed_vaccinations_appear_here'),
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FutureBuilder<UserModel>(
            future: _databaseService.getUserDetails(appointment.patientId),
            builder: (context, patientSnapshot) {
              final patient = patientSnapshot.data;

              return _buildVaccinationCard(appointment, patient, isToday);
            },
          ),
        );
      },
    );
  }

  Widget _buildVaccinationCard(
      AppointmentModel appointment, UserModel? patient, bool isToday) {
    final Color cardColor =
        isToday ? AppTheme.primaryColor : AppTheme.successColor;

    if (!_vaccineTypeControllers.containsKey(appointment.appointmentId)) {
      _vaccineTypeControllers[appointment.appointmentId] =
          TextEditingController();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetailsDialog(appointment, patient),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.healing_rounded,
                      color: cardColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient?.name ?? 'Loading...',
                          style: AppTheme.subheadingStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (appointment.vaccinationType != null)
                          Text(
                            'Vaccine: ${appointment.vaccinationType}',
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cardColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isToday ? AppLocalizations.of(context).translate('today') : AppLocalizations.of(context).translate('completed'),
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(appointment.dateTime),
                          style: AppTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('hh:mm a').format(appointment.dateTime),
                          style: AppTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isToday) ...[
                const SizedBox(height: 20),
                TextField(
                  controller:
                      _vaccineTypeControllers[appointment.appointmentId],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('actual_vaccine_type'),
                    hintText: AppLocalizations.of(context).translate('vaccine_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.primaryColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.medical_services,
                        color: AppTheme.primaryColor),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                  ),
                  style: AppTheme.bodyStyle,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsCompleted(appointment),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(AppLocalizations.of(context).translate('mark_completed')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetailsDialog(
      AppointmentModel appointment, UserModel? patient) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.healing_rounded,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('vaccination_details'),
                            style: AppTheme.headingStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${AppLocalizations.of(context).translate('appointment_id')}: ${appointment.appointmentId}',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.backgroundColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(AppLocalizations.of(context).translate('patient_name'),
                          patient?.name ?? 'Loading...', Icons.person),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          AppLocalizations.of(context).translate('email'), patient?.email ?? 'Loading...', Icons.email),
                      const SizedBox(height: 12),
                      _buildDetailRow(AppLocalizations.of(context).translate('phone'),
                          patient?.phoneNumber ?? 'Loading...', Icons.phone),
                      const SizedBox(height: 12),
                      _buildDetailRow(AppLocalizations.of(context).translate('address'),
                          patient?.address ?? 'Loading...', Icons.location_on),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                          AppLocalizations.of(context).translate('vaccine_type'),
                          appointment.vaccinationType ?? 'Not specified',
                          Icons.healing),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          AppLocalizations.of(context).translate('date'),
                          DateFormat('EEEE, MMMM dd, yyyy')
                              .format(appointment.dateTime),
                          Icons.calendar_today),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          AppLocalizations.of(context).translate('time'), // I assume 'time' maps correctly or use raw translated
                          DateFormat('hh:mm a').format(appointment.dateTime),
                          Icons.access_time),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          AppLocalizations.of(context).translate('status'),
                          appointment.status[0].toUpperCase() +
                              appointment.status.substring(1),
                          Icons.info),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      AppLocalizations.of(context).translate('close'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTheme.bodySmallStyle.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markAsCompleted(AppointmentModel appointment) async {
    final controller = _vaccineTypeControllers[appointment.appointmentId];
    final actualVaccineType = controller?.text.trim() ?? '';
    if (actualVaccineType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('enter_actual_vaccine')),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      await _databaseService.updateAppointmentStatus(
        appointment.appointmentId,
        AppointmentModel.statusCompleted,
      );

      await _databaseService.createVaccinationRecord(
        appointmentId: appointment.appointmentId,
        patientId: appointment.patientId,
        vaccineType: appointment.vaccinationType ?? 'Unknown',
        actualVaccineType: actualVaccineType, 
      );

      controller?.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('vaccination_completed_success')),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).translate('error_colon')} $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
