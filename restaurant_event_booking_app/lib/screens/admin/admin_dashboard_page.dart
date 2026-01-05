import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/booking.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/service_locator.dart';
import '../../theme/colors.dart';
import '../../widgets/action_card.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final BookingService _bookingService = serviceLocator<BookingService>();
  final AuthService _authService = serviceLocator<AuthService>();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _stats = const {};
  List<Booking> _recentBookings = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _bookingService.getBookingStats();
      final bookings = await _bookingService.getAllBookings();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _recentBookings = bookings.take(5).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    context.go('/guest-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ELEGANCE Admin'),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppColors.accentYellow,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (_isLoading) ...[
              _buildLoadingState(),
            ] else if (_error != null) ...[
              _buildErrorState(),
            ] else ...[
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
              const SizedBox(height: 24),
              _buildRecentBookingsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 220,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.accentYellow,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
            'Failed to load dashboard',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadDashboard,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentYellow,
              side: const BorderSide(color: AppColors.accentYellow),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final totalBookings = (_stats['totalBookings'] ?? 0) as int;
    final pendingCount = (_stats['pendingCount'] ?? 0) as int;
    final confirmedCount = (_stats['confirmedCount'] ?? 0) as int;
    final totalRevenue = (_stats['totalRevenue'] ?? 0) as num;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Stats Overview'),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const spacing = 16.0;
            final textScale = MediaQuery.textScaleFactorOf(context);
            final cellWidth =
                (constraints.maxWidth - spacing) / crossAxisCount;
            final minHeight = 140.0 * textScale;
            final ratio = cellWidth / minHeight;
            final childAspectRatio = ratio < 1.3 ? ratio : 1.3;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
              children: [
                StatCard(
                  title: 'Total Bookings',
                  value: totalBookings.toString(),
                  icon: Icons.event_note_outlined,
                  color: AppColors.accentYellow,
                ),
                StatCard(
                  title: 'Pending Bookings',
                  value: pendingCount.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.accentYellow,
                ),
                StatCard(
                  title: 'Confirmed Bookings',
                  value: confirmedCount.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.green,
                ),
                StatCard(
                  title: 'Total Revenue',
                  value: 'RM ${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                  color: AppColors.accentYellow,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Quick Actions'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            ActionCard(
              title: 'Manage Bookings',
              subtitle: 'Update booking status',
              icon: Icons.event_available_outlined,
              onTap: () => context.push('/admin-manage-bookings'),
            ),
            ActionCard(
              title: 'Manage Menu',
              subtitle: 'Packages & pricing',
              icon: Icons.restaurant_menu_outlined,
              onTap: () => context.push('/admin-manage-menu'),
            ),
            ActionCard(
              title: 'Add Package',
              subtitle: 'Create new offer',
              icon: Icons.add_circle_outline,
              onTap: () => context.push('/admin-add-menu'),
            ),
            Opacity(
              opacity: 0.6,
              child: ActionCard(
                title: 'View Reports',
                subtitle: 'Coming soon',
                icon: Icons.bar_chart_outlined,
                iconColor: AppColors.textSecondary,
                iconBackgroundColor: AppColors.gray,
                onTap: _showComingSoon,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Bookings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/admin-manage-bookings'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No recent bookings yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ..._recentBookings.map(_buildRecentBookingCard),
      ],
    );
  }

  Widget _buildRecentBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Booking #${_shortId(booking.id)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(booking.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getCustomerLabel(booking),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatEventDate(booking.eventDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoChip(
                icon: Icons.people_outline,
                label: '${booking.guests} guests',
              ),
              const SizedBox(width: 8),
              _infoChip(
                icon: Icons.payments_outlined,
                label: 'RM ${booking.total.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = AppColors.accentYellow;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        color = AppColors.green;
        label = 'Confirmed';
        break;
      case BookingStatus.completed:
        color = AppColors.textSecondary;
        label = 'Completed';
        break;
      case BookingStatus.cancelled:
        color = AppColors.red;
        label = 'Cancelled';
        break;
      case BookingStatus.upcoming:
        color = Colors.blue;
        label = 'Upcoming';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports are coming soon.')),
    );
  }

  String _shortId(String id) {
    if (id.length <= 6) return id.toUpperCase();
    return id.substring(0, 6).toUpperCase();
  }

  String _getCustomerLabel(Booking booking) {
    final email = booking.contactEmail?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    final notes = booking.notes?.trim();
    if (notes != null && notes.isNotEmpty) {
      return notes;
    }
    return 'Guest Booking';
  }

  String _formatEventDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;

    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$weekday, $month $day, $year • $hour:$minute $period';
  }
}