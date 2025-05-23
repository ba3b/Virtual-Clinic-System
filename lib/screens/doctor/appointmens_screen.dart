import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/firestore_service.dart';
import '../../components/custom_app_bar.dart';
import '../../components/doctor_appointment_card.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import 'appointment_details_screen.dart';

class AppointmentsViewScreen extends StatefulWidget {
  const AppointmentsViewScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsViewScreen> createState() => _AppointmentsViewScreenState();
}

class _AppointmentsViewScreenState extends State<AppointmentsViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, String> _patientNames = {};
  bool _isLoading = false;
  List<String> _processedAppointmentIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Only fetch names for appointments we haven't processed yet
  void _checkForNewAppointments(List<AppointmentModel> appointments) {
    if (_isLoading) return;
    
    // Create a list of appointment IDs we haven't processed yet
    final List<AppointmentModel> newAppointments = appointments.where((appointment) {
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
      // Mark this appointment as processed regardless of success or failure
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
    final user = Provider.of<UserId?>(context);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found. Please log in again.')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Appointments',
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
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: DatabaseService(uid: user.uid).getDoctorAppointments(user.uid),
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
                          snapshot.error.toString(),
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final List<AppointmentModel> allAppointments = snapshot.data ?? [];
                
                // Check for new appointments that need patient names fetched
                _checkForNewAppointments(allAppointments);
                
                // Filter appointments
                final List<AppointmentModel> upcomingAppointments = [];
                final List<AppointmentModel> completedAppointments = [];
                
                final now = DateTime.now();
                
                for (var appointment in allAppointments) {
                  if (appointment.status.toLowerCase() == 'completed') {
                    completedAppointments.add(appointment);
                  } else if (appointment.status.toLowerCase() == 'approved' && 
                             appointment.dateTime.isAfter(now)) {
                    upcomingAppointments.add(appointment);
                  }
                }
                
                // Sort appointments by date and time (most recent first for completed, earliest first for upcoming)
                upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
                completedAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
                
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(upcomingAppointments, 'upcoming'),
                    _buildAppointmentsList(completedAppointments, 'completed'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments, String type) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'upcoming' ? Icons.schedule : Icons.check_circle_outline,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'upcoming' 
                  ? 'No upcoming appointments' 
                  : 'No completed appointments',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'upcoming'
                  ? 'Your future appointments will appear here'
                  : 'Your appointment history will appear here',
              style: AppTheme.bodySmallStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final patientName = _patientNames[appointment.patientId] ?? 'Loading...';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DoctorAppointmentCard(
            appointment: appointment,
            patientName: patientName,
            onTap: () => _navigateToAppointmentDetails(appointment, patientName),
          ),
        );
      },
    );
  }

  void _navigateToAppointmentDetails(
    AppointmentModel appointment,
    String patientName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorAppointmentDetailsScreen(
          appointment: appointment,
          patientName: patientName,
        ),
      ),
    );
  }
}