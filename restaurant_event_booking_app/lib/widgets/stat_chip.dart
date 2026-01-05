import 'package:flutter/material.dart';
import '../theme/colors.dart';

class StatChip extends StatelessWidget {
  final String title;
  final String value;

  const StatChip({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: AppColors.accentYellow, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
