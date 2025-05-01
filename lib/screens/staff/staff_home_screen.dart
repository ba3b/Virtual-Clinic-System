import 'package:flutter/material.dart';
import 'package:virtual_clinic_system/components/appointment_edit_dialog.dart';
import 'package:virtual_clinic_system/components/custom_app_bar.dart';
import 'package:virtual_clinic_system/components/custom_bottom_nav.dart';
import 'package:virtual_clinic_system/components/doctor_selector_dialog.dart';
import 'package:virtual_clinic_system/components/notification_badge.dart';
import 'package:virtual_clinic_system/components/section_header.dart';
import 'package:virtual_clinic_system/components/staff_appointment_card.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';

import 'appointment_details_screen.dart';
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

  final List<AppointmentModel> _pendingAppointments = [
    AppointmentModel(
      appointmentId: '101',
      patientId: 'P101',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      type: 'virtual',
      status: 'pending',
    ),
    AppointmentModel(
      appointmentId: '102',
      patientId: 'P102',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
      type: 'physical',
      status: 'pending',
    ),
    AppointmentModel(
      appointmentId: '103',
      patientId: 'P103',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      type: 'vaccination',
      status: 'pending',
    ),
  ];

  final List<AppointmentModel> _verifiedAppointments = [
    AppointmentModel(
      appointmentId: '104',
      patientId: 'P104',
      doctorId: 'D001',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      type: 'virtual',
      status: 'upcoming',
    ),
    AppointmentModel(
      appointmentId: '105',
      patientId: 'P105',
      doctorId: 'D002',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      type: 'physical',
      status: 'upcoming',
    ),
  ];

  final Map<String, String> _patientNames = {
    'P101': 'Abdullah Ahmed',
    'P102': 'Sarah Mohammed',
    'P103': 'Khalid Ibrahim',
    'P104': 'Lina Saleh',
    'P105': 'Omar Hassan',
  };

  final Map<String, String> _doctorNames = {
    'D001': 'Dr. Mohammed Hussein',
    'D002': 'Dr. Fatima Abdullah',
  };

  final List<DoctorModel> _availableDoctors = [
    DoctorModel(
      userId: 'D001',
      name: 'Dr. Mohammed Hussein',
      email: 'mohammed@example.com',
      phoneNumber: '+966 50 123 4567',
      address: 'Taif',
      specialty: 'General Medicine',
    ),
    DoctorModel(
      userId: 'D002',
      name: 'Dr. Fatima Abdullah',
      email: 'fatima@example.com',
      phoneNumber: '+966 50 234 5678',
      address: 'Taif',
      specialty: 'Pediatrics',
    ),
    DoctorModel(
      userId: 'D003',
      name: 'Dr. Ahmed Ali',
      email: 'ahmed@example.com',
      phoneNumber: '+966 50 345 6789',
      address: 'Taif',
      specialty: 'Cardiology',
    ),
    DoctorModel(
      userId: 'D004',
      name: 'Dr. Noura Saeed',
      email: 'noura@example.com',
      phoneNumber: '+966 50 456 7890',
      address: 'Taif',
      specialty: 'Dermatology',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Staff Dashboard',
        backgroundColor: AppTheme.primaryColor,
        showBackButton: false,
        actions: [
          NotificationBadge(
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StaffNotificationsScreen()),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StaffNotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing_outlined),
            activeIcon: Icon(Icons.healing),
            label: 'Vaccination',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStaffInfo(),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Quick Actions',
            subtitle: 'Manage appointments and patients',
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Pending Appointments',
            subtitle: 'Appointments that need verification',
            actionText: _pendingAppointments.isEmpty ? null : 'See All',
            onActionTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildAppointmentsList(_pendingAppointments, true),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Verified Appointments',
            subtitle: 'Upcoming approved appointments',
            actionText: _verifiedAppointments.isEmpty ? null : 'See All',
            onActionTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildAppointmentsList(_verifiedAppointments, false),
        ],
      ),
    );
  }

  Widget _buildStaffInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Sarah',
                  style: AppTheme.subheadingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Staff Administrator',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoPill('Pending', '${_pendingAppointments.length}'),
                    _buildInfoPill('Today', '3'),
                    _buildInfoPill('Vaccinations', '12'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String label, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.bodySmallStyle.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: AppTheme.bodySmallStyle.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionButton(
          'Verify\nAppointments',
          Icons.check_circle_outline,
          Colors.blue,
          () {
            setState(() {
              _selectedIndex = 1;
            });
          },
        ),
        _buildQuickActionButton(
          'Assign\nDoctors',
          Icons.person_add_alt_1_outlined,
          Colors.orange,
          () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Appointment'),
                content: const Text(
                    'Please select an appointment to assign a doctor.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        _buildQuickActionButton(
          'Update\nVaccinations',
          Icons.healing_outlined,
          Colors.green,
          () {
            setState(() {
              _selectedIndex = 2;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodySmallStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(
      List<AppointmentModel> appointments, bool isPending) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                isPending
                    ? 'No pending appointments'
                    : 'No verified appointments',
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
        final patientName =
            _patientNames[appointment.patientId] ?? 'Unknown Patient';
        final doctorName = appointment.doctorId != null
            ? _doctorNames[appointment.doctorId]
            : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: StaffAppointmentCard(
            appointment: appointment,
            patientName: patientName,
            doctorName: doctorName,
            onTap: () => _navigateToAppointmentDetails(appointment),
            onAssignDoctor: isPending
                ? () => _showDoctorAssignmentDialog(appointment)
                : null,
            onVerify: isPending ? () => _verifyAppointment(appointment) : null,
            onEdit: isPending
                ? () => _showAppointmentEditDialog(appointment)
                : null,
            onDelete: isPending
                ? () => _showDeleteConfirmationDialog(appointment)
                : null,
          ),
        );
      },
    );
  }

  void _navigateToAppointmentDetails(AppointmentModel appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffAppointmentDetailsScreen(
          appointment: appointment,
          patientName:
              _patientNames[appointment.patientId] ?? 'Unknown Patient',
          doctorName: appointment.doctorId != null
              ? _doctorNames[appointment.doctorId]
              : null,
          availableDoctors: _availableDoctors,
        ),
      ),
    );
  }

  void _showDoctorAssignmentDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => DoctorSelectorDialog(
        doctors: _availableDoctors,
        onDoctorSelected: (doctor) {
          final updatedAppointment = appointment.copyWith(
            doctorId: doctor.userId,
            status: 'upcoming',
          );

          _updateAppointment(updatedAppointment);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor "${doctor.name}" assigned successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
      ),
    );
  }

  void _verifyAppointment(AppointmentModel appointment) {
    if (appointment.type.toLowerCase() == 'vaccination') {
      final updatedAppointment = appointment.copyWith(
        status: 'upcoming',
      );

      _updateAppointment(updatedAppointment);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaccination appointment verified successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      _showDoctorAssignmentDialog(appointment);
    }
  }

  void _showAppointmentEditDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditDialog(
        appointment: appointment,
        onAppointmentUpdated: (newDateTime) {
          final updatedAppointment = appointment.copyWith(
            dateTime: newDateTime,
          );

          _updateAppointment(updatedAppointment);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text(
          'Are you sure you want to delete this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              setState(() {
                _pendingAppointments.removeWhere(
                    (a) => a.appointmentId == appointment.appointmentId);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment deleted successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateAppointment(AppointmentModel updatedAppointment) {
    setState(() {
      if (updatedAppointment.status != 'pending') {
        _pendingAppointments.removeWhere(
            (a) => a.appointmentId == updatedAppointment.appointmentId);
        _verifiedAppointments.add(updatedAppointment);
      } else {
        final index = _pendingAppointments.indexWhere(
            (a) => a.appointmentId == updatedAppointment.appointmentId);
        if (index != -1) {
          _pendingAppointments[index] = updatedAppointment;
        }
      }
    });
  }
}
