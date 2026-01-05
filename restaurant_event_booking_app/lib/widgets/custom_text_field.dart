import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A reusable custom text field with consistent styling across the app.
/// 
/// Features:
/// - Filled background with dark surface color
/// - Rounded borders (12px radius)
/// - Amber focus border and cursor
/// - Optional prefix and suffix icons
/// - Password visibility toggle support
/// - Form validation support
class CustomTextField extends StatelessWidget {
  /// The label text displayed above the field
  final String label;

  /// Optional hint text shown when field is empty
  final String? hint;

  /// Optional prefix icon (displayed on the left)
  final IconData? prefixIcon;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Optional suffix widget (e.g., visibility toggle button)
  final Widget? suffixIcon;

  /// Controller for the text field
  final TextEditingController? controller;

  /// Validator function for form validation
  final String? Function(String?)? validator;

  /// Keyboard type (email, number, etc.)
  final TextInputType? keyboardType;

  /// Minimum lines for multiline fields
  final int? minLines;

  /// Maximum lines for multiline fields
  final int? maxLines;

  /// Text input action (done, next, etc.)
  final TextInputAction? textInputAction;

  /// Callback when field is submitted
  final void Function(String)? onFieldSubmitted;

  /// Callback when text changes
  final void Function(String)? onChanged;

  /// Whether the field is enabled
  final bool enabled;

  /// Auto-validation mode
  final AutovalidateMode? autovalidateMode;

  /// Focus node for this field
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autovalidateMode,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // Text Field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          minLines: obscureText ? 1 : minLines,
          maxLines: obscureText ? 1 : maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          validator: validator,
          autovalidateMode: autovalidateMode,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.accentYellow,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppColors.textSecondary,
                    size: 22,
                  )
                : null,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accentYellow,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.red,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.5),
                width: 1,
              ),
            ),
            errorStyle: const TextStyle(
              color: AppColors.red,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// A password text field with built-in visibility toggle.
/// 
/// Extends CustomTextField with automatic password visibility toggle functionality.
class PasswordTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;

  const PasswordTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autovalidateMode,
    this.focusNode,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hint: widget.hint,
      prefixIcon: Icons.lock_outline,
      obscureText: _obscureText,
      controller: widget.controller,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      autovalidateMode: widget.autovalidateMode,
      focusNode: widget.focusNode,
      suffixIcon: IconButton(
        onPressed: _toggleVisibility,
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        splashRadius: 20,
      ),
    );
  }
}