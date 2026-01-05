import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton class for managing SQLite database operations
class DatabaseHelper {
  static const String _databaseName = 'restaurant_booking.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableUsers = 'users';
  static const String tableMenuPackages = 'menu_packages';
  static const String tableBookings = 'bookings';

  // Singleton instance
  static DatabaseHelper? _instance;
  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  /// Factory constructor to return the singleton instance
  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Get the database instance, initializing if necessary
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings (enable foreign keys)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        member_since INTEGER NOT NULL,
        total_bookings INTEGER DEFAULT 0,
        rating REAL DEFAULT 0.0,
        reviews INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create menu_packages table
    await db.execute('''
      CREATE TABLE $tableMenuPackages (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price_per_guest REAL NOT NULL,
        min_guests INTEGER NOT NULL,
        max_guests INTEGER,
        image_path TEXT,
        features TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create bookings table
    await db.execute('''
      CREATE TABLE $tableBookings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        menu_package_id TEXT NOT NULL,
        title TEXT NOT NULL,
        event_date INTEGER NOT NULL,
        guests INTEGER NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        contact_phone TEXT,
        contact_email TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableUsers(id),
        FOREIGN KEY (menu_package_id) REFERENCES $tableMenuPackages(id)
      )
    ''');

    // Create indexes for performance
    await db.execute(
      'CREATE INDEX idx_bookings_user_id ON $tableBookings(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_bookings_status ON $tableBookings(status)',
    );
    await db.execute(
      'CREATE INDEX idx_bookings_event_date ON $tableBookings(event_date)',
    );
    await db.execute(
      'CREATE INDEX idx_menu_packages_active ON $tableMenuPackages(active)',
    );
    await db.execute(
      'CREATE INDEX idx_users_email ON $tableUsers(email)',
    );
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete the database (for testing/reset purposes)
  Future<void> deleteDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}