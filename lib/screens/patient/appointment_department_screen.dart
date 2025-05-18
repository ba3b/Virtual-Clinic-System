import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/firestore_service.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import 'appointment_date_screen.dart';

class AppointmentDepartmentScreen extends StatefulWidget {
  final String appointmentType;

  const AppointmentDepartmentScreen({
    Key? key,
    required this.appointmentType,
  }) : super(key: key);

  @override
  State<AppointmentDepartmentScreen> createState() => _AppointmentDepartmentScreenState();
}

class _AppointmentDepartmentScreenState extends State<AppointmentDepartmentScreen> {
  String? _selectedDepartment;

  void _onDepartmentSelected(String department) {
    setState(() {
      _selectedDepartment = department;
    });
  }

  void _proceedToNextStep() {
    if (_selectedDepartment != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDateScreen(
            appointmentType: widget.appointmentType,
            department: _selectedDepartment,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId?>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.appointmentType == 'virtual' ? 'Virtual Appointment' : 'Physical Appointment',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Department',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the medical department for your appointment',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<UserModel>(
                  future: DatabaseService(uid: user!.uid).getUserDetails(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading eligibility data: ${snapshot.error}',
                          style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.isPatient) {
                      return const Center(
                        child: Text('No eligibility data found or user is not a patient'),
                      );
                    }

                    final patientModel = snapshot.data! as PatientModel;
                    final eligibleDepartments = patientModel.eligibility;

                    if (eligibleDepartments.isEmpty) {
                      return const Center(
                        child: Text('You are not eligible for any departments yet.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: eligibleDepartments.length,
                      itemBuilder: (context, index) {
                        final department = eligibleDepartments[index];
                        final bool isSelected = department == _selectedDepartment;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isSelected ? 4 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _onDepartmentSelected(department),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryColor.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.local_hospital_outlined,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      department,
                                      style: AppTheme.subheadingStyle.copyWith(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryColor,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: 'Continue',
                onPressed: _selectedDepartment != null ? _proceedToNextStep : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}