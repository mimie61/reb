import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/service_locator.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_text_field.dart';

class AdminManageBookingsPage extends StatefulWidget {
  const AdminManageBookingsPage({super.key});

  @override
  State<AdminManageBookingsPage> createState() =>
      _AdminManageBookingsPageState();
}

class _AdminManageBookingsPageState extends State<AdminManageBookingsPage> {
  final BookingService _bookingService = serviceLocator<BookingService>();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<Booking> _allBookings = [];
  List<Booking> _filteredBookings = [];
  bool _showSearch = false;
  int _selectedFilter = 0;

  final List<_BookingFilter> _filters = const [
    _BookingFilter(label: 'All'),
    _BookingFilter(label: 'Pending', status: BookingStatus.pending),
    _BookingFilter(label: 'Confirmed', status: BookingStatus.confirmed),
    _BookingFilter(label: 'Completed', status: BookingStatus.completed),
    _BookingFilter(label: 'Cancelled', status: BookingStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await _bookingService.getAllBookings();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _allBookings = bookings;
      });
      _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    final filter = _filters[_selectedFilter];

    var results = _allBookings;

    if (filter.status != null) {
      results = results.where((b) => b.status == filter.status).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((b) {
        final customer = _getCustomerLabel(b).toLowerCase();
        final title = b.title.toLowerCase();
        final id = b.id.toLowerCase();
        return customer.contains(query) ||
            title.contains(query) ||
            id.contains(query);
      }).toList();
    }

    setState(() {
      _filteredBookings = results;
    });
  }

  Future<void> _updateStatus(
    Booking booking,
    BookingStatus status, {
    bool closeSheet = false,
  }) async {
    try {
      await _bookingService.updateBookingStatus(booking.id, status.name);
      await _loadBookings();

      if (!mounted) return;
      if (closeSheet) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${_shortId(booking.id)} marked as ${_statusLabel(status)}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    }
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailCard(
                    children: [
                      _detailRow('Booking ID', _shortId(booking.id)),
                      _detailRow('Customer', _getCustomerLabel(booking)),
                      _detailRow('Package', booking.title),
                      _detailRow('Event Date', _formatEventDate(booking.eventDate)),
                      _detailRow('Guests', '${booking.guests}'),
                      _detailRow('Total', 'RM ${booking.total.toStringAsFixed(0)}'),
                      _detailRow('Status', _statusLabel(booking.status)),
                      if (booking.contactEmail != null &&
                          booking.contactEmail!.isNotEmpty)
                        _detailRow('Email', booking.contactEmail!),
                      if (booking.contactPhone != null &&
                          booking.contactPhone!.isNotEmpty)
                        _detailRow('Phone', booking.contactPhone!),
                      if (booking.notes != null && booking.notes!.isNotEmpty)
                        _detailRow('Notes', booking.notes!),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildActionButtons(booking, closeSheet: true),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin-dashboard');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_showSearch ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        color: AppColors.accentYellow,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (_showSearch) ...[
              CustomTextField(
                label: 'Search',
                hint: 'Customer, package, or booking ID',
                prefixIcon: Icons.search,
                controller: _searchController,
              ),
              const SizedBox(height: 16),
            ],
            _buildFilterChips(),
            const SizedBox(height: 16),
            if (_isLoading) _buildLoadingList(),
            if (!_isLoading && _error != null) _buildErrorState(),
            if (!_isLoading && _error == null) _buildBookingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          final label = _filters[index].label;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = index;
              });
              _applyFilters();
            },
            selectedColor: AppColors.accentYellow,
            backgroundColor: AppColors.gray,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.black : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return Column(
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _ShimmerBox(height: 150),
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
            'Unable to load bookings',
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
            onPressed: _loadBookings,
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

  Widget _buildBookingsList() {
    if (_filteredBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting the filters or refresh again later.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _filteredBookings.map(_buildBookingCard).toList(),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showBookingDetails(booking),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 14),
                _buildActionButtons(booking),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Booking booking, {bool closeSheet = false}) {
    final actions = <Widget>[];

    if (booking.status == BookingStatus.pending) {
      actions.add(
        _actionButton(
          label: 'Confirm',
          color: AppColors.green,
          onTap: () =>
              _updateStatus(booking, BookingStatus.confirmed, closeSheet: closeSheet),
        ),
      );
    }

    if (booking.status == BookingStatus.confirmed) {
      actions.add(
        _actionButton(
          label: 'Complete',
          color: Colors.blue,
          onTap: () =>
              _updateStatus(booking, BookingStatus.completed, closeSheet: closeSheet),
        ),
      );
    }

    if (booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed) {
      actions.add(
        _actionButton(
          label: 'Cancel',
          color: AppColors.red,
          onTap: () =>
              _updateStatus(booking, BookingStatus.cancelled, closeSheet: closeSheet),
        ),
      );
    }

    actions.add(
      _actionButton(
        label: 'Details',
        color: AppColors.gray,
        textColor: AppColors.textPrimary,
        onTap: () => _showBookingDetails(booking),
      ),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
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

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

  Widget _detailCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
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

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.upcoming:
        return 'Upcoming';
    }
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

class _BookingFilter {
  final String label;
  final BookingStatus? status;

  const _BookingFilter({required this.label, this.status});
}

class _ShimmerBox extends StatefulWidget {
  final double height;

  const _ShimmerBox({required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _controller.value * 2 - 1;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            gradient: LinearGradient(
              begin: Alignment(-1 + offset, -0.2),
              end: Alignment(1 + offset, 0.2),
              colors: [
                AppColors.surface,
                AppColors.gray.withOpacity(0.6),
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}