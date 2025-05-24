import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/components/custom_app_bar.dart';
import 'package:virtual_clinic_system/components/doctor_selector_dialog.dart';
import 'package:virtual_clinic_system/components/staff_appointment_card.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';

class StaffAppointmentsScreen extends StatefulWidget {
  const StaffAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<StaffAppointmentsScreen> createState() =>
      _StaffAppointmentsScreenState();
}

class _StaffAppointmentsScreenState extends State<StaffAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final user = Provider.of<UserId?>(context, listen: false);
    _databaseService = DatabaseService(uid: user?.uid ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppointmentModel> _filterAppointmentsByType(
      List<AppointmentModel> appointments, String type) {
    return appointments
        .where((appointment) =>
            appointment.type.toLowerCase() == type.toLowerCase() &&
            appointment.status.toLowerCase() == 'pending')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Appointments',
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
                fontSize: 12, // Smaller font
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12, // Smaller font
              ),
              isScrollable: false,
              tabs: const [
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_rounded, size: 24), // Smaller icon
                      SizedBox(height: 2), // Reduced spacing
                      Text('Virtual',
                          style: TextStyle(fontSize: 14)), // Smaller text
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_rounded, size: 24), // Smaller icon
                      SizedBox(height: 2), // Reduced spacing
                      Text('Physical',
                          style: TextStyle(fontSize: 14)), // Smaller text
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.healing_rounded, size: 24), // Smaller icon
                      SizedBox(height: 2), // Reduced spacing
                      Text('Vaccination',
                          style: TextStyle(
                              fontSize: 14)), // Even smaller for longer text
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _databaseService.getPendingAppointments(),
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
                          'Error loading appointments',
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

                final allPendingAppointments = snapshot.data ?? [];
                final virtualAppointments = _filterAppointmentsByType(
                    allPendingAppointments, 'virtual');
                final physicalAppointments = _filterAppointmentsByType(
                    allPendingAppointments, 'physical');
                final vaccinationAppointments = _filterAppointmentsByType(
                    allPendingAppointments, 'vaccination');

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(virtualAppointments, 'virtual'),
                    _buildAppointmentsList(physicalAppointments, 'physical'),
                    _buildAppointmentsList(
                        vaccinationAppointments, 'vaccination'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(
      List<AppointmentModel> appointments, String type) {
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
                  _getTypeIcon(type),
                  size: 50,
                  color: AppTheme.primaryColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No pending ${type.toLowerCase()} appointments',
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                type == 'vaccination'
                    ? 'All vaccination appointments have been processed'
                    : 'All ${type.toLowerCase()} appointments have been assigned doctors',
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
                    onTap: () {
                      // You can implement navigation to appointment details if needed
                    },
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

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'virtual':
        return Icons.videocam_rounded;
      case 'physical':
        return Icons.person_rounded;
      case 'vaccination':
        return Icons.healing_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Future<void> _showDoctorAssignmentDialog(AppointmentModel appointment) async {
    try {
      final filteredDoctors = await _getFilteredDoctors(appointment);

      if (filteredDoctors.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Available Doctors'),
            content: Text(
              'No doctors found for ${appointment.department ?? appointment.type} specialty.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        return;
      }

      // Get the ScaffoldMessenger reference before showing the dialog
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      showDialog(
        context: context,
        builder: (context) => DoctorSelectorDialog(
          doctors: filteredDoctors,
          requiredSpecialty: appointment.department,
          onDoctorSelected: (doctor) async {
            // Close the dialog first
            Navigator.pop(context);
            
            try {
              await _databaseService.assignDoctorToAppointment(
                  appointment.appointmentId, doctor.userId);

              // Use the stored ScaffoldMessenger reference
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content:
                      Text('Doctor "${doctor.name}" assigned successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            } catch (e) {
              // Use the stored ScaffoldMessenger reference
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Error assigning doctor: $e'),
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
          const SnackBar(
            content: Text('Vaccination appointment verified successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying appointment: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<List<DoctorModel>> _getFilteredDoctors(
      AppointmentModel appointment) async {
    // For vaccination appointments, return all doctors
    if (appointment.type.toLowerCase() == 'vaccination') {
      return await _databaseService.getAllDoctors();
    }

    // For other appointments, filter by specialty matching department
    if (appointment.department != null) {
      return await _databaseService
          .getDoctorsBySpecialty(appointment.department!);
    }

    // Fallback to all doctors if no department specified
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
          children: const [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.errorColor,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Reject Appointment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to reject this appointment? The patient will be notified of the rejection.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: AppTheme.bodySmallStyle.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
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
                    const SnackBar(
                      content: Text('Appointment rejected successfully'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error rejecting appointment: $e'),
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
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}