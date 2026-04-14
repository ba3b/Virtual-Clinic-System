import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/components/custom_bottom_nav.dart';
import 'package:virtual_clinic_system/components/doctor_selector_dialog.dart';
import 'package:virtual_clinic_system/components/notification_badge.dart';
import 'package:virtual_clinic_system/components/section_header.dart';
import 'package:virtual_clinic_system/components/staff_appointment_card.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';
import 'package:virtual_clinic_system/localization/app_localizations.dart';

import 'appointments_screen.dart';
import 'profile_screen.dart';
import 'staff_notifications_screen.dart';
import 'vaccination_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({Key? key}) : super(key: key);

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserId?>(context, listen: false);
    _databaseService = DatabaseService(uid: user?.uid ?? '');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: l10n.translate('dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today_rounded),
            label: l10n.translate('appointments'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.healing_outlined),
            activeIcon: const Icon(Icons.healing),
            label: l10n.translate('vaccination'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: l10n.translate('profile'),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return const StaffAppointmentsScreen();
      case 2:
        return const VaccinationScreen();
      case 3:
        return const StaffProfileScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NotificationBadge(
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppTheme.primaryColor, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StaffNotificationsScreen()),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const StaffNotificationsScreen()),
                    );
                  },
                ),
              ),
            ),
            _buildStaffInfo(),
            const SizedBox(height: 32),
            StreamBuilder<List<AppointmentModel>>(
              stream: _databaseService.getPendingAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final pendingAppointments = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: AppLocalizations.of(context).translate('pending_appointments'),
                      subtitle: AppLocalizations.of(context).translate('need_verification'),
                      actionText:
                          pendingAppointments.isEmpty ? null : AppLocalizations.of(context).translate('see_all'),
                      onActionTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAppointmentsList(pendingAppointments),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffInfo() {
    final user = Provider.of<UserId?>(context);

    return FutureBuilder<UserModel>(
        future: _databaseService.getUserDetails(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No user data found'));
          }

          final UserModel currentUser = snapshot.data!;

          if (!currentUser.isStaff) {
            return const Center(
                child: Text('Error: Only staff can access this page'));
          }

          final StaffModel staff = currentUser as StaffModel;

          return StreamBuilder<List<AppointmentModel>>(
            stream: _databaseService.getPendingAppointments(),
            builder: (context, appointmentSnapshot) {
              final pendingCount = appointmentSnapshot.data?.length ?? 0;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('welcome_user').replaceAll('{name}', staff.name),
                            style: AppTheme.subheadingStyle.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context).translate('staff_administrator'),
                            style: AppTheme.bodyStyle.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.pending_actions,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$pendingCount ${AppLocalizations.of(context).translate('pending_appointments')}',
                                  style: AppTheme.bodySmallStyle.copyWith(
                                    color: Colors.white,
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
              );
            },
          );
        });
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 50,
                  color: AppTheme.primaryColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).translate('no_pending'),
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).translate('all_processed'),
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FutureBuilder<UserModel>(
            future: _databaseService.getUserDetails(appointment.patientId),
            builder: (context, patientSnapshot) {
              final patientName = patientSnapshot.data?.name ?? 'Loading...';

              return FutureBuilder<UserModel?>(
                future: appointment.doctorId != null
                    ? _databaseService.getUserDetails(appointment.doctorId!)
                    : Future.value(null),
                builder: (context, doctorSnapshot) {
                  final doctorName = doctorSnapshot.data?.name;

                  return StaffAppointmentCard(
                    appointment: appointment,
                    patientName: patientName,
                    doctorName: doctorName,
                    onTap: () => _navigateToAppointmentDetails(appointment),
                    onAssignDoctor:
                        appointment.type != AppointmentModel.typeVaccination
                            ? () => _showDoctorAssignmentDialog(appointment)
                            : null,
                    onVerify:
                        appointment.type == AppointmentModel.typeVaccination
                            ? () => _verifyVaccinationAppointment(appointment)
                            : null,
                    onReject: () => _showRejectConfirmationDialog(appointment),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToAppointmentDetails(AppointmentModel appointment) {}

  Future<void> _showDoctorAssignmentDialog(AppointmentModel appointment) async {
    try {
      final filteredDoctors = await _getFilteredDoctors(appointment);

      if (filteredDoctors.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).translate('no_available_doctors')),
            content: Text(
              AppLocalizations.of(context).translate('no_doctors_found'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).translate('close')),
              ),
            ],
          ),
        );
        return;
      }

      final scaffoldMessenger = ScaffoldMessenger.of(context);

      showDialog(
        context: context,
        builder: (context) => DoctorSelectorDialog(
          doctors: filteredDoctors,
          requiredSpecialty: appointment.department,
          onDoctorSelected: (doctor) async {
            Navigator.pop(context);

            try {
              await _databaseService.assignDoctorToAppointment(
                  appointment.appointmentId, doctor.userId);

              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).translate('doctor_assigned_success')),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context).translate('error')}: $e'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading doctors: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _verifyVaccinationAppointment(
      AppointmentModel appointment) async {
    try {
      await _databaseService.updateAppointmentStatus(
          appointment.appointmentId, AppointmentModel.statusApproved);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('vaccination_verified')),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).translate('error')}: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<List<DoctorModel>> _getFilteredDoctors(
      AppointmentModel appointment) async {
    if (appointment.type.toLowerCase() == 'vaccination') {
      return await _databaseService.getAllDoctors();
    }

    if (appointment.department != null) {
      return await _databaseService
          .getDoctorsBySpecialty(appointment.department!);
    }

    return await _databaseService.getAllDoctors();
  }

  void _showRejectConfirmationDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.errorColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context).translate('reject_appointment')),
          ],
        ),
        content: Text(
          AppLocalizations.of(context).translate('reject_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await _databaseService.updateAppointmentStatus(
                  appointment.appointmentId,
                  AppointmentModel.statusRejected,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).translate('appointment_rejected')),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${AppLocalizations.of(context).translate('error')}: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).translate('reject')),
          ),
        ],
      ),
    );
  }
}
