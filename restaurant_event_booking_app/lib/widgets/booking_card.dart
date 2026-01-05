import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../theme/colors.dart';

/// A card widget that displays booking information.
/// 
/// Features:
/// - Package name and icon
/// - Event date and time
/// - Guest count
/// - Total price
/// - Status badge (color-coded)
/// - Tap to view details
class BookingCard extends StatelessWidget {
  /// The booking to display
  final Booking booking;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Whether to show in compact mode
  final bool compact;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: compact ? 12 : 16),
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and icon
                Expanded(
                  child: Row(
                    children: [
                      // Package icon
                      Container(
                        width: compact ? 36 : 44,
                        height: compact ? 36 : 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getBookingIcon(),
                          color: AppColors.accentYellow,
                          size: compact ? 18 : 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.title,
                              style: TextStyle(
                                fontSize: compact ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatEventDate(),
                              style: TextStyle(
                                fontSize: compact ? 12 : 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _buildStatusBadge(),
              ],
            ),
            
            if (!compact) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              
              // Details row: Guests, Price
              Row(
                children: [
                  // Guests
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.people_outline,
                      label: 'Guests',
                      value: '${booking.guests}',
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border,
                  ),
                  // Total
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.payments_outlined,
                      label: 'Total',
                      value: 'RM ${booking.total.toStringAsFixed(0)}',
                      valueColor: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ],
            
            if (compact) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.guests} guests',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'RM ${booking.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (booking.status) {
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
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  IconData _getBookingIcon() {
    final title = booking.title.toLowerCase();
    if (title.contains('wedding')) return Icons.favorite_outline;
    if (title.contains('corporate')) return Icons.business_center_outlined;
    if (title.contains('birthday')) return Icons.cake_outlined;
    if (title.contains('gala') || title.contains('dinner')) return Icons.dinner_dining_outlined;
    return Icons.restaurant_menu_outlined;
  }

  String _formatEventDate() {
    final date = booking.eventDate;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    
    return '$weekday, $month $day, $year • $hour:$minute $period';
  }
}