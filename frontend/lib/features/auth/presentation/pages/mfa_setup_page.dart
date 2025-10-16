import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/custom_text_field.dart';
import '../../../../app/widgets/common/loading_indicator.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class MFASetupPage extends ConsumerStatefulWidget {
  const MFASetupPage({super.key});

  @override
  ConsumerState<MFASetupPage> createState() => _MFASetupPageState();
}

class _MFASetupPageState extends ConsumerState<MFASetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  
  bool _showQRCode = false;
  String? _qrCodeData;
  String? _secretKey;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _generateMFA();
  }

  Future<void> _generateMFA() async {
    try {
      final result = await ref.read(authProvider.notifier).generateMFASecret();
      setState(() {
        _qrCodeData = result['qrCode'];
        _secretKey = result['secret'];
        _showQRCode = true;
      });
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

  Future<void> _handleVerifyMFA() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).verifyMFASetup(
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
        title: const Text('2FA Kurulumu'),
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
                SizedBox(height: 20.h),
                
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
                  'Hesabınızın güvenliği için 2FA kurulumu yapmanızı öneriyoruz.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32.h),
                
                if (_showQRCode && _qrCodeData != null) ...[
                  // QR Code
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: _qrCodeData!,
                          version: QrVersions.auto,
                          size: 200.w,
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'QR kodu Google Authenticator ile tarayın',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manuel Anahtar:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SelectableText(
                          _secretKey ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
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
                      text: '2FA\'yı Etkinleştir',
                      onPressed: _handleVerifyMFA,
                      backgroundColor: AppConfig.primaryColor,
                    ),
                ] else ...[
                  // Loading State
                  const LoadingIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    '2FA anahtarı oluşturuluyor...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                SizedBox(height: 24.h),
                
                // Skip Button
                TextButton(
                  onPressed: () => context.go('/dashboard'),
                  child: Text(
                    'Şimdi değil',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Info Box
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppConfig.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppConfig.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: AppConfig.warningColor,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          '2FA kurulumu tamamlandıktan sonra, giriş yaparken her zaman doğrulama kodu girmeniz gerekecek.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConfig.warningColor,
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
