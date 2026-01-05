import 'package:flutter/material.dart';
import '../models/menu_package.dart';
import '../theme/colors.dart';

/// A card widget that displays a menu package for grid/list views.
/// 
/// Features:
/// - Package image placeholder with gradient
/// - Package title and description
/// - Price display (prominent, amber)
/// - Guest capacity info
/// - Tap to navigate to details
class PackageCard extends StatelessWidget {
  /// The menu package to display
  final MenuPackage package;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Whether to show a compact version (for smaller grids)
  final bool compact;

  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with gradient
            _buildImagePlaceholder(),
            
            // Content
            Padding(
              padding: EdgeInsets.all(compact ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    package.title,
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 4 : 8),
                  
                  // Description
                  Text(
                    package.description,
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  
                  // Price and guest info row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        'RM ${package.pricePerGuest.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: compact ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentYellow,
                        ),
                      ),
                      // Per person label
                      Text(
                        '/person',
                        style: TextStyle(
                          fontSize: compact ? 11 : 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    // Guest capacity
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getGuestCapacityText(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: compact ? 100 : 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentYellow.withOpacity(0.3),
            AppColors.accentOrange.withOpacity(0.2),
            AppColors.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(),
            ),
          ),
          // Icon
          Center(
            child: Icon(
              _getPackageIcon(),
              size: compact ? 36 : 48,
              color: AppColors.accentYellow.withOpacity(0.6),
            ),
          ),
          // Popular badge (if applicable - first few packages)
          if (package.pricePerGuest >= 150)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getPackageIcon() {
    final title = package.title.toLowerCase();
    if (title.contains('wedding')) return Icons.favorite_outline;
    if (title.contains('corporate')) return Icons.business_center_outlined;
    if (title.contains('birthday')) return Icons.cake_outlined;
    if (title.contains('gala') || title.contains('dinner')) return Icons.dinner_dining_outlined;
    if (title.contains('bbq') || title.contains('casual')) return Icons.outdoor_grill_outlined;
    return Icons.restaurant_menu_outlined;
  }

  String _getGuestCapacityText() {
    if (package.maxGuests != null) {
      return '${package.minGuests} - ${package.maxGuests} guests';
    }
    return 'Min ${package.minGuests} guests';
  }
}

/// Custom painter for subtle background pattern
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentYellow.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw subtle circles pattern
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(
            size.width * (i / 4) - 20,
            size.height * (j / 2) + 20,
          ),
          40,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}