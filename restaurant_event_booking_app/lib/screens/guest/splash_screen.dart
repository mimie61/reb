import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';

/// Animated splash screen with elegant branding.
/// 
/// Features:
/// - Dark background with subtle radial gradient
/// - Animated restaurant icon logo
/// - "ELEGANCE" app name with elegant typography
/// - "Fine Dining & Events" tagline
/// - Smooth fade-in and scale animations
/// - Auto-navigates to guest home after 3 seconds
/// - Subtle amber loading indicator
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  // Animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<double> _loadingFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _navigateAfterDelay();
  }

  void _initAnimations() {
    // Logo animation controller (0-800ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Text animation controller (starts at 400ms, runs for 600ms)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Loading animation controller (starts at 1000ms)
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Logo fade and scale animations
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    // Title fade and slide animations
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    // Tagline fade animation (slightly delayed within text controller)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Loading indicator fade animation
    _loadingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _startAnimations() async {
    // Start logo animation immediately
    _logoController.forward();

    // Start text animation after 400ms
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _textController.forward();

    // Start loading animation after 1000ms
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _loadingController.forward();
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/guest-home');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Subtle radial gradient for depth
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.surface.withOpacity(0.3),
              AppColors.black,
              AppColors.black,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildLogo(),
              ),
              
              const SizedBox(height: 32),
              
              // Animated App Name
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleFadeAnimation.value,
                    child: SlideTransition(
                      position: _titleSlideAnimation,
                      child: child,
                    ),
                  );
                },
                child: _buildAppName(),
              ),
              
              const SizedBox(height: 12),
              
              // Animated Tagline
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _taglineFadeAnimation.value,
                    child: child,
                  );
                },
                child: _buildTagline(),
              ),
              
              const Spacer(flex: 2),
              
              // Animated Loading Indicator
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingFadeAnimation.value,
                    child: child,
                  );
                },
                child: _buildLoadingIndicator(),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.accentYellow,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentYellow.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: AppColors.black,
          size: 56,
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppColors.accentYellow,
          AppColors.accentOrange,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        'ELEGANCE',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w300,
          letterSpacing: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return const Text(
      'Fine Dining & Events',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 2,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.accentYellow.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}