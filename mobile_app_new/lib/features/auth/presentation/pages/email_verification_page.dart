import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  
  bool _isLoading = false;
  bool _isVerified = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AuthService.verifyEmail(_tokenController.text.trim());
      
      setState(() {
        _isVerified = true;
        _successMessage = 'E-posta adresiniz başarıyla doğrulandı';
      });

      // Wait a bit then navigate to dashboard
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement resend verification email
      setState(() {
        _successMessage = 'Doğrulama e-postası tekrar gönderildi';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
        title: const Text('E-posta Doğrulama'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
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
                      color: _isVerified 
                          ? AppConfig.successColor.withOpacity(0.1)
                          : AppConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Icon(
                      _isVerified ? Icons.check_circle : Icons.email,
                      size: 40.sp,
                      color: _isVerified 
                          ? AppConfig.successColor
                          : AppConfig.primaryColor,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Text(
                  _isVerified ? 'E-posta Doğrulandı!' : 'E-posta Doğrulama',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isVerified 
                        ? AppConfig.successColor
                        : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                // Description
                Text(
                  _isVerified
                      ? 'E-posta adresiniz başarıyla doğrulandı. Ana sayfaya yönlendiriliyorsunuz...'
                      : 'E-posta adresinize gönderilen doğrulama kodunu girin.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
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

                if (!_isVerified) ...[
                  // Verification Code Field
                  CustomTextField(
                    label: 'Doğrulama Kodu',
                    hint: '6 haneli kodu girin',
                    controller: _tokenController,
                    type: TextFieldType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
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
                  LoadingButton(
                    text: 'E-postayı Doğrula',
                    onPressed: _verifyEmail,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),

                  SizedBox(height: 24.h),

                  // Resend Button
                  CustomButton(
                    text: 'Kodu Tekrar Gönder',
                    type: ButtonType.outline,
                    onPressed: _resendVerification,
                    isFullWidth: true,
                  ),
                ] else ...[
                  // Success Animation
                  SizedBox(
                    height: 100.h,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppConfig.successColor,
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 32.h),

                // Help Text
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppConfig.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppConfig.infoColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppConfig.infoColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Yardım',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppConfig.infoColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Doğrulama kodu e-posta adresinize gönderildi. Kodu bulamıyorsanız spam klasörünüzü kontrol edin.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppConfig.infoColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Giriş sayfasına dönmek ister misiniz? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
