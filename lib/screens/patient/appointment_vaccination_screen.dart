import 'package:flutter/material.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../constants/vaccinations.dart';
import '../../theme/theme.dart';
import 'appointment_date_screen.dart';

class AppointmentVaccinationScreen extends StatefulWidget {
  const AppointmentVaccinationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AppointmentVaccinationScreen> createState() => _AppointmentVaccinationScreenState();
}

class _AppointmentVaccinationScreenState extends State<AppointmentVaccinationScreen> {
  String? _selectedVaccination;

  void _onVaccinationSelected(String vaccination) {
    setState(() {
      _selectedVaccination = vaccination;
    });
  }

  void _proceedToNextStep() {
    if (_selectedVaccination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDateScreen(
            appointmentType: 'vaccination',
            vaccinationType: _selectedVaccination,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Vaccination',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Vaccination Type',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the type of vaccination you need',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: VaccinationConstants.allVaccinations.length,
                  itemBuilder: (context, index) {
                    final vaccination = VaccinationConstants.allVaccinations[index];
                    final bool isSelected = vaccination == _selectedVaccination;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.green
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _onVaccinationSelected(vaccination),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.health_and_safety_outlined,
                                  color: isSelected ? Colors.green : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  vaccination,
                                  style: AppTheme.subheadingStyle.copyWith(
                                    color: isSelected
                                        ? Colors.green
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: 'Continue',
                onPressed: _selectedVaccination != null ? _proceedToNextStep : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}