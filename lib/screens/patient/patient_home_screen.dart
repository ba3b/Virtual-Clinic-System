import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/screens/patient/prescription_screen.dart';
import '../../components/appointment_card.dart';
import '../../components/custom_bottom_nav.dart';
import '../../components/notification_badge.dart';
import '../../components/quick_action_button.dart';
import '../../components/section_header.dart';
import '../../theme/theme.dart';
import 'appointment_booking_screen.dart';
import 'appointment_details_screen.dart';
import 'appointments_screen.dart';
import '../notifications_screen.dart';
import 'profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const AppointmentsScreen();
      case 2:
        return const ProfileScreen();
      case 3:
        return const PrescriptionsScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          const SizedBox(height: 24),
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildUpcomingAppointments(),
          const SizedBox(height: 24),
          _buildHealthTips(),
          const SizedBox(
              height: 60), // Extra space at bottom for navigation bar
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Virtual Clinic',
                style: AppTheme.headingStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 20,
                ),
              ),
              const Text(
                'King Faisal Medical Complex',
                style: AppTheme.bodySmallStyle,
              ),
            ],
          ),
          Row(
            children: [
              NotificationBadge(
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final user = Provider.of<UserId?>(context);

    return FutureBuilder<UserModel>(
        future: DatabaseService(uid: user!.uid).getUserDetails(user.uid),
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

          if (!currentUser.isPatient) {
            return const Center(
                child: Text('Error: Only patients can access this page'));
          }

          final PatientModel patient = currentUser as PatientModel;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
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
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${patient.name}!',
                          style: AppTheme.subheadingStyle.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'How are you feeling today?',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppointmentBookingScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Book Appointment'),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Center(
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(
            title: 'Quick Actions',
            subtitle: 'Access common features quickly',
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 8),
              QuickActionButton(
                icon: Icons.videocam_rounded,
                label: 'Virtual \nAppointment',
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                iconColor: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentBookingScreen(
                        initialType: 'virtual',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              QuickActionButton(
                icon: Icons.person_rounded,
                label: 'Physical \nAppointment',
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                iconColor: AppTheme.secondaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentBookingScreen(
                        initialType: 'physical',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              QuickActionButton(
                icon: Icons.healing_rounded,
                label: 'Vaccination',
                backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                iconColor: AppTheme.accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentBookingScreen(
                        initialType: 'vaccination',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              QuickActionButton(
                icon: Icons.description_outlined,
                label: 'Prescriptions',
                backgroundColor: Colors.orange.withOpacity(0.1),
                iconColor: Colors.orange,
                onTap: () {
                  setState(() {
                    _currentIndex = 3; // Switch to prescriptions tab
                  });
                },
              ),
              const SizedBox(width: 16),
              QuickActionButton(
                icon: Icons.history_rounded,
                label: 'Medical History',
                backgroundColor: Colors.purple.withOpacity(0.1),
                iconColor: Colors.purple,
                onTap: () {
                  // Navigate to medical history screen
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments() {
    final user = Provider.of<UserId?>(context);

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(
            title: 'Upcoming Appointments',
            subtitle: 'Your scheduled appointments',
            actionText: 'See All',
            onActionTap: () {
              setState(() {
                _currentIndex = 1; // Switch to appointments tab
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<AppointmentModel>>(
          stream:
              DatabaseService(uid: user.uid).getPatientAppointments(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final appointments = snapshot.data ?? [];

            // Filter for upcoming appointments
            final upcomingAppointments = appointments
                .where((appointment) =>
                    appointment.status != AppointmentModel.statusCancelled &&
                    appointment.status != AppointmentModel.statusRejected &&
                    appointment.dateTime.isAfter(
                        DateTime.now().subtract(const Duration(minutes: 20))))
                .toList();

            // Sort by date
            upcomingAppointments
                .sort((a, b) => a.dateTime.compareTo(b.dateTime));

            // Take only the next 3 appointments
            final displayAppointments = upcomingAppointments.take(3).toList();

            if (displayAppointments.isEmpty) {
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
                        'No upcoming appointments',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AppointmentBookingScreen(),
                            ),
                          );
                        },
                        child: const Text('Book an appointment'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: displayAppointments.length,
              itemBuilder: (context, index) {
                final appointment = displayAppointments[index];

                return FutureBuilder<UserModel?>(
                    future: appointment.doctorId != null
                        ? DatabaseService(uid: appointment.doctorId!)
                            .getUserDetails(appointment.doctorId!)
                        : Future.value(null),
                    builder: (context, snapshot) {
                      String doctorName;
                      if (appointment.doctorId == null) {
                        doctorName = 'Awaiting Doctor';
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        doctorName = 'Loading...';
                      } else if (snapshot.hasError) {
                        doctorName = 'Doctor Unavailable';
                      } else if (snapshot.hasData) {
                        doctorName = 'Dr. ${snapshot.data!.name}';
                      } else {
                        doctorName = 'Doctor Assigned';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AppointmentCard(
                          doctorName: doctorName,
                          appointmentDate: appointment.dateTime,
                          appointmentType: appointment.type,
                          status: appointment.status,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentDetailsScreen(
                                  appointmentData: {
                                    'appointmentId': appointment.appointmentId,
                                    'doctorName': doctorName,
                                    'appointmentDate': appointment.dateTime,
                                    'appointmentType': appointment.type,
                                    'status': appointment.status,
                                    'department': appointment.department,
                                    'vaccinationType':
                                        appointment.vaccinationType,
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(
            title: 'Health Tips',
            subtitle: 'Stay healthy with these tips',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildHealthTipCard(
                title: 'Staying Hydrated',
                description:
                    'Drink 8 glasses of water daily for optimal health.',
                iconData: Icons.water_drop_outlined,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildHealthTipCard(
                title: 'Regular Exercise',
                description:
                    'At least 30 minutes of physical activity daily helps maintain health.',
                iconData: Icons.fitness_center_outlined,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _buildHealthTipCard(
                title: 'Balanced Diet',
                description:
                    'Eat plenty of fruits, vegetables, and whole grains.',
                iconData: Icons.restaurant_outlined,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTipCard({
    required String title,
    required String description,
    required IconData iconData,
    required Color color,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.subheadingStyle.copyWith(
                    fontSize: 16,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTheme.bodySmallStyle.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to full health tip details
              },
              style: TextButton.styleFrom(
                foregroundColor: color,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read More',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    color: color,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _buildScreen(),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'Prescriptions',
          ),
        ],
      ),
    );
  }
}
