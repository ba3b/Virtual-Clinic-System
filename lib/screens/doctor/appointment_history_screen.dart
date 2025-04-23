import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../components/doctor_appointment_card.dart';
import '../../models/appointment_model.dart';
import '../../theme/theme.dart';
import 'appointment_details_screen.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  // Sample data for demonstration
  final List<AppointmentModel> _completedAppointments = [
    AppointmentModel(
      appointmentId: '10',
      patientId: 'P010',
      doctorId: 'D001',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      type: 'virtual',
      status: 'completed',
    ),
    AppointmentModel(
      appointmentId: '11',
      patientId: 'P011',
      doctorId: 'D001',
      dateTime: DateTime.now().subtract(const Duration(days: 4)),
      type: 'physical',
      status: 'completed',
    ),
    AppointmentModel(
      appointmentId: '12',
      patientId: 'P012',
      doctorId: 'D001',
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      type: 'vaccination',
      status: 'completed',
    ),
  ];

  final List<AppointmentModel> _cancelledAppointments = [
    AppointmentModel(
      appointmentId: '13',
      patientId: 'P013',
      doctorId: 'D001',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      type: 'virtual',
      status: 'cancelled',
    ),
    AppointmentModel(
      appointmentId: '14',
      patientId: 'P014',
      doctorId: 'D001',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      type: 'physical',
      status: 'cancelled',
    ),
  ];

  // Sample patient names
  final Map<String, String> _patientNames = {
    'P010': 'Noura Abdullah',
    'P011': 'Saeed Mohammad',
    'P012': 'Aisha Ahmed',
    'P013': 'Yasir Salim',
    'P014': 'Layla Hassan',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Appointment History',
        backgroundColor: AppTheme.primaryColor,
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: AppTheme.primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentsList(_completedAppointments),
                      _buildAppointmentsList(_cancelledAppointments),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
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
        final patientName = _patientNames[appointment.patientId] ?? 'Unknown Patient';
        
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