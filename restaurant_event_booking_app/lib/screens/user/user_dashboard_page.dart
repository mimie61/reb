import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../theme/colors.dart';
import '../../widgets/action_card.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/stat_card.dart';

/// User Dashboard - Main screen for logged-in users
/// 
/// Features:
/// - Welcome section with user greeting
/// - Quick stats (upcoming bookings, total spent)
/// - Quick action cards for navigation
/// - Upcoming bookings preview
class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final AuthService _authService = serviceLocator<AuthService>();
  final BookingService _bookingService = serviceLocator<BookingService>();
  
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final bookings = await _bookingService.getUserBookings(user.id);
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.accentYellow,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(context),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Welcome Section
                    _buildWelcomeSection(user?.name ?? 'Guest'),
                    const SizedBox(height: 24),
                    
                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    _buildQuickActionsSection(context),
                    const SizedBox(height: 32),
                    
                    // Upcoming Bookings
                    _buildUpcomingBookingsSection(context),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentYellow.withOpacity(0.2),
                  AppColors.accentOrange.withOpacity(0.1),
                ],
              ),
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
        // Notification icon
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
              ),
              // Notification badge (optional)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Profile icon
        IconButton(
          onPressed: () => context.push('/user-profile'),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.accentYellow,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection(String userName) {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    final dateString = '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          '$greeting,',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        // User name
        Text(
          userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // Date
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              dateString,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildQuickStats() {
    // Calculate stats from bookings
    final upcomingCount = _bookings.where((b) => 
      b.status == BookingStatus.upcoming || 
      b.status == BookingStatus.confirmed ||
      b.status == BookingStatus.pending
    ).length;
    
    final totalSpent = _bookings
      .where((b) => b.status == BookingStatus.completed)
      .fold<double>(0, (sum, b) => sum + b.total);

    return Row(
      children: [
        Expanded(
          child: StatChipCard(
            label: 'upcoming',
            value: '$upcomingCount',
            icon: Icons.event_outlined,
            valueColor: AppColors.accentYellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatChipCard(
            label: 'spent',
            value: 'RM ${totalSpent.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
            valueColor: AppColors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // 2x2 Grid of actions
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            ActionCard(
              title: 'Browse Packages',
              subtitle: 'Explore our offerings',
              icon: Icons.restaurant_menu_outlined,
              onTap: () => context.push('/guest-home'),
            ),
            ActionCard(
              title: 'My Bookings',
              subtitle: 'View all reservations',
              icon: Icons.calendar_month_outlined,
              onTap: () => context.push('/booking-history'),
              iconColor: Colors.blue,
            ),
            ActionCard(
              title: 'New Booking',
              subtitle: 'Make a reservation',
              icon: Icons.add_circle_outline,
              onTap: () => context.push('/guest-home'),
              iconColor: AppColors.green,
            ),
            ActionCard(
              title: 'My Profile',
              subtitle: 'Account settings',
              icon: Icons.person_outline,
              onTap: () => context.push('/user-profile'),
              iconColor: AppColors.accentOrange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingBookingsSection(BuildContext context) {
    // Filter upcoming bookings
    final upcomingBookings = _bookings.where((b) => 
      b.status == BookingStatus.upcoming || 
      b.status == BookingStatus.confirmed ||
      b.status == BookingStatus.pending
    ).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (upcomingBookings.isNotEmpty)
              TextButton(
                onPressed: () => context.push('/booking-history'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.accentYellow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Content
        if (_isLoading)
          _buildLoadingState()
        else if (_error != null)
          _buildErrorState()
        else if (upcomingBookings.isEmpty)
          _buildEmptyState(context)
        else
          Column(
            children: upcomingBookings
                .map((booking) => BookingCard(
                  booking: booking,
                  compact: true,
                  onTap: () {
                    // TODO: Navigate to booking details
                    context.push('/booking-history');
                  },
                ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.accentYellow,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.red,
          ),
          const SizedBox(height: 12),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadData,
            child: const Text(
              'Try Again',
              style: TextStyle(color: AppColors.accentYellow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_outlined,
              size: 32,
              color: AppColors.accentYellow,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No upcoming events',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start planning your next celebration!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/guest-home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentYellow,
              foregroundColor: AppColors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Book Your First Event',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}