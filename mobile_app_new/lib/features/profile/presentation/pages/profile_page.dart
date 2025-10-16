import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_card.dart';
import '../../../../core/config/app_config.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

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
            _buildProfileHeader(user),
            
            SizedBox(height: 24.h),
            
            // Profile Stats
            _buildProfileStats(),
            
            SizedBox(height: 24.h),
            
            // Profile Actions
            _buildProfileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return CustomCard(
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50.w,
            backgroundColor: AppConfig.primaryColor,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Name and Email
          Text(
            user?.name ?? 'User',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppConfig.primaryColor,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            user?.email ?? 'user@example.com',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Verification Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                user?.isEmailVerified == true ? Icons.verified : Icons.warning,
                color: user?.isEmailVerified == true ? AppConfig.successColor : AppConfig.warningColor,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                user?.isEmailVerified == true ? 'Email Verified' : 'Email Not Verified',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: user?.isEmailVerified == true ? AppConfig.successColor : AppConfig.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Statistics',
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
                child: _buildStatItem(
                  'Active Alerts',
                  '12',
                  Icons.notifications,
                  AppConfig.successColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'Analyses',
                  '8',
                  Icons.analytics,
                  AppConfig.infoColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Favorites',
                  '5',
                  Icons.favorite,
                  AppConfig.errorColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'Watchlist',
                  '15',
                  Icons.watch_later,
                  AppConfig.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32.w,
            color: color,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return CustomCard(
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => _editProfile(),
          ),
          Divider(),
          _buildActionTile(
            icon: Icons.security,
            title: 'Security Settings',
            subtitle: 'Manage your account security',
            onTap: () => context.go('/settings'),
          ),
          Divider(),
          _buildActionTile(
            icon: Icons.notifications,
            title: 'Notification Preferences',
            subtitle: 'Customize your notifications',
            onTap: () => _showNotificationPreferences(),
          ),
          Divider(),
          _buildActionTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showHelpSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConfig.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppConfig.primaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.w,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Text('This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreferences() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notification Preferences'),
        content: Text('This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Text('This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}