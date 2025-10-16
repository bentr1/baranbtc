import 'package:flutter/material.dart';
import '../../../core/utils/color_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_config.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  final double? borderRadius;
  final Color? fillColor;
  final bool filled;
  final InputType inputType;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.filled = false,
    this.inputType = InputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          inputFormatters: _getInputFormatters(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacityDouble(0.6),
          ),
          decoration: _getInputDecoration(theme),
        ),
        if (widget.helperText != null && widget.errorText == null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.inputType) {
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.phone:
        return TextInputType.phone;
      case InputType.number:
        return TextInputType.number;
      case InputType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case InputType.url:
        return TextInputType.url;
      case InputType.multiline:
        return TextInputType.multiline;
      default:
        return widget.keyboardType;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];

    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    switch (widget.inputType) {
      case InputType.phone:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case InputType.number:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case InputType.decimal:
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')));
        break;
      case InputType.tcId:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        formatters.add(LengthLimitingTextInputFormatter(11));
        break;
      default:
        break;
    }

    return formatters;
  }

  InputDecoration _getInputDecoration(ThemeData theme) {
    final borderColor =
        _isFocused ? AppConfig.primaryColor : theme.colorScheme.outline;

    final errorColor = theme.colorScheme.error;

    return InputDecoration(
      hintText: widget.hint,
      prefixText: widget.prefixText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(theme),
      errorText: widget.errorText,
      filled: widget.filled,
      fillColor: widget.fillColor ?? theme.colorScheme.surface,
      contentPadding: widget.contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
        borderSide: BorderSide(color: AppConfig.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
        borderSide:
            BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (widget.inputType == InputType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onPressed: _toggleObscureText,
      );
    }

    return null;
  }
}

// Input types
enum InputType {
  text,
  email,
  password,
  phone,
  number,
  decimal,
  url,
  multiline,
  tcId,
}
