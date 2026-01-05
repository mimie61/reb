 // lib/main.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'app_router.dart';
import 'data/repositories/user_repository.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'services/menu_service.dart';
import 'services/service_locator.dart';
import 'theme/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupServiceLocator();

  await _seedAdminUserIfMissing();

  // Seed initial data if database is empty
  final menuService = serviceLocator<MenuService>();
  final packages = await menuService.getAllPackages();
  if (packages.isEmpty) {
    await menuService.seedInitialData();
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Restaurant Booking',
      // ✅ Use your wireframe theme
      theme: AppTheme.wireframeTheme,
      // ✅ Connect to your GoRouter configuration
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> _seedAdminUserIfMissing() async {
  serviceLocator<AuthService>();
  final userRepository = serviceLocator<UserRepository>();

  const adminEmail = 'admin@elegance.com';
  const adminPassword = 'admin123';

  final existingAdmin = await userRepository.findByEmail(adminEmail);
  if (existingAdmin != null) {
    return;
  }

  final now = DateTime.now();
  final adminUser = User(
    id: const Uuid().v4(),
    name: 'Admin',
    email: adminEmail,
    phone: '',
    passwordHash: _hashPassword(adminPassword),
    role: 'admin',
    memberSince: now,
    totalBookings: 0,
    rating: 0.0,
    reviews: 0,
    createdAt: now,
    updatedAt: now,
  );

  await userRepository.insert(adminUser);
}

String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}