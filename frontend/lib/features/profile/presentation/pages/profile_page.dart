import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_card.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/custom_text_field.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Kullanıcı Adı');
  final _emailController = TextEditingController(text: 'user@example.com');
  final _phoneController = TextEditingController();
  
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
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
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            
            // Profile Form
            _buildProfileForm(),
            
            // Account Actions
            _buildAccountActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: AppConfig.primaryColor,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50.w,
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
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // User Info
            Text(
              _nameController.text,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            Text(
              _emailController.text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Member Since
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Üye olma tarihi: Ocak 2024',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppConfig.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kişisel Bilgiler',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Ad Soyad',
                enabled: _isEditing,
                prefixIcon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad soyad gerekli';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16.h),
              
              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'E-posta',
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
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
              
              // Phone Field
              CustomTextField(
                controller: _phoneController,
                label: 'Telefon (Opsiyonel)',
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              
              if (_isEditing) ...[
                SizedBox(height: 24.h),
                
                // Save/Cancel Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'İptal',
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomButton(
                        text: 'Kaydet',
                        onPressed: _saveProfile,
                        backgroundColor: AppConfig.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      padding: EdgeInsets.all(AppConfig.defaultPadding.w),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap İşlemleri',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            _buildActionItem(
              icon: Icons.lock,
              title: 'Şifre Değiştir',
              subtitle: 'Hesap şifrenizi güncelleyin',
              onTap: () => _showChangePasswordDialog(),
            ),
            
            _buildActionItem(
              icon: Icons.security,
              title: '2FA Ayarları',
              subtitle: 'İki faktörlü doğrulama',
              onTap: () => _show2FASettings(),
            ),
            
            _buildActionItem(
              icon: Icons.download,
              title: 'Verilerimi İndir',
              subtitle: 'Hesap verilerinizi indirin',
              onTap: () => _downloadUserData(),
            ),
            
            _buildActionItem(
              icon: Icons.delete,
              title: 'Hesabı Sil',
              subtitle: 'Hesabınızı kalıcı olarak silin',
              onTap: () => _showDeleteAccountDialog(),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? AppConfig.errorColor.withOpacity(0.1)
                      : AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isDestructive 
                      ? AppConfig.errorColor
                      : AppConfig.primaryColor,
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
                        color: isDestructive 
                            ? AppConfig.errorColor
                            : Theme.of(context).colorScheme.onSurface,
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
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Save profile logic here
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla güncellendi'),
          backgroundColor: AppConfig.successColor,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: const Text('Şifre değiştirme sayfası geliştirilecek.'),
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

  void _downloadUserData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri İndirme'),
        content: const Text('Veri indirme işlemi başlatılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veri indirme işlemi başlatıldı'),
                  backgroundColor: AppConfig.successColor,
                ),
              );
            },
            child: const Text('İndir'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Bu işlem geri alınamaz. Hesabınız ve tüm verileriniz kalıcı olarak silinecektir. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete account logic here
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConfig.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
