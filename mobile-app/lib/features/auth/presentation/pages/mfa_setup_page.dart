import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/config/app_config.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class MFASetupPage extends ConsumerStatefulWidget {
  const MFASetupPage({super.key});

  @override
  ConsumerState<MFASetupPage> createState() => _MFASetupPageState();
}

class _MFASetupPageState extends ConsumerState<MFASetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSetup = false;
  String? _secret;
  String? _qrCodeData;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _setupMFA();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _setupMFA() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final secret = await AuthService.setupMFA();
      setState(() {
        _secret = secret;
        _qrCodeData = 'otpauth://totp/BTCBaran?secret=$secret&issuer=BTCBaran';
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
        _isSetup = true;
        _successMessage = 'İki faktörlü kimlik doğrulama başarıyla kuruldu';
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
        title: const Text('2FA Kurulumu'),
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
                SizedBox(height: 24.h),

                // Icon
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: _isSetup 
                          ? AppConfig.successColor.withOpacity(0.1)
                          : AppConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Icon(
                      _isSetup ? Icons.security : Icons.security,
                      size: 40.sp,
                      color: _isSetup 
                          ? AppConfig.successColor
                          : AppConfig.primaryColor,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Text(
                  _isSetup ? '2FA Kuruldu!' : 'İki Faktörlü Kimlik Doğrulama',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isSetup 
                        ? AppConfig.successColor
                        : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                // Description
                Text(
                  _isSetup
                      ? 'İki faktörlü kimlik doğrulama başarıyla kuruldu. Hesabınız artık daha güvenli.'
                      : 'Hesabınızı daha güvenli hale getirmek için 2FA kurun. Google Authenticator gibi bir uygulama kullanın.',
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

                if (!_isSetup && _secret != null) ...[
                  // QR Code
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'QR Kodu Tarayın',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        QrImageView(
                          data: _qrCodeData!,
                          version: QrVersions.auto,
                          size: 200.w,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Google Authenticator ile QR kodu tarayın',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Manual Key
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manuel Anahtar',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'QR kod çalışmıyorsa bu anahtarı manuel olarak girin:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: SelectableText(
                            _secret!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

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
                    text: '2FA\'yı Etkinleştir',
                    onPressed: _verifyMFA,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ] else if (_isSetup) ...[
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
                ] else if (_isLoading) ...[
                  // Loading
                  Center(
                    child: LoadingIndicator(
                      message: '2FA kurulumu hazırlanıyor...',
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
                            '2FA Hakkında',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppConfig.infoColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '2FA, hesabınızı daha güvenli hale getirir. Giriş yaparken şifrenize ek olarak telefonunuzdaki uygulamadan aldığınız 6 haneli kodu girmeniz gerekir.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppConfig.infoColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Skip Button
                if (!_isSetup)
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: Text(
                      'Şimdi Değil',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
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
