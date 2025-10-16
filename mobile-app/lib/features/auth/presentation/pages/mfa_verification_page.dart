import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class MFAVerificationPage extends ConsumerStatefulWidget {
  const MFAVerificationPage({super.key});

  @override
  ConsumerState<MFAVerificationPage> createState() => _MFAVerificationPageState();
}

class _MFAVerificationPageState extends ConsumerState<MFAVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isVerified = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyMFA() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AuthService.verifyMFA(_codeController.text.trim());
      
      setState(() {
        _isVerified = true;
        _successMessage = 'İki faktörlü kimlik doğrulama başarılı';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('2FA Doğrulama'),
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
                      _isVerified ? Icons.check_circle : Icons.security,
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
                  _isVerified ? 'Doğrulama Başarılı!' : '2FA Doğrulama',
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
                      ? 'İki faktörlü kimlik doğrulama başarılı. Ana sayfaya yönlendiriliyorsunuz...'
                      : 'Telefonunuzdaki authenticator uygulamasından 6 haneli kodu girin.',
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
                    controller: _codeController,
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
                    text: 'Doğrula',
                    onPressed: _verifyMFA,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),

                  SizedBox(height: 24.h),

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
                          'Google Authenticator, Microsoft Authenticator veya benzeri bir uygulama kullanarak 6 haneli kodu alın.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppConfig.infoColor,
                          ),
                        ),
                      ],
                    ),
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

                // Back to Login
                if (!_isVerified)
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
