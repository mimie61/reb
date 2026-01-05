import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../theme/colors.dart';
import '../../widgets/booking_card.dart';

/// Booking History Page - List of all user bookings
/// 
/// Features:
/// - Filter tabs (All, Upcoming, Completed, Cancelled)
/// - List of booking cards
/// - Pull to refresh
/// - Empty states
/// - Loading states
class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = serviceLocator<AuthService>();
  final BookingService _bookingService = serviceLocator<BookingService>();

  late TabController _tabController;
  List<Booking> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _tabLabels = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final bookings = await _bookingService.getUserBookings(user.id);
        // Sort by event date (newest first)
        bookings.sort((a, b) => b.eventDate.compareTo(a.eventDate));
        setState(() {
          _allBookings = bookings;
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

  List<Booking> _getFilteredBookings(int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return _allBookings;
      case 1: // Upcoming
        return _allBookings.where((b) =>
          b.status == BookingStatus.upcoming ||
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.pending
        ).toList();
      case 2: // Completed
        return _allBookings.where((b) =>
          b.status == BookingStatus.completed
        ).toList();
      case 3: // Cancelled
        return _allBookings.where((b) =>
          b.status == BookingStatus.cancelled
        ).toList();
      default:
        return _allBookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Tab bar
          _buildTabBar(),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) => _buildTabContent(index)),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        'My Bookings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        // Refresh button
        IconButton(
          onPressed: _loadBookings,
          icon: const Icon(
            Icons.refresh,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.accentYellow,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: AppColors.black,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: _tabLabels.map((label) {
          final index = _tabLabels.indexOf(label);
          final count = _getFilteredBookings(index).length;
          return Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (count > 0 && index != 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tabController.index == index
                            ? AppColors.black.withOpacity(0.2)
                            : AppColors.accentYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == index
                              ? AppColors.black
                              : AppColors.accentYellow,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final bookings = _getFilteredBookings(tabIndex);

    if (bookings.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.accentYellow,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return BookingCard(
            booking: bookings[index],
            onTap: () {
              // Show booking details in a bottom sheet
              _showBookingDetails(bookings[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.accentYellow,
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading bookings...',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unable to load bookings',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBookings,
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
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String message;
    String subMessage;
    IconData icon;

    switch (tabIndex) {
      case 1: // Upcoming
        message = 'No upcoming bookings';
        subMessage = 'Your upcoming events will appear here';
        icon = Icons.event_available_outlined;
        break;
      case 2: // Completed
        message = 'No completed bookings';
        subMessage = 'Your past events will appear here';
        icon = Icons.check_circle_outline;
        break;
      case 3: // Cancelled
        message = 'No cancelled bookings';
        subMessage = 'Cancelled reservations will appear here';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No bookings yet';
        subMessage = 'Start planning your next celebration!';
        icon = Icons.calendar_today_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.accentYellow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (tabIndex == 0) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/guest-home'),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Book Your First Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  foregroundColor: AppColors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Package info
                _buildDetailSection('Package', booking.title, Icons.restaurant_menu_outlined),
                const SizedBox(height: 16),
                
                // Date & Time
                _buildDetailSection(
                  'Event Date',
                  _formatDateTime(booking.eventDate),
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),
                
                // Guests
                _buildDetailSection(
                  'Guests',
                  '${booking.guests} people',
                  Icons.people_outline,
                ),
                const SizedBox(height: 16),
                
                // Total
                _buildDetailSection(
                  'Total Amount',
                  'RM ${booking.total.toStringAsFixed(0)}',
                  Icons.payments_outlined,
                  valueColor: AppColors.accentYellow,
                ),
                
                // Notes
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Special Requests',
                    booking.notes!,
                    Icons.notes_outlined,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Reference
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Booking Reference',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${booking.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentYellow,
                      foregroundColor: AppColors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case BookingStatus.pending:
        bgColor = AppColors.accentYellow.withOpacity(0.15);
        textColor = AppColors.accentYellow;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        bgColor = AppColors.green.withOpacity(0.15);
        textColor = AppColors.green;
        label = 'Confirmed';
        break;
      case BookingStatus.upcoming:
        bgColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue;
        label = 'Upcoming';
        break;
      case BookingStatus.completed:
        bgColor = AppColors.textSecondary.withOpacity(0.15);
        textColor = AppColors.textSecondary;
        label = 'Completed';
        break;
      case BookingStatus.cancelled:
        bgColor = AppColors.red.withOpacity(0.15);
        textColor = AppColors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    
    return '$month $day, $year • $hour:$minute $period';
  }
}