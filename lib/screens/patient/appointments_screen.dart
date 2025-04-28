import 'package:flutter/material.dart';
import '../../components/appointment_card.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import 'appointment_details_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data for demonstration
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'doctorName': 'Dr. Mohammed Hussein',
      'appointmentDate': DateTime.now().add(const Duration(days: 2)),
      'appointmentType': 'Virtual',
      'status': 'Upcoming',
    },
    {
      'doctorName': 'Dr. Fatima Abdullah',
      'appointmentDate': DateTime.now().add(const Duration(days: 4)),
      'appointmentType': 'Physical',
      'status': 'Upcoming',
    },
    {
      'doctorName': 'Dr. Ahmed Ali',
      'appointmentDate': DateTime.now().add(const Duration(days: 7)),
      'appointmentType': 'Vaccination',
      'status': 'Upcoming',
    },
  ];

  final List<Map<String, dynamic>> _completedAppointments = [
    {
      'doctorName': 'Dr. Mohammed Hussein',
      'appointmentDate': DateTime.now().subtract(const Duration(days: 3)),
      'appointmentType': 'Virtual',
      'status': 'Completed',
    },
    {
      'doctorName': 'Dr. Ahmed Ali',
      'appointmentDate': DateTime.now().subtract(const Duration(days: 7)),
      'appointmentType': 'Physical',
      'status': 'Completed',
    },
  ];

  final List<Map<String, dynamic>> _cancelledAppointments = [
    {
      'doctorName': 'Dr. Sarah Mohammed',
      'appointmentDate': DateTime.now().subtract(const Duration(days: 2)),
      'appointmentType': 'Virtual',
      'status': 'Cancelled',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Simulate data loading
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

  List<Map<String, dynamic>> _getFilteredAppointments(List<Map<String, dynamic>> appointments) {
    if (_searchQuery.isEmpty) {
      return appointments;
    }
    
    return appointments.where((appointment) {
      final doctorName = appointment['doctorName'].toString().toLowerCase();
      final appointmentType = appointment['appointmentType'].toString().toLowerCase();
      
      return doctorName.contains(_searchQuery) ||
             appointmentType.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Appointments',
        showBackButton: false,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options dialog
              _showFilterDialog();
            },
          ),
        ],
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
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentsList(_getFilteredAppointments(_upcomingAppointments)),
                      _buildAppointmentsList(_getFilteredAppointments(_completedAppointments)),
                      _buildAppointmentsList(_getFilteredAppointments(_cancelledAppointments)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments) {
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
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AppointmentCard(
            doctorName: appointment['doctorName'],
            appointmentDate: appointment['appointmentDate'],
            appointmentType: appointment['appointmentType'],
            status: appointment['status'],
            onTap: () => _navigateToAppointmentDetails(appointment),
          ),
        );
      },
    );
  }

  void _navigateToAppointmentDetails(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsScreen(
          appointmentData: appointment,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Appointments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All Types', true),
            _buildFilterOption('Virtual', false),
            _buildFilterOption('Physical', false),
            _buildFilterOption('Vaccination', false),
            const Divider(),
            _buildFilterOption('All Doctors', true),
            _buildFilterOption('Dr. Mohammed Hussein', false),
            _buildFilterOption('Dr. Fatima Abdullah', false),
            _buildFilterOption('Dr. Ahmed Ali', false),
          ],
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
              // Apply filter (would be implemented with actual filter logic)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filters applied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              'Apply',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return ListTile(
      title: Text(label),
      leading: isSelected
          ? Icon(Icons.radio_button_checked, color: AppTheme.primaryColor)
          : const Icon(Icons.radio_button_unchecked),
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: () {
        // This would update the filter selection in the actual implementation
        Navigator.pop(context);
        _showFilterDialog();
      },
    );
  }
}