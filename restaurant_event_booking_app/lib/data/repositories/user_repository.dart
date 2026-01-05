import 'package:sqflite/sqflite.dart';
import '../../models/user.dart';
import '../database_helper.dart';

/// Abstract interface for User repository operations
abstract class UserRepository {
  Future<User?> findById(String id);
  Future<User?> findByEmail(String email);
  Future<void> insert(User user);
  Future<void> update(User user);
  Future<void> delete(String id);
  Future<List<User>> findAll();
  Future<bool> validateCredentials(String email, String passwordHash);
  Future<void> updateBookingStats(String userId, int totalBookings);
}

/// SQLite implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _databaseHelper;

  UserRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<Database> get _db => _databaseHelper.database;

  @override
  Future<User?> findById(String id) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableUsers,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return User.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to find user by id: $e');
    }
  }

  @override
  Future<User?> findByEmail(String email) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableUsers,
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return User.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to find user by email: $e');
    }
  }

  @override
  Future<void> insert(User user) async {
    try {
      final db = await _db;
      await db.insert(
        DatabaseHelper.tableUsers,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  @override
  Future<void> update(User user) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseHelper.tableUsers,
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _db;
      await db.delete(
        DatabaseHelper.tableUsers,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<List<User>> findAll() async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableUsers,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find all users: $e');
    }
  }

  @override
  Future<bool> validateCredentials(String email, String passwordHash) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableUsers,
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email, passwordHash],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to validate credentials: $e');
    }
  }

  @override
  Future<void> updateBookingStats(String userId, int totalBookings) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseHelper.tableUsers,
        {
          'total_bookings': totalBookings,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Failed to update booking stats: $e');
    }
  }
}