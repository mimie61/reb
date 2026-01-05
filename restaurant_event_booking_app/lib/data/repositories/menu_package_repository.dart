import 'package:sqflite/sqflite.dart';
import '../../models/menu_package.dart';
import '../database_helper.dart';

/// Abstract interface for MenuPackage repository operations
abstract class MenuPackageRepository {
  Future<List<MenuPackage>> findAll();
  Future<List<MenuPackage>> findAvailable();
  Future<MenuPackage?> findById(String id);
  Future<void> insert(MenuPackage package);
  Future<void> update(MenuPackage package);
  Future<void> delete(String id);
  Future<void> toggleActive(String id, bool active);
}

/// SQLite implementation of MenuPackageRepository
class MenuPackageRepositoryImpl implements MenuPackageRepository {
  final DatabaseHelper _databaseHelper;

  MenuPackageRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<Database> get _db => _databaseHelper.database;

  @override
  Future<List<MenuPackage>> findAll() async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableMenuPackages,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => MenuPackage.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find all menu packages: $e');
    }
  }

  @override
  Future<List<MenuPackage>> findAvailable() async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableMenuPackages,
        where: 'active = ?',
        whereArgs: [1],
        orderBy: 'title ASC',
      );

      return maps.map((map) => MenuPackage.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to find available menu packages: $e');
    }
  }

  @override
  Future<MenuPackage?> findById(String id) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableMenuPackages,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return MenuPackage.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to find menu package by id: $e');
    }
  }

  @override
  Future<void> insert(MenuPackage package) async {
    try {
      final db = await _db;
      await db.insert(
        DatabaseHelper.tableMenuPackages,
        package.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert menu package: $e');
    }
  }

  @override
  Future<void> update(MenuPackage package) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseHelper.tableMenuPackages,
        package.toMap(),
        where: 'id = ?',
        whereArgs: [package.id],
      );
    } catch (e) {
      throw Exception('Failed to update menu package: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _db;
      await db.delete(
        DatabaseHelper.tableMenuPackages,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete menu package: $e');
    }
  }

  @override
  Future<void> toggleActive(String id, bool active) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseHelper.tableMenuPackages,
        {
          'active': active ? 1 : 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to toggle menu package active status: $e');
    }
  }
}