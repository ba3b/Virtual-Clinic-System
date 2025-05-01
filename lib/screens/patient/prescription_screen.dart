import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/custom_app_bar.dart';
import '../../models/prescription_model.dart';
import '../../theme/theme.dart';
import 'prescription_detail_screen.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data for demonstration
  final List<PrescriptionModel> _prescriptions = [
    PrescriptionModel(
      prescriptionId: '101',
      appointmentId: 'APT001',
      patientId: 'P001',
      doctorId: 'D001',
      medicationDetails: 'Paracetamol 500mg',
      dosageInstructions: 'Take 1 tablet every 6 hours as needed for pain or fever. Do not exceed 4 tablets in 24 hours.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PrescriptionModel(
      prescriptionId: '102',
      appointmentId: 'APT002',
      patientId: 'P001',
      doctorId: 'D002',
      medicationDetails: 'Amoxicillin 250mg',
      dosageInstructions: 'Take 1 capsule three times daily with meals for 7 days. Complete the full course even if you feel better.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PrescriptionModel(
      prescriptionId: '103',
      appointmentId: 'APT003',
      patientId: 'P001',
      doctorId: 'D001',
      medicationDetails: 'Cetirizine 10mg',
      dosageInstructions: 'Take 1 tablet daily for allergies. May cause drowsiness; avoid driving if affected.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  // Sample doctor names mapping
  final Map<String, String> _doctorNames = {
    'D001': 'Dr. Mohammed Hussein',
    'D002': 'Dr. Fatima Abdullah',
    'D003': 'Dr. Ahmed Ali',
  };

  @override
  void initState() {
    super.initState();
    
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
    _searchController.dispose();
    super.dispose();
  }

  List<PrescriptionModel> _getFilteredPrescriptions() {
    if (_searchQuery.isEmpty) {
      return _prescriptions;
    }
    
    return _prescriptions.where((prescription) {
      final doctorName = _doctorNames[prescription.doctorId]?.toLowerCase() ?? '';
      final medicationDetails = prescription.medicationDetails.toLowerCase();
      final prescriptionId = prescription.prescriptionId.toLowerCase();
      
      return doctorName.contains(_searchQuery) ||
             medicationDetails.contains(_searchQuery) ||
             prescriptionId.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Prescriptions',
        backgroundColor: AppTheme.primaryColor,
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
                      hintText: 'Search prescriptions...',
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
                  child: _buildPrescriptionsList(_getFilteredPrescriptions()),
                ),
              ],
            ),
    );
  }

  Widget _buildPrescriptionsList(List<PrescriptionModel> prescriptions) {
    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medication_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No prescriptions found for "$_searchQuery"'
                  : 'No prescriptions available',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return _buildPrescriptionCard(prescription);
      },
    );
  }

  Widget _buildPrescriptionCard(PrescriptionModel prescription) {
    final doctorName = _doctorNames[prescription.doctorId] ?? 'Unknown Doctor';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrescriptionDetailScreen(
                prescription: prescription,
                doctorName: doctorName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription.medicationDetails,
                        style: AppTheme.subheadingStyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctorName,
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              'Dosage Instructions',
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prescription.dosageInstructions,
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prescription ID: ${prescription.prescriptionId}',
                      style: AppTheme.bodySmallStyle,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(prescription.createdAt),
                      style: AppTheme.bodySmallStyle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}