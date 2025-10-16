import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/common/custom_button.dart';
import '../../../../app/widgets/common/custom_text_field.dart';
import '../../../../core/config/app_config.dart';
import '../../../../app/providers/auth/auth_provider.dart';

class MFAVerificationPage extends ConsumerStatefulWidget {
  const MFAVerificationPage({super.key});

  @override
  ConsumerState<MFAVerificationPage> createState() => _MFAVerificationPageState();
}

class _MFAVerificationPageState extends ConsumerState<MFAVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyMFA() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).verifyMFA(_codeController.text.trim());
      
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
                        'Two-Factor Authentication',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Enter the 6-digit code from your authenticator app',
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
                
                // Verification Code Field
                CustomTextField(
                  label: 'Verification Code',
                  hint: 'Enter 6-digit code',
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
                  text: 'Verify',
                  onPressed: _isLoading ? null : _verifyMFA,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                ),
                
                SizedBox(height: 24.h),
                
                // Help Text
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppConfig.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
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
                          'If you don\'t have access to your authenticator app, contact support for assistance.',
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