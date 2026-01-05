import 'package:uuid/uuid.dart';

import '../data/repositories/booking_repository.dart';
import '../data/repositories/menu_package_repository.dart';
import '../models/booking.dart';
import '../models/menu_package.dart';

/// Abstract interface for booking service operations
abstract class BookingService {
  /// Get all bookings (admin use)
  Future<List<Booking>> getAllBookings();

  /// Get bookings for a specific user
  Future<List<Booking>> getUserBookings(String userId);

  /// Get a booking by ID
  Future<Booking?> getBookingById(String id);

  /// Create a new booking
  Future<Booking> createBooking(Booking booking);

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status);

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId);

  /// Get bookings filtered by status
  Future<List<Booking>> getBookingsByStatus(String status);

  /// Get booking statistics for dashboard
  Future<Map<String, dynamic>> getBookingStats();
}

/// Implementation of BookingService using BookingRepository
class BookingServiceImpl implements BookingService {
  final BookingRepository _bookingRepository;
  final MenuPackageRepository _menuPackageRepository;
  final Uuid _uuid = const Uuid();

  BookingServiceImpl({
    required BookingRepository bookingRepository,
    required MenuPackageRepository menuPackageRepository,
  })  : _bookingRepository = bookingRepository,
        _menuPackageRepository = menuPackageRepository;

  @override
  Future<List<Booking>> getAllBookings() async {
    try {
      return await _bookingRepository.findAll();
    } catch (e) {
      throw Exception('Failed to get all bookings: $e');
    }
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      return await _bookingRepository.findByUserId(userId);
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    try {
      return await _bookingRepository.findById(id);
    } catch (e) {
      throw Exception('Failed to get booking by id: $e');
    }
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    try {
      // Get the menu package to calculate total price
      final MenuPackage? menuPackage = await _menuPackageRepository.findById(
        booking.menuPackageId,
      );

      if (menuPackage == null) {
        throw Exception('Menu package not found');
      }

      // Validate guest count
      if (booking.guests < menuPackage.minGuests) {
        throw Exception(
          'Minimum guests required: ${menuPackage.minGuests}',
        );
      }

      if (menuPackage.maxGuests != null &&
          booking.guests > menuPackage.maxGuests!) {
        throw Exception(
          'Maximum guests allowed: ${menuPackage.maxGuests}',
        );
      }

      // Calculate total price
      final double totalPrice = menuPackage.pricePerGuest * booking.guests;

      final now = DateTime.now();
      final newBooking = Booking(
        id: booking.id.isEmpty ? _uuid.v4() : booking.id,
        userId: booking.userId,
        menuPackageId: booking.menuPackageId,
        title: booking.title,
        eventDate: booking.eventDate,
        guests: booking.guests,
        total: totalPrice,
        status: BookingStatus.pending,
        notes: booking.notes,
        contactPhone: booking.contactPhone,
        contactEmail: booking.contactEmail,
        createdAt: now,
        updatedAt: now,
      );

      await _bookingRepository.insert(newBooking);
      return newBooking;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final bookingStatus = BookingStatusExtension.fromString(status);
      await _bookingRepository.updateStatus(bookingId, bookingStatus);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingRepository.updateStatus(bookingId, BookingStatus.cancelled);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  @override
  Future<List<Booking>> getBookingsByStatus(String status) async {
    try {
      final bookingStatus = BookingStatusExtension.fromString(status);
      return await _bookingRepository.findByStatus(bookingStatus);
    } catch (e) {
      throw Exception('Failed to get bookings by status: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final allBookings = await _bookingRepository.findAll();
      final totalRevenue = await _bookingRepository.getTotalRevenue();

      // Count bookings by status
      int pendingCount = 0;
      int confirmedCount = 0;
      int completedCount = 0;
      int cancelledCount = 0;
      int upcomingCount = 0;

      for (final booking in allBookings) {
        switch (booking.status) {
          case BookingStatus.pending:
            pendingCount++;
            break;
          case BookingStatus.confirmed:
            confirmedCount++;
            break;
          case BookingStatus.completed:
            completedCount++;
            break;
          case BookingStatus.cancelled:
            cancelledCount++;
            break;
          case BookingStatus.upcoming:
            upcomingCount++;
            break;
        }
      }

      return {
        'totalBookings': allBookings.length,
        'pendingCount': pendingCount,
        'confirmedCount': confirmedCount,
        'completedCount': completedCount,
        'cancelledCount': cancelledCount,
        'upcomingCount': upcomingCount,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Failed to get booking stats: $e');
    }
  }
}