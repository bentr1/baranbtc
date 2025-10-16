import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'tr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account Settings
            _buildSection(
              'Hesap Ayarları',
              [
                _buildMenuItem(
                  icon: Icons.person,
                  title: 'Profil',
                  subtitle: 'Kişisel bilgilerinizi düzenleyin',
                  onTap: () => context.go('/profile'),
                ),
                _buildMenuItem(
                  icon: Icons.security,
                  title: 'Güvenlik',
                  subtitle: 'Şifre ve 2FA ayarları',
                  onTap: () => _showSecuritySettings(),
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip,
                  title: 'Gizlilik',
                  subtitle: 'Veri kullanımı ve gizlilik',
                  onTap: () => _showPrivacySettings(),
                ),
              ],
            ),
            
            // Notification Settings
            _buildSection(
              'Bildirim Ayarları',
              [
                _buildSwitchItem(
                  icon: Icons.notifications,
                  title: 'Bildirimler',
                  subtitle: 'Push bildirimlerini etkinleştir',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildMenuItem(
                  icon: Icons.price_change,
                  title: 'Fiyat Uyarıları',
                  subtitle: 'Fiyat değişim uyarıları',
                  onTap: () => _showPriceAlertSettings(),
                ),
                _buildMenuItem(
                  icon: Icons.analytics,
                  title: 'Analiz Sinyalleri',
                  subtitle: 'Teknik analiz uyarıları',
                  onTap: () => _showAnalysisAlertSettings(),
                ),
              ],
            ),
            
            // Security Settings
            _buildSection(
              'Güvenlik',
              [
                _buildSwitchItem(
                  icon: Icons.fingerprint,
                  title: 'Biometrik Giriş',
                  subtitle: 'Parmak izi veya yüz tanıma',
                  value: _biometricEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                ),
                _buildMenuItem(
                  icon: Icons.lock,
                  title: 'PIN Kodu',
                  subtitle: 'Uygulama kilidi',
                  onTap: () => _showPinSettings(),
                ),
                _buildMenuItem(
                  icon: Icons.security,
                  title: '2FA',
                  subtitle: 'İki faktörlü doğrulama',
                  onTap: () => _show2FASettings(),
                ),
              ],
            ),
            
            // App Settings
            _buildSection(
              'Uygulama Ayarları',
              [
                _buildSwitchItem(
                  icon: Icons.dark_mode,
                  title: 'Karanlık Mod',
                  subtitle: 'Koyu tema kullan',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
                _buildMenuItem(
                  icon: Icons.language,
                  title: 'Dil',
                  subtitle: _getLanguageName(_selectedLanguage),
                  onTap: () => _showLanguageSettings(),
                ),
                _buildMenuItem(
                  icon: Icons.storage,
                  title: 'Veri Yönetimi',
                  subtitle: 'Önbellek ve veri temizleme',
                  onTap: () => _showDataManagement(),
                ),
              ],
            ),
            
            // Support
            _buildSection(
              'Destek',
              [
                _buildMenuItem(
                  icon: Icons.help,
                  title: 'Yardım',
                  subtitle: 'SSS ve kullanım kılavuzu',
                  onTap: () => _showHelp(),
                ),
                _buildMenuItem(
                  icon: Icons.feedback,
                  title: 'Geri Bildirim',
                  subtitle: 'Öneri ve şikayetleriniz',
                  onTap: () => _showFeedback(),
                ),
                _buildMenuItem(
                  icon: Icons.info,
                  title: 'Hakkında',
                  subtitle: 'Uygulama bilgileri',
                  onTap: () => _showAbout(),
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      margin: EdgeInsets.symmetric(
        horizontal: AppConfig.defaultPadding.w,
        vertical: 4.h,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppConfig.primaryColor,
              size: 20.w,
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CustomCard(
      margin: EdgeInsets.symmetric(
        horizontal: AppConfig.defaultPadding.w,
        vertical: 4.h,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppConfig.primaryColor,
              size: 20.w,
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return 'Türkçe';
    }
  }

  void _showSecuritySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Güvenlik Ayarları'),
        content: const Text('Güvenlik ayarları sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Ayarları'),
        content: const Text('Gizlilik ayarları sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPriceAlertSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fiyat Uyarı Ayarları'),
        content: const Text('Fiyat uyarı ayarları sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showAnalysisAlertSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analiz Uyarı Ayarları'),
        content: const Text('Analiz uyarı ayarları sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPinSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN Kodu Ayarları'),
        content: const Text('PIN kodu ayarları sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _show2FASettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('2FA Ayarları'),
        content: const Text('2FA ayarları sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Türkçe'),
              leading: Radio<String>(
                value: 'tr',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showDataManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri Yönetimi'),
        content: const Text('Veri yönetimi sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım'),
        content: const Text('Yardım sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geri Bildirim'),
        content: const Text('Geri bildirim sayfası geliştirilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hakkında'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.currency_bitcoin,
              size: 64.w,
              color: AppConfig.primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'BTC Baran',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'v${AppConfig.appVersion}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppConfig.appDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
