import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

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
  String _selectedCurrency = 'USD';

  final List<String> _languages = ['tr', 'en', 'fr', 'de'];
  final List<String> _currencies = ['USD', 'EUR', 'TRY', 'BTC'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionTitle('Profil'),
            CustomCard(
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.person,
                    title: 'Profil Bilgileri',
                    subtitle: 'Kişisel bilgilerinizi düzenleyin',
                    onTap: () => context.go('/profile'),
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    icon: Icons.security,
                    title: 'Güvenlik',
                    subtitle: 'Şifre ve 2FA ayarları',
                    onTap: () => _openSecuritySettings(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // App Settings
            _buildSectionTitle('Uygulama Ayarları'),
            CustomCard(
              child: Column(
                children: [
                  _buildSwitchItem(
                    icon: Icons.notifications,
                    title: 'Bildirimler',
                    subtitle: 'Push bildirimlerini al',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    icon: Icons.fingerprint,
                    title: 'Biyometrik Giriş',
                    subtitle: 'Parmak izi ile giriş yap',
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    icon: Icons.dark_mode,
                    title: 'Karanlık Mod',
                    subtitle: 'Karanlık tema kullan',
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Language and Currency
            _buildSectionTitle('Dil ve Para Birimi'),
            CustomCard(
              child: Column(
                children: [
                  _buildDropdownItem(
                    icon: Icons.language,
                    title: 'Dil',
                    subtitle: 'Uygulama dilini seçin',
                    value: _selectedLanguage,
                    items: _languages,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildDropdownItem(
                    icon: Icons.attach_money,
                    title: 'Para Birimi',
                    subtitle: 'Varsayılan para birimi',
                    value: _selectedCurrency,
                    items: _currencies,
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Data and Storage
            _buildSectionTitle('Veri ve Depolama'),
            CustomCard(
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.storage,
                    title: 'Önbellek Temizle',
                    subtitle: 'Geçici dosyaları sil',
                    onTap: _clearCache,
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    icon: Icons.download,
                    title: 'Veri İndir',
                    subtitle: 'Hesap verilerinizi indirin',
                    onTap: _downloadData,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Support
            _buildSectionTitle('Destek'),
            CustomCard(
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.help,
                    title: 'Yardım',
                    subtitle: 'Sık sorulan sorular',
                    onTap: _openHelp,
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    icon: Icons.contact_support,
                    title: 'İletişim',
                    subtitle: 'Müşteri hizmetleri',
                    onTap: _openContact,
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    icon: Icons.info,
                    title: 'Hakkında',
                    subtitle: 'Uygulama bilgileri',
                    onTap: _openAbout,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Account Actions
            _buildSectionTitle('Hesap İşlemleri'),
            CustomCard(
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.logout,
                    title: 'Çıkış Yap',
                    subtitle: 'Hesabınızdan çıkış yapın',
                    onTap: _logout,
                    textColor: AppConfig.warningColor,
                  ),
                  _buildDivider(),
                  _buildProfileItem(
                    icon: Icons.delete,
                    title: 'Hesabı Sil',
                    subtitle: 'Hesabınızı kalıcı olarak silin',
                    onTap: _deleteAccount,
                    textColor: AppConfig.errorColor,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // App Version
            Center(
              child: Text(
                'Versiyon ${AppConfig.appVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppConfig.primaryColor,
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: textColor ?? AppConfig.primaryColor,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor ?? theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: AppConfig.primaryColor,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: AppConfig.primaryColor,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item.toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.3),
    );
  }

  void _openSecuritySettings() {
    // TODO: Navigate to security settings
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Önbellek Temizle'),
        content: const Text('Geçici dosyalar silinecek. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Önbellek temizlendi')),
              );
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  void _downloadData() {
    // TODO: Implement data download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veri indirme başlatıldı')),
    );
  }

  void _openHelp() {
    // TODO: Navigate to help page
  }

  void _openContact() {
    // TODO: Navigate to contact page
  }

  void _openAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationLegalese: '© 2024 BTC Baran. Tüm hakları saklıdır.',
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout
              context.go('/login');
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Hesabınız kalıcı olarak silinecek. Bu işlem geri alınamaz. Devam etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              context.go('/login');
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
