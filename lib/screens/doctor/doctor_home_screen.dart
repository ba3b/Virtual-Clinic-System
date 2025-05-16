import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_clinic_system/components/custom_bottom_nav.dart';
import 'package:virtual_clinic_system/components/doctor_appointment_card.dart';
import 'package:virtual_clinic_system/components/notification_badge.dart';
import 'package:virtual_clinic_system/components/section_header.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';

import 'appointment_details_screen.dart';
import 'appointment_history_screen.dart';
import 'doctor_notifications_screen.dart';
import 'profile_screen.dart';
import 'virtual_appointment_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  final List<AppointmentModel> _todayAppointments = [
    AppointmentModel(
      appointmentId: '1',
      patientId: 'P001',
      doctorId: 'D001',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      type: 'virtual',
      status: 'upcoming',
    ),
    AppointmentModel(
      appointmentId: '2',
      patientId: 'P002',
      doctorId: 'D001',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      type: 'physical',
      status: 'upcoming',
    ),
  ];

  final List<AppointmentModel> _upcomingAppointments = [
    AppointmentModel(
      appointmentId: '3',
      patientId: 'P003',
      doctorId: 'D001',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      type: 'virtual',
      status: 'upcoming',
    ),
    AppointmentModel(
      appointmentId: '4',
      patientId: 'P004',
      doctorId: 'D001',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      type: 'physical',
      status: 'upcoming',
    ),
    AppointmentModel(
      appointmentId: '5',
      patientId: 'P005',
      doctorId: 'D001',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      type: 'vaccination',
      status: 'upcoming',
    ),
  ];

  final Map<String, String> _patientNames = {
    'P001': 'Ahmed Ali',
    'P002': 'Fatima Mohammed',
    'P003': 'Khalid Saeed',
    'P004': 'Sara Abdullah',
    'P005': 'Omar Ibrahim',
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Doctor Dashboard'),
        actions: [
          NotificationBadge(
            child: IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DoctorNotificationsScreen()),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DoctorNotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.dividerColor,
              child: Icon(
                Icons.logout_rounded,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
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
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
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
        return const AppointmentHistoryScreen();
      case 2:
        return const DoctorProfileScreen();
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
          _buildDoctorInfo(),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Today\'s Appointments',
            subtitle: 'Your schedule for today',
            actionText: _todayAppointments.isEmpty ? null : 'See All',
            onActionTap: () {},
          ),
          const SizedBox(height: 16),
          _buildAppointmentsList(_todayAppointments),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Upcoming Appointments',
            subtitle: 'Your future schedule',
            actionText: _upcomingAppointments.isEmpty ? null : 'See All',
            onActionTap: () {},
          ),
          const SizedBox(height: 16),
          _buildAppointmentsList(_upcomingAppointments),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return SafeArea(
      child: Container(
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
                    'Dr. Mohammed Hussein',
                    style: AppTheme.subheadingStyle.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'General Medicine',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatCard('Today', '${_todayAppointments.length}'),
                      const SizedBox(width: 16),
                      _buildStatCard(
                          'Upcoming', '${_upcomingAppointments.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTheme.bodySmallStyle.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count,
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No appointments',
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DoctorAppointmentCard(
            appointment: appointment,
            patientName: patientName,
            onTap: () => _navigateToAppointmentDetails(appointment),
          ),
        );
      },
    );
  }

  void _navigateToAppointmentDetails(AppointmentModel appointment) {
    if (appointment.type.toLowerCase() == 'virtual' &&
        appointment.status.toLowerCase() == 'upcoming') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorVirtualAppointmentScreen(
            appointment: appointment,
            patientName:
                _patientNames[appointment.patientId] ?? 'Unknown Patient',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorAppointmentDetailsScreen(
            appointment: appointment,
            patientName:
                _patientNames[appointment.patientId] ?? 'Unknown Patient',
          ),
        ),
      );
    }
  }
}
