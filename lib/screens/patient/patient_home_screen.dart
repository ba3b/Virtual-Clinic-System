import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/screens/patient/prescription_screen.dart';
import 'package:virtual_clinic_system/screens/patient/vaccination_records_screen.dart';
import '../../components/appointment_card.dart';
import '../../components/custom_bottom_nav.dart';
import '../../components/notification_badge.dart';
import '../../components/section_header.dart';
import '../../theme/theme.dart';
import '../../localization/app_localizations.dart';
import 'appointment_booking_screen.dart';
import 'appointment_details_screen.dart';
import 'appointments_screen.dart';
import 'patient_notifications_screen.dart';
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
        return const PrescriptionsScreen();
      case 3:
        return const VaccinationRecordsScreen();
      case 4:
        return const PatientProfileScreen();
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
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final tr = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.translate('virtual_clinic'),
                style: AppTheme.headingStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 20,
                ),
              ),
              Text(
                tr.translate('king_faisal_medical'),
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
                          builder: (context) =>
                              const PatientNotificationsScreen()),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PatientNotificationsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final tr = AppLocalizations.of(context);
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
                          tr.translate('welcome_user').replaceAll('{name}', patient.name),
                          style: AppTheme.subheadingStyle.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr.translate('how_feeling'),
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
                          child: Text(tr.translate('book_appointment')),
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
    final tr = AppLocalizations.of(context);
    final actions = [
      {
        'icon': Icons.videocam_rounded,
        'label': tr.translate('virtual_appointment'),
        'color': AppTheme.primaryColor,
        'gradientColors': [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ],
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentBookingScreen(initialType: 'virtual'),
            ),
          );
        },
      },
      {
        'icon': Icons.person_rounded,
        'label': tr.translate('physical_appointment'),
        'color': AppTheme.secondaryColor,
        'gradientColors': [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
        ],
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentBookingScreen(initialType: 'physical'),
            ),
          );
        },
      },
      {
        'icon': Icons.healing_rounded,
        'label': tr.translate('vaccination'),
        'color': AppTheme.accentColor,
        'gradientColors': [
          const Color(0xFF4facfe),
          const Color(0xFF00f2fe),
        ],
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentBookingScreen(initialType: 'vaccination'),
            ),
          );
        },
      },
      {
        'icon': Icons.description_outlined,
        'label': tr.translate('prescriptions'),
        'color': Colors.orange,
        'gradientColors': [
          const Color(0xFFfa709a),
          const Color(0xFFfee140),
        ],
        'onTap': () {
          setState(() {
            _currentIndex = 2;
          });
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(
            title: tr.translate('quick_actions'),
            subtitle: tr.translate('access_quickly'),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 30),
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, i) {
              final a = actions[i];
              return _buildStunningQuickActionCard(
                icon: a['icon'] as IconData,
                label: a['label'] as String,
                color: a['color'] as Color,
                gradientColors: a['gradientColors'] as List<Color>,
                onTap: a['onTap'] as VoidCallback,
                index: i,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStunningQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 400 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              width: 160,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                  stops: const [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: -5,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: -10,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    bottom: 30,
                    left: 15,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 40,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.2,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    final tr = AppLocalizations.of(context);
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
            title: tr.translate('upcoming_appointments'),
            subtitle: tr.translate('your_scheduled'),
            actionText: tr.translate('see_all'),
            onActionTap: () {
              setState(() {
                _currentIndex = 1;
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

            final upcomingAppointments = appointments
                .where((appointment) =>
                    appointment.status != AppointmentModel.statusCancelled &&
                    appointment.status != AppointmentModel.statusRejected &&
                    appointment.dateTime.isAfter(
                        DateTime.now().subtract(const Duration(minutes: 20))))
                .toList();

            upcomingAppointments
                .sort((a, b) => a.dateTime.compareTo(b.dateTime));

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
                        tr.translate('no_upcoming'),
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
                        child: Text(tr.translate('book_an_appointment')),
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
                        doctorName = tr.translate('awaiting_doctor');
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        doctorName = tr.translate('loading');
                      } else if (snapshot.hasError) {
                        doctorName = tr.translate('doctor_unavailable');
                      } else if (snapshot.hasData) {
                        doctorName = tr.locale.languageCode == 'ar' ? 'د. ${snapshot.data!.name}' : 'Dr. ${snapshot.data!.name}';
                      } else {
                        doctorName = tr.translate('doctor_assigned');
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
                                  builder: (context) =>
                                      AppointmentDetailsScreen(
                                    appointmentData: {
                                      'appointmentId':
                                          appointment.appointmentId,
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
                          ));
                    });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthTips() {
    final tr = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(
            title: tr.translate('health_tips'),
            subtitle: tr.translate('stay_healthy'),
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
                title: tr.translate('staying_hydrated'),
                description: tr.translate('drink_water'),
                iconData: Icons.water_drop_outlined,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildHealthTipCard(
                title: tr.translate('regular_exercise'),
                description: tr.translate('exercise_desc'),
                iconData: Icons.fitness_center_outlined,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _buildHealthTipCard(
                title: tr.translate('balanced_diet'),
                description: tr.translate('diet_desc'),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _buildScreen(),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: tr.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today_rounded),
            label: tr.translate('appointments'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_outlined),
            activeIcon: const Icon(Icons.list),
            label: tr.translate('prescriptions'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.vaccines_outlined),
            activeIcon: const Icon(Icons.vaccines_rounded),
            label: tr.translate('vaccination'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: tr.translate('profile'),
          ),
        ],
      ),
    );
  }
}