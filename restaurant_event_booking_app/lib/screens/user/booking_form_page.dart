import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../models/menu_package.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

/// Booking Form Page - Create a new booking for a package
/// 
/// Features:
/// - Selected package summary
/// - Event date/time pickers
/// - Guest count with +/- buttons
/// - Contact information (pre-filled from profile)
/// - Special requests/notes
/// - Live price calculation
/// - Form validation
class BookingFormPage extends StatefulWidget {
  /// Optional package to pre-select
  final MenuPackage? package;

  const BookingFormPage({super.key, this.package});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final AuthService _authService = serviceLocator<AuthService>();
  final BookingService _bookingService = serviceLocator<BookingService>();
  
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  MenuPackage? _selectedPackage;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  int _guestCount = 50;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedPackage = widget.package;
    
    // Pre-fill contact info from user profile
    final user = _authService.currentUser;
    if (user != null) {
      _phoneController.text = user.phone;
      _emailController.text = user.email;
    }
    
    // Set initial guest count to package minimum
    if (_selectedPackage != null) {
      _guestCount = _selectedPackage!.minGuests;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    if (_selectedPackage == null) return 0;
    return _selectedPackage!.pricePerGuest * _guestCount;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentYellow,
              onPrimary: AppColors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentYellow,
              onPrimary: AppColors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _incrementGuests() {
    final maxGuests = _selectedPackage?.maxGuests ?? 500;
    if (_guestCount < maxGuests) {
      setState(() {
        _guestCount += 10;
        if (_guestCount > maxGuests) _guestCount = maxGuests;
      });
    }
  }

  void _decrementGuests() {
    final minGuests = _selectedPackage?.minGuests ?? 20;
    if (_guestCount > minGuests) {
      setState(() {
        _guestCount -= 10;
        if (_guestCount < minGuests) _guestCount = minGuests;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a package'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Please log in to make a booking');

      // Combine date and time
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final booking = Booking(
        id: '',
        userId: user.id,
        menuPackageId: _selectedPackage!.id,
        title: _selectedPackage!.title,
        eventDate: eventDateTime,
        guests: _guestCount,
        total: _totalPrice,
        status: BookingStatus.pending,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        contactEmail: _emailController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdBooking = await _bookingService.createBooking(booking);
      
      if (mounted) {
        context.pushReplacement('/booking-summary', extra: createdBooking);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.toString()}'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: _buildAppBar(),
      body: _selectedPackage == null
          ? _buildNoPackageState()
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Package summary
                          _buildPackageSummary(),
                          const SizedBox(height: 32),
                          
                          // Date & Time section
                          _buildSectionTitle('Event Date & Time'),
                          const SizedBox(height: 16),
                          _buildDateTimePickers(),
                          const SizedBox(height: 32),
                          
                          // Guests section
                          _buildSectionTitle('Number of Guests'),
                          const SizedBox(height: 16),
                          _buildGuestSelector(),
                          const SizedBox(height: 32),
                          
                          // Contact section
                          _buildSectionTitle('Contact Information'),
                          const SizedBox(height: 16),
                          _buildContactFields(),
                          const SizedBox(height: 32),
                          
                          // Notes section
                          _buildSectionTitle('Special Requests'),
                          const SizedBox(height: 16),
                          _buildNotesField(),
                          const SizedBox(height: 32),
                          
                          // Price calculator
                          _buildPriceCalculator(),
                          const SizedBox(height: 24),
                          
                          // Terms checkbox
                          _buildTermsCheckbox(),
                          const SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom bar
                  _buildBottomBar(),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Package',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (_selectedPackage != null)
            Text(
              _selectedPackage!.title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoPackageState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Package Selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please select a package from our menu to continue',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LoadingButton(
              label: 'Browse Packages',
              onPressed: () => context.push('/guest-home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Package icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPackageIcon(),
              color: AppColors.accentYellow,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Package info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedPackage!.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'RM ${_selectedPackage!.pricePerGuest.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentYellow,
                      ),
                    ),
                    const Text(
                      ' / person',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Change button
          TextButton(
            onPressed: () => context.push('/guest-home'),
            child: const Text(
              'Change',
              style: TextStyle(
                color: AppColors.accentYellow,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        // Date picker
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.accentYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Time picker
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    color: AppColors.accentYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatTime(_selectedTime),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSelector() {
    final minGuests = _selectedPackage?.minGuests ?? 20;
    final maxGuests = _selectedPackage?.maxGuests ?? 500;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Guest counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement button
              GestureDetector(
                onTap: _decrementGuests,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _guestCount > minGuests
                        ? AppColors.accentYellow.withOpacity(0.15)
                        : AppColors.gray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: _guestCount > minGuests
                        ? AppColors.accentYellow
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Count display
              Column(
                children: [
                  Text(
                    '$_guestCount',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentYellow,
                    ),
                  ),
                  const Text(
                    'guests',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              
              // Increment button
              GestureDetector(
                onTap: _incrementGuests,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _guestCount < maxGuests
                        ? AppColors.accentYellow.withOpacity(0.15)
                        : AppColors.gray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: _guestCount < maxGuests
                        ? AppColors.accentYellow
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Min/max label
          Text(
            'Min: $minGuests • Max: ${maxGuests > 400 ? "Unlimited" : maxGuests}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        CustomTextField(
          label: 'Phone Number',
          hint: 'Enter your phone number',
          prefixIcon: Icons.phone_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Any special requests, dietary requirements, or additional notes...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPriceCalculator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentYellow.withOpacity(0.1),
            AppColors.accentOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentYellow.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Calculation row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_guestCount guests × RM ${_selectedPackage!.pricePerGuest.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'RM ${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border),
          ),
          
          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'RM ${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _agreedToTerms = !_agreedToTerms;
        });
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _agreedToTerms ? AppColors.accentYellow : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms ? AppColors.accentYellow : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check, size: 16, color: AppColors.black)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(color: AppColors.accentYellow),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Booking Policy',
                    style: TextStyle(color: AppColors.accentYellow),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'RM ${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ),
            
            // Book button
            Expanded(
              child: LoadingButton(
                label: 'Confirm Booking',
                isLoading: _isLoading,
                onPressed: _submitBooking,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPackageIcon() {
    final title = _selectedPackage!.title.toLowerCase();
    if (title.contains('wedding')) return Icons.favorite_outline;
    if (title.contains('corporate')) return Icons.business_center_outlined;
    if (title.contains('birthday')) return Icons.cake_outlined;
    if (title.contains('gala') || title.contains('dinner')) return Icons.dinner_dining_outlined;
    return Icons.restaurant_menu_outlined;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}