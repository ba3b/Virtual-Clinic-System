import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Profile',
        showBackButton: false,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 72,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Profile Screen',
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