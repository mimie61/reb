import 'package:get_it/get_it.dart';

import '../data/database_helper.dart';
import '../data/repositories/repositories.dart';
import 'auth_service.dart';
import 'menu_service.dart';
import 'booking_service.dart';

/// Global service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Setup and register all dependencies
/// Must be called before runApp() in main.dart
Future<void> setupServiceLocator() async {
  // ============================================
  // 1. Register DatabaseHelper (singleton)
  // ============================================
  serviceLocator.registerLazySingleton<DatabaseHelper>(
    () => DatabaseHelper(),
  );

  // ============================================
  // 2. Register Repositories (singletons)
  // ============================================
  serviceLocator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      databaseHelper: serviceLocator<DatabaseHelper>(),
    ),
  );

  serviceLocator.registerLazySingleton<MenuPackageRepository>(
    () => MenuPackageRepositoryImpl(
      databaseHelper: serviceLocator<DatabaseHelper>(),
    ),
  );

  serviceLocator.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      databaseHelper: serviceLocator<DatabaseHelper>(),
    ),
  );

  // ============================================
  // 3. Register Services (singletons)
  // ============================================
  serviceLocator.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(
      userRepository: serviceLocator<UserRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<MenuService>(
    () => MenuServiceImpl(
      menuPackageRepository: serviceLocator<MenuPackageRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<BookingService>(
    () => BookingServiceImpl(
      bookingRepository: serviceLocator<BookingRepository>(),
      menuPackageRepository: serviceLocator<MenuPackageRepository>(),
    ),
  );
}

/// Reset the service locator (useful for testing)
Future<void> resetServiceLocator() async {
  await serviceLocator.reset();
}