import 'package:flutter/material.dart';
import '../theme/colors.dart';

class OutlinedButtonGray extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  const OutlinedButtonGray({super.key, required this.text, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, color: AppColors.textPrimary),
        if (icon != null) const SizedBox(width: 8),
        Text(text),
      ],
    );

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.surface,
      ),
      child: child,
    );
  }
}
