import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/components/custom_app_bar.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DatabaseService _databaseService;

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
      appBar: const CustomAppBar(
        title: 'Vaccination Management',
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
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.today_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Today'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Completed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _databaseService
                  .getVaccinationAppointments(), // You'll need to add this method
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
                    ? 'No vaccinations scheduled for today'
                    : 'No completed vaccinations',
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isToday
                    ? 'All today\'s vaccinations have been completed'
                    : 'Completed vaccinations will appear here',
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
                      isToday ? 'Today' : 'Completed',
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
                        Icon(
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
                        Icon(
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsCompleted(appointment),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Mark as Completed'),
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
                      child: Icon(
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
                            'Vaccination Details',
                            style: AppTheme.headingStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Appointment ID: ${appointment.appointmentId}',
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
                      _buildDetailRow('Patient Name',
                          patient?.name ?? 'Loading...', Icons.person),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          'Email', patient?.email ?? 'Loading...', Icons.email),
                      const SizedBox(height: 12),
                      _buildDetailRow('Phone',
                          patient?.phoneNumber ?? 'Loading...', Icons.phone),
                      const SizedBox(height: 12),
                      _buildDetailRow('Address',
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
                          'Vaccine Type',
                          appointment.vaccinationType ?? 'Not specified',
                          Icons.healing),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          'Date',
                          DateFormat('EEEE, MMMM dd, yyyy')
                              .format(appointment.dateTime),
                          Icons.calendar_today),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          'Time',
                          DateFormat('hh:mm a').format(appointment.dateTime),
                          Icons.access_time),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          'Status',
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
                    child: const Text(
                      'Close',
                      style: TextStyle(
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
    try {
      await _databaseService.updateAppointmentStatus(
        appointment.appointmentId,
        AppointmentModel.statusCompleted,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination marked as completed successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking vaccination as completed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
