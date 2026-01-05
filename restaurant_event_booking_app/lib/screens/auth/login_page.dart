import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';

/// Modern login page with AuthService integration.
/// 
/// Features:
/// - Clean, modern layout with proper spacing (24px padding)
/// - "Welcome Back" header with subtitle
/// - Email and password fields with validation
/// - Forgot password link (amber colored)
/// - Primary login button with loading state
/// - Register link at bottom
/// - AuthService integration for actual authentication
/// - Navigates to UserDashboardPage or AdminDashboardPage on success
/// - Shows SnackBar on error
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Focus nodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  // State
  bool _isLoading = false;
  
  // Services
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = serviceLocator<AuthService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handle login
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt login
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        // Navigate based on user role
        if (user.role == 'admin') {
          context.go('/admin-dashboard');
        } else {
          context.go('/user-dashboard');
        }
      } else {
        // Show error
        _showError('Invalid email or password');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Login failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Navigate to forgot password (placeholder)
  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Forgot password feature coming soon!'),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Navigate to register page
  void _handleRegister() {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Back button (optional - only show if can pop)
                  _buildBackButton(),
                  
                  const SizedBox(height: 32),
                  
                  // Logo
                  _buildLogo(),
                  
                  const SizedBox(height: 32),
                  
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 32),
                  
                  // Email field
                  CustomTextField(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    enabled: !_isLoading,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password field
                  PasswordTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    textInputAction: TextInputAction.done,
                    validator: _validatePassword,
                    enabled: !_isLoading,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (_) {
                      _handleLogin();
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextLoadingButton(
                      label: 'Forgot Password?',
                      onPressed: _handleForgotPassword,
                      color: AppColors.accentYellow,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login button
                  LoadingButton(
                    label: 'Login',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Register link
                  _buildRegisterLink(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/guest-home');
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.accentYellow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.restaurant_menu,
          color: AppColors.black,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue to ELEGANCE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _handleRegister,
          child: Text(
            'Register',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isLoading 
                  ? AppColors.accentYellow.withOpacity(0.5)
                  : AppColors.accentYellow,
            ),
          ),
        ),
      ],
    );
  }
}