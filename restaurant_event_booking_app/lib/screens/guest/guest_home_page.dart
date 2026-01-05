// lib/screens/guest/guest_home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_package.dart';
import '../../services/service_locator.dart';
import '../../services/menu_service.dart';
import '../../theme/colors.dart';
import '../../widgets/package_card.dart';
import '../../widgets/loading_button.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  late Future<List<MenuPackage>> _packagesFuture;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  void _loadPackages() {
    _packagesFuture = serviceLocator<MenuService>().getAvailablePackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          _buildAppBar(),
          
          // Hero Section
          SliverToBoxAdapter(
            child: _buildHeroSection(),
          ),
          
          // Section Title
          SliverToBoxAdapter(
            child: _buildSectionTitle(),
          ),
          
          // Packages Grid
          _buildPackagesGrid(),
          
          // Footer Section
          SliverToBoxAdapter(
            child: _buildFooterSection(),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.black.withOpacity(0.95),
      elevation: 0,
      expandedHeight: 60,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo/Brand
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentYellow, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ELEGANCE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.accentYellow,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Login Button
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: OutlinedLoadingButton(
            label: 'Login',
            width: 90,
            height: 38,
            onPressed: () => context.push('/login'),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accentYellow.withOpacity(0.15),
            AppColors.accentOrange.withOpacity(0.08),
            AppColors.black,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroPatternPainter(),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main headline
                const Text(
                  'Experience\nFine Dining Events',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Book your perfect event package for weddings,\ncorporate events, and special celebrations.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    label: 'Explore Packages',
                    icon: Icons.restaurant_menu_outlined,
                    onPressed: () {
                      // Scroll to packages section
                      Scrollable.ensureVisible(
                        context,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accentYellow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Our Packages',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.border,
                    AppColors.border.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesGrid() {
    return FutureBuilder<List<MenuPackage>>(
      future: _packagesFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: _buildLoadingState(),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: _buildErrorState(snapshot.error.toString()),
          );
        }

        final packages = snapshot.data ?? [];

        // Empty state
        if (packages.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        // Packages grid
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final package = packages[index];
                return PackageCard(
                  package: package,
                  compact: true,
                  onTap: () {
                    context.push('/menu-details', extra: package);
                  },
                );
              },
              childCount: packages.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Shimmer placeholders
          for (int i = 0; i < 2; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(child: _buildShimmerCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildShimmerCard()),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentYellow),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading packages...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Image placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.gray.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          // Content placeholders
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.gray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.gray.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.restaurant_menu_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Packages Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for our upcoming\nevent packages and special offers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.red.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Something Went Wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load packages.\nPlease try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedLoadingButton(
            label: 'Retry',
            width: 120,
            onPressed: () {
              setState(() {
                _loadPackages();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Book?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account to start booking your perfect event.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedLoadingButton(
                  label: 'Login',
                  height: 46,
                  onPressed: () => context.push('/login'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LoadingButton(
                  label: 'Sign Up',
                  height: 46,
                  onPressed: () => context.push('/register'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Contact info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'Open daily 10:00 AM - 10:00 PM',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      Offset(size.width * 0.9, size.height * 0.2),
      100,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.9),
      60,
      paint,
    );

    // Draw subtle lines
    final linePaint = Paint()
      ..color = AppColors.accentYellow.withOpacity(0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(0, size.height * (i / 5)),
        Offset(size.width, size.height * (i / 5) + 50),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}