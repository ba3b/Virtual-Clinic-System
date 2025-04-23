import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../theme/theme.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data for vaccination appointments
  final List<AppointmentModel> _pendingVaccinations = [
    AppointmentModel(
      appointmentId: 'V001',
      patientId: 'P201',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      type: 'vaccination',
      status: 'pending',
    ),
    AppointmentModel(
      appointmentId: 'V002',
      patientId: 'P202',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      type: 'vaccination',
      status: 'pending',
    ),
  ];

  final List<AppointmentModel> _scheduledVaccinations = [
    AppointmentModel(
      appointmentId: 'V003',
      patientId: 'P203',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      type: 'vaccination',
      status: 'upcoming',
    ),
    AppointmentModel(
      appointmentId: 'V004',
      patientId: 'P204',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      type: 'vaccination',
      status: 'upcoming',
    ),
  ];

  final List<AppointmentModel> _completedVaccinations = [
    AppointmentModel(
      appointmentId: 'V005',
      patientId: 'P205',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      type: 'vaccination',
      status: 'completed',
    ),
    AppointmentModel(
      appointmentId: 'V006',
      patientId: 'P206',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      type: 'vaccination',
      status: 'completed',
    ),
  ];

  // Sample patient details
  final Map<String, Map<String, dynamic>> _patientDetails = {
    'P201': {
      'name': 'Ahmed Khalid',
      'age': 35,
      'vaccine': 'COVID-19 Booster',
    },
    'P202': {
      'name': 'Layla Mohammed',
      'age': 28,
      'vaccine': 'Seasonal Flu',
    },
    'P203': {
      'name': 'Omar Saeed',
      'age': 42,
      'vaccine': 'Hepatitis B',
    },
    'P204': {
      'name': 'Aisha Abdullah',
      'age': 31,
      'vaccine': 'Tetanus',
    },
    'P205': {
      'name': 'Hassan Ali',
      'age': 45,
      'vaccine': 'COVID-19',
    },
    'P206': {
      'name': 'Fatima Ibrahim',
      'age': 26,
      'vaccine': 'Seasonal Flu',
    },
  };

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
      final patientDetails = _patientDetails[appointment.patientId];
      if (patientDetails == null) {
        return false;
      }
      
      final patientName = patientDetails['name'].toString().toLowerCase();
      final vaccine = patientDetails['vaccine'].toString().toLowerCase();
      final appointmentId = appointment.appointmentId.toLowerCase();
      
      return patientName.contains(_searchQuery) ||
             vaccine.contains(_searchQuery) ||
             appointmentId.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Vaccination Management',
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
                      hintText: 'Search vaccinations...',
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
                      Tab(text: 'Scheduled'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVaccinationsList(_getFilteredAppointments(_pendingVaccinations), 'pending'),
                      _buildVaccinationsList(_getFilteredAppointments(_scheduledVaccinations), 'scheduled'),
                      _buildVaccinationsList(_getFilteredAppointments(_completedVaccinations), 'completed'),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a dialog to add a new vaccination record
          _showAddVaccinationDialog();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVaccinationsList(List<AppointmentModel> appointments, String type) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.healing_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No vaccinations found for "$_searchQuery"'
                  : 'No $type vaccinations',
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
        final patientDetails = _patientDetails[appointment.patientId];
        
        if (patientDetails == null) {
          return Container(); // Skip if patient details not found
        }
        
        return _buildVaccinationCard(appointment, patientDetails, type);
      },
    );
  }

  Widget _buildVaccinationCard(
    AppointmentModel appointment,
    Map<String, dynamic> patientDetails,
    String type,
  ) {
    final Color cardColor = type == 'pending'
        ? Colors.orange
        : type == 'scheduled'
            ? AppTheme.primaryColor
            : AppTheme.successColor;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.healing_rounded,
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientDetails['name'],
                        style: AppTheme.subheadingStyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vaccine: ${patientDetails['vaccine']}',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: AppTheme.bodySmallStyle.copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(appointment.dateTime),
                      style: AppTheme.bodySmallStyle,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('hh:mm a').format(appointment.dateTime),
                      style: AppTheme.bodySmallStyle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (type == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Verify',
                      onPressed: () => _verifyVaccination(appointment),
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonButton(
                      text: 'Delete',
                      onPressed: () => _deleteVaccination(appointment),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ] else if (type == 'scheduled') ...[
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Mark as Completed',
                      onPressed: () => _completeVaccination(appointment),
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _verifyVaccination(AppointmentModel appointment) {
    // Update the appointment status to 'upcoming'
    final updatedAppointment = appointment.copyWith(status: 'upcoming');
    
    setState(() {
      _pendingVaccinations.removeWhere(
        (a) => a.appointmentId == appointment.appointmentId
      );
      _scheduledVaccinations.add(updatedAppointment);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vaccination verified successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _completeVaccination(AppointmentModel appointment) {
    // Update the appointment status to 'completed'
    final updatedAppointment = appointment.copyWith(status: 'completed');
    
    setState(() {
      _scheduledVaccinations.removeWhere(
        (a) => a.appointmentId == appointment.appointmentId
      );
      _completedVaccinations.add(updatedAppointment);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vaccination marked as completed'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _deleteVaccination(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccination'),
        content: const Text(
          'Are you sure you want to delete this vaccination appointment? This action cannot be undone.',
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
                _pendingVaccinations.removeWhere(
                  (a) => a.appointmentId == appointment.appointmentId
                );
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vaccination deleted successfully'),
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

  void _showAddVaccinationDialog() {
    final patientNameController = TextEditingController();
    final vaccineTypeController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Vaccination'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    hintText: 'Enter patient name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: vaccineTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Vaccine Type',
                    hintText: 'Enter vaccine type',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Date:',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  title: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                    style: AppTheme.bodyStyle,
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                Text(
                  'Select Time:',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  title: Text(
                    selectedTime.format(context),
                    style: AppTheme.bodyStyle,
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null && pickedTime != selectedTime) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
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
                if (patientNameController.text.isEmpty || vaccineTypeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }
                
                // Create a new appointment
                final newAppointmentId = 'V${_pendingVaccinations.length + _scheduledVaccinations.length + _completedVaccinations.length + 7}';
                final newPatientId = 'P${_patientDetails.length + 207}';
                
                final appointmentDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                
                final newAppointment = AppointmentModel(
                  appointmentId: newAppointmentId,
                  patientId: newPatientId,
                  dateTime: appointmentDateTime,
                  type: 'vaccination',
                  status: 'pending',
                );
                
                // Add patient details
                _patientDetails[newPatientId] = {
                  'name': patientNameController.text,
                  'age': 30, // Default age
                  'vaccine': vaccineTypeController.text,
                };
                
                // Add to pending vaccinations
                setState(() {
                  _pendingVaccinations.add(newAppointment);
                });
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vaccination appointment added successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}