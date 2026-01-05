import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../theme/colors.dart';
import '../../widgets/loading_button.dart';

/// Booking Summary Page - Confirmation after successful booking
/// 
/// Features:
/// - Success animation/icon
/// - Booking reference number
/// - Booking details card
/// - Action buttons (View Bookings, Back to Home)
class BookingSummaryPage extends StatefulWidget {
  /// The booking to display (passed from BookingFormPage)
  final Booking? booking;

  const BookingSummaryPage({super.key, this.booking});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: booking == null
            ? _buildNoBookingState()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    
                    // Success icon with animation
                    _buildSuccessIcon(),
                    const SizedBox(height: 24),
                    
                    // Success message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'Booking Confirmed!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your reservation has been successfully submitted',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Booking reference
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildReferenceCard(booking),
                    ),
                    const SizedBox(height: 24),
                    
                    // Booking details
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildDetailsCard(booking),
                    ),
                    const SizedBox(height: 24),
                    
                    // Contact details
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildContactCard(booking),
                    ),
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildActionButtons(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNoBookingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Booking Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to load booking details',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            LoadingButton(
              label: 'Back to Dashboard',
              onPressed: () => context.go('/user-dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          size: 60,
          color: AppColors.green,
        ),
      ),
    );
  }

  Widget _buildReferenceCard(Booking booking) {
    // Format reference number (first 8 chars of ID)
    final reference = booking.id.substring(0, 8).toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentYellow.withOpacity(0.15),
            AppColors.accentOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentYellow.withOpacity(0.3),
        ),
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
          const SizedBox(height: 8),
          Text(
            '#$reference',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.accentYellow,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusBadge(booking.status),
        ],
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
        label = 'Pending Confirmation';
        break;
      case BookingStatus.confirmed:
        bgColor = AppColors.green.withOpacity(0.15);
        textColor = AppColors.green;
        label = 'Confirmed';
        break;
      default:
        bgColor = AppColors.textSecondary.withOpacity(0.15);
        textColor = AppColors.textSecondary;
        label = status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == BookingStatus.pending
                ? Icons.hourglass_empty
                : Icons.check_circle_outline,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Booking booking) {
    return Container(
      width: double.infinity,
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
            'Booking Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Package
          _buildDetailRow(
            icon: Icons.restaurant_menu_outlined,
            label: 'Package',
            value: booking.title,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          
          // Date & Time
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Event Date',
            value: _formatDateTime(booking.eventDate),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          
          // Guests
          _buildDetailRow(
            icon: Icons.people_outline,
            label: 'Guests',
            value: '${booking.guests} people',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          
          // Total
          _buildDetailRow(
            icon: Icons.payments_outlined,
            label: 'Total Amount',
            value: 'RM ${booking.total.toStringAsFixed(0)}',
            valueColor: AppColors.accentYellow,
            valueBold: true,
          ),
          
          // Notes (if any)
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppColors.border, height: 1),
            ),
            _buildDetailRow(
              icon: Icons.notes_outlined,
              label: 'Special Requests',
              value: booking.notes!,
              multiline: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
    bool multiline = false,
  }) {
    return Row(
      crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: valueBold ? FontWeight.w600 : FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(Booking booking) {
    return Container(
      width: double.infinity,
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
            'Contact Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Phone
          if (booking.contactPhone != null && booking.contactPhone!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    booking.contactPhone!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          
          // Email
          if (booking.contactEmail != null && booking.contactEmail!.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking.contactEmail!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary action
        LoadingButton(
          label: 'View My Bookings',
          icon: Icons.calendar_month_outlined,
          onPressed: () => context.go('/booking-history'),
        ),
        const SizedBox(height: 12),
        
        // Secondary action
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/user-dashboard'),
            icon: const Icon(Icons.home_outlined, size: 20),
            label: const Text(
              'Back to Dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Share action (optional)
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
          icon: const Icon(Icons.share_outlined, size: 18),
          label: const Text('Share Booking Details'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    
    return '$weekday, $month $day, $year at $hour:$minute $period';
  }
}