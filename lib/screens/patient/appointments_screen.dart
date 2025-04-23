import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

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
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 72,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Appointments Screen',
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'This will be implemented next',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}