import 'package:flutter/material.dart';
import '../../components/common_button.dart';
import '../../components/custom_app_bar.dart';
import '../../theme/theme.dart';
import '../auth/login_screen.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Profile',
        backgroundColor: AppTheme.primaryColor,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildProfileInfo(),
            const SizedBox(height: 24),
            _buildStatistics(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sarah Mohammed',
            style: AppTheme.headingStyle.copyWith(
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Staff Administrator',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.badge_outlined, 'Staff ID', 'S001'),
          _buildInfoRow(Icons.email_outlined, 'Email', 'sarah@kfmc.sa'),
          _buildInfoRow(Icons.phone_outlined, 'Phone', '+966 50 123 4567'),
          _buildInfoRow(Icons.location_on_outlined, 'Address', 'King Faisal Medical Complex, Taif, Saudi Arabia'),
          _buildInfoRow(Icons.work_outline, 'Department', 'Outpatient Administration'),
          _buildInfoRow(Icons.schedule_outlined, 'Working Hours', 'Sun-Thu: 8:00 AM - 5:00 PM'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Overview',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Appointments',
                  '12',
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Verified Today',
                  '8',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Vaccinations',
                  '27',
                  Icons.healing_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Doctors Assigned',
                  '15',
                  Icons.person_outline,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.headingStyle.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmallStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButton(
          'Edit Profile',
          Icons.edit_outlined,
          Colors.blue,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Profile feature will be implemented next')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Change Password',
          Icons.lock_outline,
          Colors.orange,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change Password feature will be implemented next')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Notifications Settings',
          Icons.notifications_outlined,
          Colors.purple,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications Settings feature will be implemented next')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Help & Support',
          Icons.help_outline,
          Colors.green,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & Support feature will be implemented next')),
            );
          },
        ),
        const SizedBox(height: 24),
        CommonButton(
          text: 'Logout',
          backgroundColor: Colors.red,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout Confirmation'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyStyle,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}