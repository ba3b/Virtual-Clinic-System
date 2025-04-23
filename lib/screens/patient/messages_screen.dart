import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Messages',
        showBackButton: false,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Show search interface
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.message_outlined,
              size: 72,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Messages Screen',
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