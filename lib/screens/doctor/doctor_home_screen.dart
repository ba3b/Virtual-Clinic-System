import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/components/custom_bottom_nav.dart';
import 'package:virtual_clinic_system/components/doctor_appointment_card.dart';
import 'package:virtual_clinic_system/components/notification_badge.dart';
import 'package:virtual_clinic_system/components/section_header.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';

import 'appointment_details_screen.dart';
import 'appointmens_screen.dart';
import 'doctor_notifications_screen.dart';
import 'profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;
  final Map<String, String> _patientNames = {};
  bool _isLoading = false;
  List<String> _processedAppointmentIds = [];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _checkForNewAppointments(List<AppointmentModel> appointments) {
    if (_isLoading) return;

    final List<AppointmentModel> newAppointments =
        appointments.where((appointment) {
      return !_processedAppointmentIds.contains(appointment.appointmentId) &&
          !_patientNames.containsKey(appointment.patientId);
    }).toList();

    if (newAppointments.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchPatientNames(newAppointments);
      });
    }
  }

  Future<void> _fetchPatientNames(List<AppointmentModel> appointments) async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    Map<String, String> updatedNames = Map.from(_patientNames);
    List<String> processedIds = List.from(_processedAppointmentIds);

    for (var appointment in appointments) {
      processedIds.add(appointment.appointmentId);

      if (!updatedNames.containsKey(appointment.patientId)) {
        try {
          final patientData = await DatabaseService(uid: appointment.patientId)
              .getUserDetails(appointment.patientId);

          updatedNames[appointment.patientId] = patientData.name;
        } catch (e) {
          print('Error fetching patient name: $e');
          updatedNames[appointment.patientId] = 'Unknown Patient';
        }
      }
    }

    if (mounted) {
      setState(() {
        _patientNames.addAll(updatedNames);
        _processedAppointmentIds = processedIds;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            activeIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
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
        return const AppointmentsViewScreen();
      case 2:
        return const DoctorProfileScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    final user = Provider.of<UserId?>(context);
    if (user == null) {
      return const Center(child: Text('User not found. Please log in again.'));
    }

    return StreamBuilder<UserModel>(
      stream: DatabaseService(uid: user.uid).getUserStream(user.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Center(
              child: Text('Error loading user data: ${userSnapshot.error}'));
        }

        if (!userSnapshot.hasData) {
          return const Center(child: Text('No user data found'));
        }

        final UserModel currentUser = userSnapshot.data!;

        if (!currentUser.isDoctor) {
          return const Center(
              child: Text('Error: Only doctors can access this page'));
        }

        final DoctorModel doctor = currentUser as DoctorModel;

        return StreamBuilder<List<AppointmentModel>>(
          stream:
              DatabaseService(uid: user.uid).getDoctorAppointments(user.uid),
          builder: (context, appointmentSnapshot) {
            if (appointmentSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (appointmentSnapshot.hasError) {
              return Center(
                  child: Text(
                      'Error loading appointments: ${appointmentSnapshot.error}'));
            }

            final List<AppointmentModel> allAppointments =
                appointmentSnapshot.data ?? [];

            _checkForNewAppointments(allAppointments);

            final List<AppointmentModel> todayAppointments = [];
            final List<AppointmentModel> upcomingAppointments = [];

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            for (var appointment in allAppointments) {
              if (appointment.status != AppointmentModel.statusApproved) {
                continue;
              }
              final appointmentDate = DateTime(
                appointment.dateTime.year,
                appointment.dateTime.month,
                appointment.dateTime.day,
              );
              if (appointmentDate.isAtSameMomentAs(today)) {
                todayAppointments.add(appointment);
              } else if (appointmentDate.isAfter(today)) {
                upcomingAppointments.add(appointment);
              }
            }

            todayAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
            upcomingAppointments
                .sort((a, b) => a.dateTime.compareTo(b.dateTime));

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
                            icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
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
                      ),
                    ),
                    _buildDoctorInfoWidget(doctor, todayAppointments.length,
                        upcomingAppointments.length),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Today\'s Appointments',
                      subtitle: 'Your schedule for today',
                      actionText: todayAppointments.isEmpty ? null : 'See All',
                      onActionTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAppointmentsList(todayAppointments),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Upcoming Appointments',
                      subtitle: 'Your future schedule',
                      actionText: upcomingAppointments.isEmpty ? null : 'See All',
                      onActionTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAppointmentsList(upcomingAppointments),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorInfoWidget(
      DoctorModel doctor, int todayCount, int upcomingCount) {
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
                  'Dr. ${doctor.name}',
                  style: AppTheme.subheadingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatCard('Today', '$todayCount'),
                    const SizedBox(width: 16),
                    _buildStatCard('Upcoming', '$upcomingCount'),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            _patientNames[appointment.patientId] ?? 'Loading...';

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
