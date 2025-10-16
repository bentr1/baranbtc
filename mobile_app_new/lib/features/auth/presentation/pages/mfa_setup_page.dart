import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/custom_text_field.dart';
import '../../../../core/config/app_config.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class MFASetupPage extends ConsumerStatefulWidget {
  const MFASetupPage({super.key});

  @override
  ConsumerState<MFASetupPage> createState() => _MFASetupPageState();
}

class _MFASetupPageState extends ConsumerState<MFASetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _mfaSecret;
  String? _qrCode;

  @override
  void initState() {
    super.initState();
    _generateMFASecret();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _generateMFASecret() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await ref.read(authProvider.notifier).generateMFASecret();
      setState(() {
        _mfaSecret = result['secret'];
        _qrCode = result['qrCode'];
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
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _verifyMFASetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).verifyMFASetup(_codeController.text.trim());
      
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 48.h),
                
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      size: 24.w,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.security,
                          size: 40.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Setup 2FA',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add an extra layer of security to your account',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 48.h),
                
                if (_isGenerating) ...[
                  // Loading State
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Generating MFA secret...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_mfaSecret != null) ...[
                  // MFA Setup Instructions
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppConfig.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 48.w,
                          color: AppConfig.primaryColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppConfig.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Use your authenticator app to scan this QR code',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        if (_qrCode != null)
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Image.network(
                              _qrCode!,
                              width: 200.w,
                              height: 200.w,
                            ),
                          ),
                        SizedBox(height: 16.h),
                        Text(
                          'Or enter this code manually:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            _mfaSecret!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
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
                    label: 'Verification Code',
                    hint: 'Enter 6-digit code from your app',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    inputType: InputType.number,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(Icons.verified_user),
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter verification code';
                      }
                      if (value.length != 6) {
                        return 'Verification code must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Verify Button
                  CustomButton(
                    text: 'Verify & Enable 2FA',
                    onPressed: _isLoading ? null : _verifyMFASetup,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                  ),
                ],
                
                SizedBox(height: 24.h),
                
                // Skip for now
                TextButton(
                  onPressed: () => context.go('/dashboard'),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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