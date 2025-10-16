import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // Simulate loading user data
    _firstNameController.text = 'Ahmet';
    _lastNameController.text = 'Yılmaz';
    _emailController.text = 'ahmet.yilmaz@email.com';
    _phoneController.text = '+90 555 123 45 67';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // TODO: Implement profile update API call
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isEditing = false;
        _successMessage = 'Profil başarıyla güncellendi';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Kaydet',
                style: TextStyle(
                  color: AppConfig.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppConfig.primaryColor,
                          child: Text(
                            '${_firstNameController.text[0]}${_lastNameController.text[0]}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: AppConfig.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                                onPressed: _changeAvatar,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '${_firstNameController.text} ${_lastNameController.text}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _emailController.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Success Message
              if (_successMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppConfig.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppConfig.successColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppConfig.successColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConfig.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppConfig.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppConfig.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppConfig.errorColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConfig.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Personal Information
              _buildSectionTitle('Kişisel Bilgiler'),
              CustomCard(
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Ad',
                      controller: _firstNameController,
                      readOnly: !_isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ad gerekli';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Soyad',
                      controller: _lastNameController,
                      readOnly: !_isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Soyad gerekli';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'E-posta',
                      controller: _emailController,
                      type: TextFieldType.email,
                      readOnly: !_isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E-posta gerekli';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Geçerli bir e-posta adresi girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Telefon',
                      controller: _phoneController,
                      type: TextFieldType.phone,
                      readOnly: !_isEditing,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Account Information
              _buildSectionTitle('Hesap Bilgileri'),
              CustomCard(
                child: Column(
                  children: [
                    _buildInfoRow('Hesap Oluşturma', '15 Ocak 2024'),
                    _buildDivider(),
                    _buildInfoRow('Son Giriş', 'Bugün, 14:30'),
                    _buildDivider(),
                    _buildInfoRow('2FA Durumu', 'Etkin'),
                    _buildDivider(),
                    _buildInfoRow('Hesap Durumu', 'Aktif'),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Security Actions
              _buildSectionTitle('Güvenlik'),
              CustomCard(
                child: Column(
                  children: [
                    _buildActionRow(
                      icon: Icons.lock,
                      title: 'Şifre Değiştir',
                      subtitle: 'Hesap şifrenizi güncelleyin',
                      onTap: _changePassword,
                    ),
                    _buildDivider(),
                    _buildActionRow(
                      icon: Icons.security,
                      title: '2FA Ayarları',
                      subtitle: 'İki faktörlü kimlik doğrulama',
                      onTap: _open2FASettings,
                    ),
                    _buildDivider(),
                    _buildActionRow(
                      icon: Icons.devices,
                      title: 'Cihazlar',
                      subtitle: 'Bağlı cihazları yönetin',
                      onTap: _openDevices,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'İptal',
                        type: ButtonType.outline,
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _loadUserData(); // Reset to original data
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: LoadingButton(
                        text: 'Kaydet',
                        onPressed: _saveProfile,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Düzenle',
                    icon: Icons.edit,
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
                ),
              ],

              SizedBox(height: 32.h),
            ],
          ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.3),
    );
  }

  void _changeAvatar() {
    // TODO: Implement avatar change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar değiştirme özelliği yakında')),
    );
  }

  void _changePassword() {
    // TODO: Navigate to change password page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifre değiştirme sayfasına yönlendiriliyor')),
    );
  }

  void _open2FASettings() {
    // TODO: Navigate to 2FA settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('2FA ayarları sayfasına yönlendiriliyor')),
    );
  }

  void _openDevices() {
    // TODO: Navigate to devices page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cihazlar sayfasına yönlendiriliyor')),
    );
  }
}
