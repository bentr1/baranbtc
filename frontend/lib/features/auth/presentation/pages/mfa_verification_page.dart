import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/custom_text_field.dart';
import '../../../../app/widgets/common/loading_indicator.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class MFAVerificationPage extends ConsumerStatefulWidget {
  const MFAVerificationPage({super.key});

  @override
  ConsumerState<MFAVerificationPage> createState() => _MFAVerificationPageState();
}

class _MFAVerificationPageState extends ConsumerState<MFAVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyMFA() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).verifyMFA(
        _codeController.text.trim(),
      );
      
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('2FA Doğrulama'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConfig.defaultPadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),
                
                // Icon
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Icon(
                      Icons.security,
                      size: 40.w,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Title
                Text(
                  'İki Faktörlü Doğrulama',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 16.h),
                
                // Description
                Text(
                  'Google Authenticator uygulamanızdan 6 haneli doğrulama kodunu girin.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40.h),
                
                // Verification Code Field
                CustomTextField(
                  controller: _codeController,
                  label: 'Doğrulama Kodu',
                  hint: '123456',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.security,
                  maxLength: 6,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Doğrulama kodu gerekli';
                    }
                    if (value.length != 6) {
                      return 'Doğrulama kodu 6 haneli olmalı';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 32.h),
                
                // Verify Button
                if (authState.isLoading)
                  const LoadingIndicator()
                else
                  CustomButton(
                    text: 'Doğrula',
                    onPressed: _handleVerifyMFA,
                    backgroundColor: AppConfig.primaryColor,
                  ),
                
                SizedBox(height: 24.h),
                
                // Back to Login
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Farklı hesap ile giriş yap',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppConfig.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Info Box
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppConfig.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppConfig.infoColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppConfig.infoColor,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Doğrulama kodu 30 saniyede bir yenilenir. Kodunuz çalışmıyorsa bir sonraki kodu bekleyin.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConfig.infoColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
