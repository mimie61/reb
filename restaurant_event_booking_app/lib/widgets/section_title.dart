import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  const SectionTitle(this.text, {super.key, this.padding = const EdgeInsets.only(bottom: 12)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }
}
