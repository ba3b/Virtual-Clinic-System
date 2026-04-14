import 'package:flutter/material.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../components/date_picker_component.dart';
import '../../theme/theme.dart';
import '../../localization/app_localizations.dart';
import '../../constants/departments.dart';
import 'appointment_time_screen.dart';

class AppointmentDateScreen extends StatefulWidget {
  final String appointmentType;
  final String? department;
  final String? vaccinationType;

  const AppointmentDateScreen({
    Key? key,
    required this.appointmentType,
    this.department,
    this.vaccinationType,
  }) : super(key: key);

  @override
  State<AppointmentDateScreen> createState() => _AppointmentDateScreenState();
}

class _AppointmentDateScreenState extends State<AppointmentDateScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));

    if (_selectedDate.weekday == 5) {
      _selectedDate =
          _selectedDate.add(const Duration(days: 2)); 
    } else if (_selectedDate.weekday == 6) {
      _selectedDate =
          _selectedDate.add(const Duration(days: 1)); 
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _proceedToNextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentTimeScreen(
          appointmentType: widget.appointmentType,
          appointmentDate: _selectedDate,
          department: widget.department,
          vaccinationType: widget.vaccinationType,
        ),
      ),
    );
  }

  String _getAppointmentTypeTitle(BuildContext context) {
    if (widget.appointmentType == 'vaccination' &&
        widget.vaccinationType != null) {
      return '${AppLocalizations.of(context).translate('vaccination')}: ${AppLocalizations.of(context).translate(widget.vaccinationType!)}';
    } else if (widget.appointmentType == 'virtual' &&
        widget.department != null) {
      return '${AppLocalizations.of(context).translate('virtual')}: ${AppLocalizations.of(context).translate(DepartmentConstants.getTranslationKey(widget.department!))}';
    } else if (widget.appointmentType == 'physical' &&
        widget.department != null) {
      return '${AppLocalizations.of(context).translate('physical')}: ${AppLocalizations.of(context).translate(DepartmentConstants.getTranslationKey(widget.department!))}';
    } else {
      switch (widget.appointmentType) {
        case 'virtual':
          return AppLocalizations.of(context).translate('virtual_appointment');
        case 'physical':
          return AppLocalizations.of(context).translate('physical_appointment');
        case 'vaccination':
          return AppLocalizations.of(context).translate('vaccination');
        default:
          return AppLocalizations.of(context).translate('book_appointment');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppointmentTypeTitle(context),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('select_date'),
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).translate('choose_date_desc'),
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: DatePickerComponent(
                  initialDate: _selectedDate,
                  firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day + 1),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  onDateSelected: _onDateSelected,
                ),
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: AppLocalizations.of(context).translate('continue_btn'),
                onPressed: _proceedToNextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
