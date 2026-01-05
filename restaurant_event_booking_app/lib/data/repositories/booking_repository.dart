import 'package:sqflite/sqflite.dart';
import '../../models/booking.dart';
import '../database_helper.dart';

/// Abstract interface for Booking repository operations
abstract class BookingRepository {
  Future<List<Booking>> findAll();
  Future<List<Booking>> findByUserId(String userId);
  Future<Booking?> findById(String id);
  Future<void> insert(Booking booking);
  Future<void> update(Booking booking);
  Future<void> delete(String id);
  Future<List<Booking>> findByStatus(BookingStatus status);
  Future<List<Booking>> findByDateRange(DateTime start, DateTime end);
  Future<double> getTotalRevenue();
  Future<void> updateStatus(String id, BookingStatus status);
}

/// SQLite implementation of BookingRepository
class BookingRepositoryImpl implements BookingRepository {
  final DatabaseHelper _databaseHelper;

  BookingRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<Database> get _db => _databaseHelper.database;

  @override
  Future<List<Booking>> findAll() async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableBookings,
        orderBy: 'event_date DESC',
      );

      return maps.map((map) => Booking.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find all bookings: $e');
    }
  }

  @override
  Future<List<Booking>> findByUserId(String userId) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableBookings,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'event_date DESC',
      );

      return maps.map((map) => Booking.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find bookings by user id: $e');
    }
  }

  @override
  Future<Booking?> findById(String id) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableBookings,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return Booking.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to find booking by id: $e');
    }
  }

  @override
  Future<void> insert(Booking booking) async {
    try {
      final db = await _db;
      await db.insert(
        DatabaseHelper.tableBookings,
        booking.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert booking: $e');
    }
  }

  @override
  Future<void> update(Booking booking) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseHelper.tableBookings,
        booking.toMap(),
        where: 'id = ?',
        whereArgs: [booking.id],
      );
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _db;
      await db.delete(
        DatabaseHelper.tableBookings,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  @override
  Future<List<Booking>> findByStatus(BookingStatus status) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableBookings,
        where: 'status = ?',
        whereArgs: [status.name],
        orderBy: 'event_date ASC',
      );

      return maps.map((map) => Booking.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find bookings by status: $e');
    }
  }

  @override
  Future<List<Booking>> findByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableBookings,
        where: 'event_date >= ? AND event_date <= ?',
        whereArgs: [
          start.millisecondsSinceEpoch,
          end.millisecondsSinceEpoch,
        ],
        orderBy: 'event_date ASC',
      );

      return maps.map((map) => Booking.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find bookings by date range: $e');
    }
  }

  @override
  Future<double> getTotalRevenue() async {
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM(total) as total_revenue FROM ${DatabaseHelper.tableBookings} '
        "WHERE status IN ('completed', 'confirmed', 'upcoming')",
      );

      if (result.isEmpty || result.first['total_revenue'] == null) {
        return 0.0;
      }

      return (result.first['total_revenue'] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get total revenue: $e');
    }
  }

  @override
  Future<void> updateStatus(String id, BookingStatus status) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseHelper.tableBookings,
        {
          'status': status.name,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}