import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../components/staff_appointment_card.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import 'appointment_details_screen.dart';

class StaffAppointmentsScreen extends StatefulWidget {
  const StaffAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<StaffAppointmentsScreen> createState() => _StaffAppointmentsScreenState();
}

class _StaffAppointmentsScreenState extends State<StaffAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data for demonstration
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

  final List<AppointmentModel> _upcomingAppointments = [
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

  final List<AppointmentModel> _completedAppointments = [
    AppointmentModel(
      appointmentId: '106',
      patientId: 'P106',
      doctorId: 'D001',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      type: 'virtual',
      status: 'completed',
    ),
    AppointmentModel(
      appointmentId: '107',
      patientId: 'P107',
      doctorId: 'D002',
      dateTime: DateTime.now().subtract(const Duration(days: 4)),
      type: 'physical',
      status: 'completed',
    ),
  ];

  // Sample patient names
  final Map<String, String> _patientNames = {
    'P101': 'Abdullah Ahmed',
    'P102': 'Sarah Mohammed',
    'P103': 'Khalid Ibrahim',
    'P104': 'Lina Saleh',
    'P105': 'Omar Hassan',
    'P106': 'Fatima Ali',
    'P107': 'Mohammed Saeed',
  };

  // Sample doctor names
  final Map<String, String> _doctorNames = {
    'D001': 'Dr. Mohammed Hussein',
    'D002': 'Dr. Fatima Abdullah',
  };

  // Sample available doctors
  final List<DoctorModel> _availableDoctors = [
    DoctorModel(
      userId: 'D001',
      name: 'Dr. Mohammed Hussein',
      email: 'mohammed@example.com',
      phoneNumber: '+966 50 123 4567',
      address: 'Taif',
      specialty: 'General Medicine',
      fcmToken: '',
    ),
    DoctorModel(
      userId: 'D002',
      name: 'Dr. Fatima Abdullah',
      email: 'fatima@example.com',
      phoneNumber: '+966 50 234 5678',
      address: 'Taif',
      specialty: 'Pediatrics',
      fcmToken: '',
    ),
    DoctorModel(
      userId: 'D003',
      name: 'Dr. Ahmed Ali',
      email: 'ahmed@example.com',
      phoneNumber: '+966 50 345 6789',
      address: 'Taif',
      specialty: 'Cardiology',
      fcmToken: '',
    ),
    DoctorModel(
      userId: 'D004',
      name: 'Dr. Noura Saeed',
      email: 'noura@example.com',
      phoneNumber: '+966 50 456 7890',
      address: 'Taif',
      specialty: 'Dermatology',
      fcmToken: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AppointmentModel> _getFilteredAppointments(List<AppointmentModel> appointments) {
    if (_searchQuery.isEmpty) {
      return appointments;
    }
    
    return appointments.where((appointment) {
      final patientName = _patientNames[appointment.patientId]?.toLowerCase() ?? '';
      final doctorName = appointment.doctorId != null
          ? _doctorNames[appointment.doctorId]?.toLowerCase() ?? ''
          : '';
      final appointmentId = appointment.appointmentId.toLowerCase();
      final appointmentType = appointment.type.toLowerCase();
      
      return patientName.contains(_searchQuery) ||
             doctorName.contains(_searchQuery) ||
             appointmentId.contains(_searchQuery) ||
             appointmentType.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Appointments',
        backgroundColor: AppTheme.primaryColor,
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search appointments...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: AppTheme.primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentsList(_getFilteredAppointments(_pendingAppointments), true),
                      _buildAppointmentsList(_getFilteredAppointments(_upcomingAppointments), false),
                      _buildAppointmentsList(_getFilteredAppointments(_completedAppointments), false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments, bool isPending) {
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
              _searchQuery.isNotEmpty
                  ? 'No appointments found for "$_searchQuery"'
                  : isPending
                      ? 'No pending appointments'
                      : 'No appointments',
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
        final doctorName = appointment.doctorId != null
            ? _doctorNames[appointment.doctorId]
            : null;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: StaffAppointmentCard(
            appointment: appointment,
            patientName: patientName,
            doctorName: doctorName,
            onTap: () => _navigateToAppointmentDetails(appointment, patientName, doctorName),
            onAssignDoctor: isPending
                ? () => _navigateToAppointmentDetails(appointment, patientName, doctorName)
                : null,
            onVerify: isPending
                ? () => _verifyAppointment(appointment)
                : null,
            onEdit: isPending
                ? () => _navigateToAppointmentDetails(appointment, patientName, doctorName)
                : null,
            onDelete: isPending
                ? () => _deleteAppointment(appointment)
                : null,
          ),
        );
      },
    );
  }

  Future<void> _navigateToAppointmentDetails(
    AppointmentModel appointment,
    String patientName,
    String? doctorName,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffAppointmentDetailsScreen(
          appointment: appointment,
          patientName: patientName,
          doctorName: doctorName,
          availableDoctors: _availableDoctors,
        ),
      ),
    );
    
    if (result == 'delete') {
      _deleteAppointment(appointment);
    } else if (result is AppointmentModel) {
      _updateAppointment(result);
    }
  }

  void _verifyAppointment(AppointmentModel appointment) {
    // For vaccination appointments or appointments with assigned doctors
    if (appointment.type.toLowerCase() == 'vaccination' || appointment.doctorId != null) {
      // Update the appointment status
      final updatedAppointment = appointment.copyWith(status: 'upcoming');
      _updateAppointment(updatedAppointment);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment verified successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      // For other appointments without a doctor, navigate to details to assign
      _navigateToAppointmentDetails(
        appointment,
        _patientNames[appointment.patientId] ?? 'Unknown Patient',
        null,
      );
    }
  }

  void _deleteAppointment(AppointmentModel appointment) {
    setState(() {
      _pendingAppointments.removeWhere(
        (a) => a.appointmentId == appointment.appointmentId
      );
      _upcomingAppointments.removeWhere(
        (a) => a.appointmentId == appointment.appointmentId
      );
      _completedAppointments.removeWhere(
        (a) => a.appointmentId == appointment.appointmentId
      );
    });
  }

  void _updateAppointment(AppointmentModel updatedAppointment) {
    setState(() {
      // Remove from all lists
      _pendingAppointments.removeWhere(
        (a) => a.appointmentId == updatedAppointment.appointmentId
      );
      _upcomingAppointments.removeWhere(
        (a) => a.appointmentId == updatedAppointment.appointmentId
      );
      _completedAppointments.removeWhere(
        (a) => a.appointmentId == updatedAppointment.appointmentId
      );
      
      // Add to appropriate list based on status
      switch (updatedAppointment.status.toLowerCase()) {
        case 'pending':
          _pendingAppointments.add(updatedAppointment);
          break;
        case 'upcoming':
          _upcomingAppointments.add(updatedAppointment);
          break;
        case 'completed':
          _completedAppointments.add(updatedAppointment);
          break;
      }
    });
  }
}