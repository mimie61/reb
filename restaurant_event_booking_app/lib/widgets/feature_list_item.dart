import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A widget that displays a single feature with a checkmark icon.
/// 
/// Used in menu details pages to show what's included in a package.
/// Features:
/// - Amber/gold checkmark icon
/// - Customizable text styling
/// - Optional custom icon
/// - Proper spacing and alignment
class FeatureListItem extends StatelessWidget {
  /// The feature text to display
  final String text;

  /// Optional custom icon (defaults to check_circle)
  final IconData? icon;

  /// Icon color (defaults to amber/gold)
  final Color? iconColor;

  /// Icon size (defaults to 20)
  final double iconSize;

  /// Text style override
  final TextStyle? textStyle;

  /// Padding around the item
  final EdgeInsets padding;

  const FeatureListItem({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
    this.iconSize = 20,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(
              icon ?? Icons.check_circle,
              color: iconColor ?? AppColors.accentYellow,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Text(
              text,
              style: textStyle ?? const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A section that displays a list of features with a title.
/// 
/// Useful for showing "What's Included" sections in package details.
class FeatureSection extends StatelessWidget {
  /// Section title (e.g., "What's Included")
  final String title;

  /// List of feature strings to display
  final List<String> features;

  /// Optional icon for each feature
  final IconData? featureIcon;

  /// Optional icon color
  final Color? iconColor;

  const FeatureSection({
    super.key,
    required this.title,
    required this.features,
    this.featureIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with decorative line
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentYellow.withOpacity(0.5),
                      AppColors.accentYellow.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Feature items
        ...features.map(
          (feature) => FeatureListItem(
            text: feature,
            icon: featureIcon,
            iconColor: iconColor,
          ),
        ),
      ],
    );
  }
}