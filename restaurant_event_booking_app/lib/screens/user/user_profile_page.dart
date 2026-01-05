import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../theme/colors.dart';
import '../../widgets/action_card.dart';
import '../../widgets/stat_card.dart';

/// User Profile Page - Display user information and settings
/// 
/// Features:
/// - Profile header with avatar
/// - User info card (phone, email, member since)
/// - Quick stats (bookings, spent, member since)
/// - Actions list (edit profile, settings, help, logout)
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AuthService _authService = serviceLocator<AuthService>();
  final BookingService _bookingService = serviceLocator<BookingService>();

  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final bookings = await _bookingService.getUserBookings(user.id);
        setState(() {
          _bookings = bookings;
        });
      }
    } catch (e) {
      // Ignore load errors for now.
    }
  }

  double get _totalSpent {
    return _bookings
        .where((b) => b.status == BookingStatus.completed)
        .fold<double>(0, (sum, b) => sum + b.total);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: user == null
          ? _buildNoUserState()
          : CustomScrollView(
              slivers: [
                // App bar
                _buildAppBar(),
                
                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Profile header
                      _buildProfileHeader(user.name, user.email),
                      const SizedBox(height: 24),
                      
                      // Quick stats
                      _buildQuickStats(),
                      const SizedBox(height: 32),
                      
                      // Profile info card
                      _buildInfoCard(user),
                      const SizedBox(height: 32),
                      
                      // Actions section
                      _buildActionsSection(),
                      const SizedBox(height: 32),
                      
                      // Logout button
                      _buildLogoutButton(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoUserState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Not Logged In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please login to view your profile',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.black,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/user-dashboard');
          }
        },
      ),
      title: const Text(
        'My Profile',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit profile coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_outlined, color: AppColors.textPrimary, size: 18),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    // Get initials from name
    final nameParts = name.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : name.isNotEmpty ? name[0] : '?';

    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentYellow,
                AppColors.accentOrange,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentYellow.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Name
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        
        // Email
        Text(
          email,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Edit button
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit profile coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentYellow,
            side: const BorderSide(color: AppColors.accentYellow, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Bookings',
            value: '${_bookings.length}',
            icon: Icons.calendar_month_outlined,
            color: AppColors.accentYellow,
            compact: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Spent',
            value: 'RM ${_totalSpent.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
            color: AppColors.green,
            compact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Phone
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone.isNotEmpty ? user.phone : 'Not set',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          
          // Email
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          
          // Member since
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: _formatMemberSince(user.memberSince),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          
          // Total bookings
          _buildInfoRow(
            icon: Icons.event_note_outlined,
            label: 'Total Bookings',
            value: '${_bookings.length}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.accentYellow,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Actions list
        ActionListItem(
          title: 'Edit Profile',
          subtitle: 'Update your information',
          icon: Icons.person_outline,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit profile coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        
        ActionListItem(
          title: 'Change Password',
          subtitle: 'Update your password',
          icon: Icons.lock_outline,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Change password coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
          iconColor: Colors.blue,
        ),
        const SizedBox(height: 10),
        
        ActionListItem(
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          icon: Icons.notifications_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification settings coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
          iconColor: AppColors.accentOrange,
        ),
        const SizedBox(height: 10),
        
        ActionListItem(
          title: 'Help & Support',
          subtitle: 'Get help with your account',
          icon: Icons.help_outline,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help & Support coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
          iconColor: AppColors.green,
        ),
        const SizedBox(height: 10),
        
        ActionListItem(
          title: 'About App',
          subtitle: 'Version 1.0.0',
          icon: Icons.info_outline,
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Elegance',
              applicationVersion: '1.0.0',
              applicationIcon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.black,
                ),
              ),
              children: [
                const Text(
                  'Fine Dining & Events Booking App',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            );
          },
          iconColor: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red.withOpacity(0.15),
          foregroundColor: AppColors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _formatMemberSince(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}