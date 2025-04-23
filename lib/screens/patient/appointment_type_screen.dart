import 'package:flutter/material.dart';
import '../../components/appointment_type_card.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import 'appointment_date_screen.dart';

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
      'title': 'Virtual Appointment',
      'description': 'Consult with doctors through video call from your home',
      'icon': Icons.videocam_rounded,
      'color': AppTheme.primaryColor,
    },
    {
      'id': 'physical',
      'title': 'Physical Appointment',
      'description': 'Visit the hospital for in-person consultation',
      'icon': Icons.person_rounded,
      'color': Colors.blue,
    },
    {
      'id': 'vaccination',
      'title': 'Vaccination',
      'description': 'Schedule your vaccination at the hospital',
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDateScreen(
            appointmentType: _selectedType!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Book Appointment',
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Appointment Type',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the type of appointment you need',
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
                      title: type['title'],
                      description: type['description'],
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
                text: 'Continue',
                onPressed: _selectedType != null ? _proceedToNextStep : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}