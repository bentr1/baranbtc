import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../core/config/app_config.dart';
import '../../../../../core/utils/color_utils.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            SizedBox(height: 24.h),

            // Account Info
            _buildAccountInfo(),

            SizedBox(height: 24.h),

            // Security
            _buildSecuritySection(),

            SizedBox(height: 24.h),

            // Statistics
            _buildStatisticsSection(),

            SizedBox(height: 24.h),

            // Preferences
            _buildPreferencesSection(),

            SizedBox(height: 24.h),

            // Actions
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor.withOpacityDouble(0.1),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50.w,
                    color: AppConfig.primaryColor,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // User Info
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'john.doe@example.com',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppConfig.successColor.withOpacityDouble(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Verified Account',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.successColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Member Since', 'January 2024', Icons.calendar_today),
            _buildInfoRow('Account Type', 'Premium', Icons.star),
            _buildInfoRow('Last Login', '2 hours ago', Icons.access_time),
            _buildInfoRow('Total Alerts', '24', Icons.notifications),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSecurityItem(
              'Two-Factor Authentication',
              'Enabled',
              Icons.security,
              AppConfig.successColor,
              () => context.go('/mfa-setup'),
            ),
            _buildSecurityItem(
              'Biometric Login',
              'Enabled',
              Icons.fingerprint,
              AppConfig.successColor,
              () => _toggleBiometric(),
            ),
            _buildSecurityItem(
              'Password',
              'Last changed 30 days ago',
              Icons.lock,
              AppConfig.warningColor,
              () => _changePassword(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child:
                      _buildStatItem('Total Alerts', '24', Icons.notifications),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatItem(
                      'Active Alerts', '8', Icons.notifications_active),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child:
                      _buildStatItem('Analysis Views', '156', Icons.analytics),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatItem('Watchlist Items', '12', Icons.star),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildPreferenceItem(
              'Dark Mode',
              'Enabled',
              Icons.dark_mode,
              () => _toggleDarkMode(),
            ),
            _buildPreferenceItem(
              'Push Notifications',
              'Enabled',
              Icons.notifications,
              () => _toggleNotifications(),
            ),
            _buildPreferenceItem(
              'Email Notifications',
              'Disabled',
              Icons.email,
              () => _toggleEmailNotifications(),
            ),
            _buildPreferenceItem(
              'Language',
              'English',
              Icons.language,
              () => _changeLanguage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            CustomButton(
              text: 'Edit Profile',
              onPressed: _editProfile,
              isFullWidth: true,
              type: ButtonType.outline,
              icon: Icons.edit,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Export Data',
              onPressed: _exportData,
              isFullWidth: true,
              type: ButtonType.outline,
              icon: Icons.download,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Logout',
              onPressed: _logout,
              isFullWidth: true,
              type: ButtonType.danger,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.w,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacityDouble(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.w,
                color: color,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24.w,
            color: AppConfig.primaryColor,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppConfig.primaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.w,
              color: Colors.grey[600],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBiometric() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Biometric settings updated'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password changed successfully'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            child: Text('Change'),
          ),
        ],
      ),
    );
  }

  void _toggleDarkMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dark mode preference updated'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  void _toggleNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification settings updated'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  void _toggleEmailNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email notification settings updated'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('English'),
              onTap: () async {
                Navigator.pop(context);
                await LocalStorageService.setLanguage('en');
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  context.read(localeProvider.notifier).setLocale('en');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to English'),
                    backgroundColor: AppConfig.successColor,
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Türkçe'),
              onTap: () async {
                Navigator.pop(context);
                await LocalStorageService.setLanguage('tr');
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  context.read(localeProvider.notifier).setLocale('tr');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dil Türkçe olarak değiştirildi'),
                    backgroundColor: AppConfig.successColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Data export started. You will receive an email when ready.'),
        backgroundColor: AppConfig.infoColor,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
