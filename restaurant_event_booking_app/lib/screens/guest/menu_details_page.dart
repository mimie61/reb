// lib/screens/guest/menu_details_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_package.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';
import '../../theme/colors.dart';
import '../../widgets/feature_list_item.dart';
import '../../widgets/loading_button.dart';

class MenuDetailsPage extends StatelessWidget {
  final MenuPackage? package;

  const MenuDetailsPage({super.key, this.package});

  @override
  Widget build(BuildContext context) {
    // Handle case where no package is passed
    if (package == null) {
      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          title: const Text('Package Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Package not found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedLoadingButton(
                label: 'Go Back',
                width: 120,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/guest-home');
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // Sliver App Bar with hero image
              _buildSliverAppBar(context),
              
              // Content
              SliverToBoxAdapter(
                child: _buildContent(context),
              ),
              
              // Bottom padding for floating button
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          
          // Fixed bottom CTA bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.black,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/guest-home');
            }
          },
        ),
      ),
      actions: [
        // Share button (optional)
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  backgroundColor: AppColors.surface,
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background with pattern
            Container(
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
              child: CustomPaint(
                painter: _HeroPatternPainter(),
              ),
            ),
            // Center icon
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getPackageIcon(),
                    size: 72,
                    color: AppColors.accentYellow.withOpacity(0.7),
                  ),
                  const SizedBox(height: 8),
                  // Premium badge if applicable
                  if (package!.pricePerGuest >= 150)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PREMIUM PACKAGE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black.withOpacity(0.8),
                      AppColors.black,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package title
          Text(
            package!.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Price section
          _buildPriceSection(),
          const SizedBox(height: 24),
          
          // Guest capacity
          _buildGuestCapacity(),
          const SizedBox(height: 24),
          
          // Description
          _buildDescriptionSection(),
          const SizedBox(height: 32),
          
          // Features section
          if (package!.features.isNotEmpty) ...[
            FeatureSection(
              title: "What's Included",
              features: package!.features,
            ),
            const SizedBox(height: 24),
          ],
          
          // Additional info
          _buildAdditionalInfo(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentYellow.withOpacity(0.15),
            AppColors.accentOrange.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Starting from',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'RM ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentYellow,
                    ),
                  ),
                  Text(
                    package!.pricePerGuest.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
              const Text(
                'per person',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Estimated total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Min. ${package!.minGuests} guests',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'From RM ${(package!.pricePerGuest * package!.minGuests).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'total estimate',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCapacity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_outline,
              color: AppColors.accentYellow,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guest Capacity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getGuestCapacityText(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Visual indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${package!.minGuests}${package!.maxGuests != null ? ' - ${package!.maxGuests}' : '+'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'About This Package',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          package!.description,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Advance Booking',
            value: 'Required at least 7 days prior',
          ),
          const Divider(color: AppColors.border, height: 24),
          _buildInfoRow(
            icon: Icons.access_time_outlined,
            title: 'Event Duration',
            value: 'Flexible timing available',
          ),
          const Divider(color: AppColors.border, height: 24),
          _buildInfoRow(
            icon: Icons.room_service_outlined,
            title: 'Service Style',
            value: 'Full-service catering',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.accentYellow.withOpacity(0.8),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final authService = serviceLocator<AuthService>();
    final isLoggedIn = authService.isLoggedIn;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'RM ${package!.pricePerGuest.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentYellow,
                        ),
                      ),
                      const Text(
                        ' /person',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Book button
            LoadingButton(
              label: isLoggedIn ? 'Book This Package' : 'Login to Book',
              width: 180,
              height: 50,
              icon: isLoggedIn ? Icons.event_available : Icons.login,
              onPressed: () {
                if (isLoggedIn) {
                  // Navigate to booking form with package data
                  context.push('/booking-form', extra: package);
                } else {
                  // Navigate to login
                  context.push('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPackageIcon() {
    final title = package!.title.toLowerCase();
    if (title.contains('wedding')) return Icons.favorite;
    if (title.contains('corporate')) return Icons.business_center;
    if (title.contains('birthday')) return Icons.cake;
    if (title.contains('gala') || title.contains('dinner')) return Icons.dinner_dining;
    if (title.contains('bbq') || title.contains('casual')) return Icons.outdoor_grill;
    return Icons.restaurant_menu;
  }

  String _getGuestCapacityText() {
    if (package!.maxGuests != null) {
      return 'This package accommodates ${package!.minGuests} to ${package!.maxGuests} guests';
    }
    return 'Minimum ${package!.minGuests} guests required';
  }
}

/// Custom painter for hero section background pattern
class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentYellow.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.3),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.7),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.85),
      50,
      paint,
    );

    // Draw subtle diagonal lines
    final linePaint = Paint()
      ..color = AppColors.accentYellow.withOpacity(0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(-50 + (i * 80), size.height),
        Offset(size.width * 0.3 + (i * 80), 0),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}