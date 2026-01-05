import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A quick action card for the dashboard grid.
/// 
/// Features:
/// - Icon with colored background
/// - Title text
/// - Optional subtitle
/// - Tap callback
/// - Customizable colors
class ActionCard extends StatelessWidget {
  /// The title of the action
  final String title;

  /// Icon to display
  final IconData icon;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Optional subtitle/description
  final String? subtitle;

  /// Optional color for the icon
  final Color? iconColor;

  /// Optional background color for the icon container
  final Color? iconBackgroundColor;

  /// Whether the card should take full width
  final bool fullWidth;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = iconColor ?? AppColors.accentYellow;
    final bgColor = iconBackgroundColor ?? accentColor.withOpacity(0.15);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            // Subtitle (optional)
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A horizontal action card variant for list display
class ActionListItem extends StatelessWidget {
  /// The title of the action
  final String title;

  /// Icon to display
  final IconData icon;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Optional subtitle/description
  final String? subtitle;

  /// Optional color for the icon
  final Color? iconColor;

  /// Whether to show a chevron arrow
  final bool showChevron;

  /// Optional trailing widget (replaces chevron)
  final Widget? trailing;

  const ActionListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.showChevron = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = iconColor ?? AppColors.accentYellow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing widget or chevron
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// A section of action items with a title
class ActionSection extends StatelessWidget {
  /// Section title
  final String title;

  /// List of action items
  final List<Widget> children;

  /// Optional action button on the right of title
  final Widget? action;

  const ActionSection({
    super.key,
    required this.title,
    required this.children,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 12),
        
        // Children
        ...children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: child,
        )),
      ],
    );
  }
}