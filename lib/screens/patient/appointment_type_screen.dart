import 'package:flutter/material.dart';
import '../../components/appointment_type_card.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import 'appointment_department_screen.dart';
import 'appointment_vaccination_screen.dart';
import '../../localization/app_localizations.dart';

class AppointmentTypeScreen extends StatefulWidget {
  const AppointmentTypeScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentTypeScreen> createState() => _AppointmentTypeScreenState();
}

class _AppointmentTypeScreenState extends State<AppointmentTypeScreen> {
  String? _selectedType;
  
  final List<Map<String, dynamic>> _appointmentTypes = [
    {
      'id': 'virtual',
      'titleKey': 'virtual_appointment',
      'descriptionKey': 'virtual_desc',
      'icon': Icons.videocam_rounded,
      'color': AppTheme.primaryColor,
    },
    {
      'id': 'physical',
      'titleKey': 'physical_appointment',
      'descriptionKey': 'physical_desc',
      'icon': Icons.person_rounded,
      'color': Colors.blue,
    },
    {
      'id': 'vaccination',
      'titleKey': 'vaccination',
      'descriptionKey': 'vaccination_desc',
      'icon': Icons.healing_rounded,
      'color': Colors.green,
    },
  ];

  void _selectType(String typeId) {
    setState(() {
      _selectedType = typeId;
    });
  }

  void _proceedToNextStep() {
    if (_selectedType != null) {
      if (_selectedType == 'vaccination') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AppointmentVaccinationScreen(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDepartmentScreen(
              appointmentType: _selectedType!,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('book_appointment'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('select_type'),
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).translate('choose_appointment_type'),
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _appointmentTypes.length,
                  itemBuilder: (context, index) {
                    final type = _appointmentTypes[index];
                    final bool isSelected = type['id'] == _selectedType;
                    
                    return AppointmentTypeCard(
                      title: AppLocalizations.of(context).translate(type['titleKey']),
                      description: AppLocalizations.of(context).translate(type['descriptionKey']),
                      icon: type['icon'],
                      color: type['color'],
                      isSelected: isSelected,
                      onTap: () => _selectType(type['id']),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: AppLocalizations.of(context).translate('continue_btn'),
                onPressed: _selectedType != null ? _proceedToNextStep : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}