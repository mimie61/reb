import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../data/repositories/user_repository.dart';
import '../models/user.dart';

/// Abstract interface for authentication service
abstract class AuthService {
  /// Current authenticated user (null if not logged in)
  User? get currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Whether a user is currently logged in
  bool get isLoggedIn;

  /// Whether the current user is an admin
  bool get isAdmin;

  /// Login with email and password
  /// Returns the user if successful, null otherwise
  Future<User?> login(String email, String password);

  /// Register a new user
  /// Returns the newly created user
  Future<User?> register(
    String email,
    String password,
    String name, {
    String? phone,
  });

  /// Logout the current user
  Future<void> logout();

  /// Get the current user from storage
  Future<User?> getCurrentUser();
}

/// Implementation of AuthService using UserRepository
class AuthServiceImpl implements AuthService {
  final UserRepository _userRepository;
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  AuthServiceImpl({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  bool get isAdmin => _currentUser?.role == 'admin';

  @override
  Future<User?> login(String email, String password) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return null;
      }

      // Hash the password
      final passwordHash = _hashPassword(password);

      // Validate credentials
      final isValid = await _userRepository.validateCredentials(
        email.toLowerCase().trim(),
        passwordHash,
      );

      if (!isValid) {
        return null;
      }

      // Get the user
      final user = await _userRepository.findByEmail(email.toLowerCase().trim());
      if (user == null) {
        return null;
      }

      // Set current user and notify listeners
      _currentUser = user;
      _authStateController.add(_currentUser);

      return _currentUser;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<User?> register(
    String email,
    String password,
    String name, {
    String? phone,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password length
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Validate name
      if (name.trim().isEmpty) {
        throw Exception('Name is required');
      }

      // Check if email already exists
      final existingUser = await _userRepository.findByEmail(
        email.toLowerCase().trim(),
      );
      if (existingUser != null) {
        throw Exception('Email already registered');
      }

      // Hash the password
      final passwordHash = _hashPassword(password);

      // Create new user
      final now = DateTime.now();
      final newUser = User(
        id: _uuid.v4(),
        name: name.trim(),
        email: email.toLowerCase().trim(),
        phone: phone?.trim() ?? '',
        passwordHash: passwordHash,
        role: 'user',
        memberSince: now,
        totalBookings: 0,
        rating: 0.0,
        reviews: 0,
        createdAt: now,
        updatedAt: now,
      );

      // Insert user into database
      await _userRepository.insert(newUser);

      // Set current user and notify listeners
      _currentUser = newUser;
      _authStateController.add(_currentUser);

      return _currentUser;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  /// Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}