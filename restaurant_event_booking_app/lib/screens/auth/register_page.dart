import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';

/// Modern register page with AuthService integration.
/// 
/// Features:
/// - Clean, modern layout with proper spacing (24px padding)
/// - "Create Account" header with subtitle
/// - Full name, email, phone, password, and confirm password fields
/// - Real-time form validation
/// - Primary register button with loading state
/// - Login link at bottom
/// - AuthService integration for actual registration
/// - Navigates to UserDashboardPage on success
/// - Shows SnackBar on error
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Focus nodes
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  // State
  bool _isLoading = false;
  bool _acceptedTerms = false;
  
  // Services
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = serviceLocator<AuthService>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Validate name
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  /// Validate phone (optional but must be valid if provided)
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    // Basic phone validation - at least 10 digits
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
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

  /// Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Handle registration
  Future<void> _handleRegister() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt registration
      final user = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      );

      if (!mounted) return;

      if (user != null) {
        // Show success message
        _showSuccess('Account created successfully!');
        
        // Navigate to user dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/user-dashboard');
        }
      } else {
        _showError('Registration failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      // Extract error message
      String errorMessage = 'Registration failed. Please try again.';
      if (e.toString().contains('Email already registered')) {
        errorMessage = 'This email is already registered. Please login instead.';
      } else if (e.toString().contains('Invalid email format')) {
        errorMessage = 'Please enter a valid email address.';
      }
      _showError(errorMessage);
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

  /// Show success snackbar
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
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
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to login page
  void _handleLogin() {
    context.go('/login');
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
                  
                  // Back button
                  _buildBackButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 32),
                  
                  // Full name field
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: _validateName,
                    enabled: !_isLoading,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (_) {
                      _emailFocusNode.requestFocus();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                      _phoneFocusNode.requestFocus();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Phone field (optional)
                  CustomTextField(
                    label: 'Phone Number (Optional)',
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: _validatePhone,
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
                    hint: 'Create a password (min. 6 characters)',
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    textInputAction: TextInputAction.next,
                    validator: _validatePassword,
                    enabled: !_isLoading,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (_) {
                      _confirmPasswordFocusNode.requestFocus();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Confirm password field
                  PasswordTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    textInputAction: TextInputAction.done,
                    validator: _validateConfirmPassword,
                    enabled: !_isLoading,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (_) {
                      if (_acceptedTerms) {
                        _handleRegister();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms checkbox
                  _buildTermsCheckbox(),
                  
                  const SizedBox(height: 24),
                  
                  // Register button
                  LoadingButton(
                    label: 'Create Account',
                    onPressed: _acceptedTerms ? _handleRegister : null,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login link
                  _buildLoginLink(),
                  
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
          context.go('/login');
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join ELEGANCE today',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: _isLoading 
          ? null 
          : () {
              setState(() {
                _acceptedTerms = !_acceptedTerms;
              });
            },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _acceptedTerms ? AppColors.accentYellow : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _acceptedTerms ? AppColors.accentYellow : AppColors.border,
                width: 1.5,
              ),
            ),
            child: _acceptedTerms
                ? const Icon(
                    Icons.check,
                    color: AppColors.black,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _handleLogin,
          child: Text(
            'Login',
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