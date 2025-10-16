import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/custom_text_field.dart';
import '../../../../app/widgets/common/loading_indicator.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).verifyEmail(
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

  Future<void> _handleResendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      await ref.read(authProvider.notifier).resendVerificationCode();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doğrulama kodu tekrar gönderildi'),
            backgroundColor: AppConfig.successColor,
          ),
        );
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
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('E-posta Doğrulama'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConfig.defaultPadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                
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
                      Icons.email,
                      size: 40.w,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Title
                Text(
                  'E-posta Doğrulama',
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
                  'E-posta adresinize gönderilen 6 haneli doğrulama kodunu girin.',
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
                    text: 'E-postayı Doğrula',
                    onPressed: _handleVerifyEmail,
                    backgroundColor: AppConfig.primaryColor,
                  ),
                
                SizedBox(height: 24.h),
                
                // Resend Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kod gelmedi mi? ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    if (_isResending)
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _handleResendCode,
                        child: Text(
                          'Tekrar Gönder',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConfig.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
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
                          'Doğrulama kodu 5 dakika içinde geçerliliğini yitirir.',
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
