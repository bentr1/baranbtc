import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/color_utils.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _biometricAuth = true;
  bool _autoRefresh = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Appearance
            _buildAppearanceSection(),

            SizedBox(height: 24.h),

            // Notifications
            _buildNotificationsSection(),

            SizedBox(height: 24.h),

            // Security
            _buildSecuritySection(),

            SizedBox(height: 24.h),

            // General
            _buildGeneralSection(),

            SizedBox(height: 24.h),

            // About
            _buildAboutSection(),

            SizedBox(height: 24.h),

            // Actions
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSwitchItem(
              'Dark Mode',
              'Enable dark theme',
              _darkMode,
              Icons.dark_mode,
              (value) => setState(() => _darkMode = value),
            ),
            _buildDropdownItem(
              'Theme',
              'Choose app theme',
              _selectedTheme,
              Icons.palette,
              ['System', 'Light', 'Dark'],
              (value) => setState(() => _selectedTheme = value),
            ),
            _buildDropdownItem(
              'Language',
              'Select app language',
              _selectedLanguage,
              Icons.language,
              ['English', 'Türkçe', 'Español', 'Français'],
              (value) async {
                setState(() => _selectedLanguage = value);
                final langMap = {
                  'English': 'en',
                  'Türkçe': 'tr',
                  'Español': 'es',
                  'Français': 'fr',
                };
                final code = langMap[value] ?? 'en';
                await LocalStorageService.setLanguage(code);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  context.read(localeProvider.notifier).setLocale(code);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSwitchItem(
              'Push Notifications',
              'Receive push notifications',
              _pushNotifications,
              Icons.notifications,
              (value) => setState(() => _pushNotifications = value),
            ),
            _buildSwitchItem(
              'Email Notifications',
              'Receive email notifications',
              _emailNotifications,
              Icons.email,
              (value) => setState(() => _emailNotifications = value),
            ),
            _buildActionItem(
              'Notification Settings',
              'Configure notification preferences',
              Icons.notifications_active,
              () => context.go('/notifications'),
            ),
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
            _buildSwitchItem(
              'Biometric Authentication',
              'Use fingerprint or face ID',
              _biometricAuth,
              Icons.fingerprint,
              (value) => setState(() => _biometricAuth = value),
            ),
            _buildActionItem(
              'Two-Factor Authentication',
              'Manage 2FA settings',
              Icons.security,
              () => context.go('/mfa-setup'),
            ),
            _buildActionItem(
              'Change Password',
              'Update your password',
              Icons.lock,
              () => _showChangePasswordDialog(),
            ),
            _buildActionItem(
              'Privacy Settings',
              'Manage privacy preferences',
              Icons.privacy_tip,
              () => _showPrivacySettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSwitchItem(
              'Auto Refresh',
              'Automatically refresh data',
              _autoRefresh,
              Icons.refresh,
              (value) => setState(() => _autoRefresh = value),
            ),
            _buildDropdownItem(
              'Currency',
              'Select display currency',
              _selectedCurrency,
              Icons.attach_money,
              ['USD', 'EUR', 'TRY', 'GBP'],
              (value) => setState(() => _selectedCurrency = value),
            ),
            _buildActionItem(
              'Cache Settings',
              'Manage app cache',
              Icons.storage,
              () => _showCacheSettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildActionItem(
              'App Version',
              '1.0.0 (Build 1)',
              Icons.info,
              () => _showAppInfo(),
            ),
            _buildActionItem(
              'Terms of Service',
              'Read our terms and conditions',
              Icons.description,
              () => _showTermsOfService(),
            ),
            _buildActionItem(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              () => _showPrivacyPolicy(),
            ),
            _buildActionItem(
              'Support',
              'Get help and support',
              Icons.help,
              () => _showSupport(),
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
              text: 'Export Data',
              onPressed: _exportData,
              isFullWidth: true,
              type: ButtonType.outline,
              icon: Icons.download,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Reset Settings',
              onPressed: _resetSettings,
              isFullWidth: true,
              type: ButtonType.outline,
              icon: Icons.restore,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Delete Account',
              onPressed: _deleteAccount,
              isFullWidth: true,
              type: ButtonType.danger,
              icon: Icons.delete_forever,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value,
      IconData icon, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacityDouble(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 20.w,
              color: AppConfig.primaryColor,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String title, String subtitle, String value,
      IconData icon, List<String> options, Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: GestureDetector(
        onTap: () => _showDropdownDialog(title, options, value, onChanged),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.w,
                color: AppConfig.primaryColor,
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
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(width: 8.w),
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

  Widget _buildActionItem(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
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
                color: AppConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.w,
                color: AppConfig.primaryColor,
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

  void _showDropdownDialog(String title, List<String> options,
      String currentValue, Function(String) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((option) => ListTile(
                    title: Text(option),
                    trailing: option == currentValue
                        ? Icon(Icons.check, color: AppConfig.primaryColor)
                        : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
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

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Analytics'),
              subtitle: Text('Help improve the app'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('Crash Reports'),
              subtitle: Text('Send crash reports'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showCacheSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cache Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current cache size: 45.2 MB'),
            SizedBox(height: 16.h),
            CustomButton(
              text: 'Clear Cache',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: AppConfig.successColor,
                  ),
                );
              },
              isFullWidth: true,
              type: ButtonType.outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'BTC Baran',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          color: AppConfig.primaryColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.trending_up,
          size: 32.w,
          color: Colors.white,
        ),
      ),
      children: [
        Text('A comprehensive crypto analysis and notification platform.'),
      ],
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text('Terms of Service content would be displayed here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text('Privacy Policy content would be displayed here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Support'),
              subtitle: Text('support@btcbaran.com'),
              onTap: () {
                Navigator.pop(context);
                // Open email client
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Live Chat'),
              subtitle: Text('Available 24/7'),
              onTap: () {
                Navigator.pop(context);
                // Open live chat
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('FAQ'),
              subtitle: Text('Frequently Asked Questions'),
              onTap: () {
                Navigator.pop(context);
                // Open FAQ
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
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

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content:
            Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _darkMode = false;
                _pushNotifications = true;
                _emailNotifications = false;
                _biometricAuth = true;
                _autoRefresh = true;
                _selectedLanguage = 'English';
                _selectedCurrency = 'USD';
                _selectedTheme = 'System';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings reset to default'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion initiated'),
                  backgroundColor: AppConfig.errorColor,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConfig.errorColor,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
