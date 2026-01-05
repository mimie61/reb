import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A primary button with loading state support.
/// 
/// Features:
/// - Full width by default
/// - Amber/gold background with black text
/// - Rounded corners (12px radius)
/// - Loading state with CircularProgressIndicator
/// - Disabled state while loading
/// - Subtle press animation
class LoadingButton extends StatelessWidget {
  /// The button label text
  final String label;

  /// Callback when button is pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Custom width (null = full width)
  final double? width;

  /// Custom height (default: 52px)
  final double height;

  /// Background color (default: amber/gold)
  final Color? backgroundColor;

  /// Text/icon color (default: black)
  final Color? foregroundColor;

  /// Optional icon to show before label
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.accentYellow;
    final fgColor = foregroundColor ?? AppColors.black;
    final isDisabled = isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withOpacity(0.6),
          disabledForegroundColor: fgColor.withOpacity(0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// A secondary/outlined button with loading state support.
/// 
/// Features:
/// - Transparent background with border
/// - Amber/gold border and text
/// - Rounded corners (12px radius)
/// - Loading state with CircularProgressIndicator
class OutlinedLoadingButton extends StatelessWidget {
  /// The button label text
  final String label;

  /// Callback when button is pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Custom width (null = full width)
  final double? width;

  /// Custom height (default: 52px)
  final double height;

  /// Border and text color (default: amber/gold)
  final Color? color;

  /// Optional icon to show before label
  final IconData? icon;

  const OutlinedLoadingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.accentYellow;
    final isDisabled = isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: btnColor,
          side: BorderSide(
            color: isDisabled ? btnColor.withOpacity(0.5) : btnColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(btnColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDisabled ? btnColor.withOpacity(0.5) : btnColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// A text button with loading state (for links like "Forgot Password?")
class TextLoadingButton extends StatelessWidget {
  /// The button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Text color (default: amber/orange)
  final Color? color;

  const TextLoadingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.accentYellow;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: btnColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(btnColor),
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: btnColor,
              ),
            ),
    );
  }
}