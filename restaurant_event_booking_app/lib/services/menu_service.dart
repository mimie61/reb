import 'package:uuid/uuid.dart';

import '../data/repositories/menu_package_repository.dart';
import '../models/menu_package.dart';

/// Abstract interface for menu service operations
abstract class MenuService {
  /// Get all menu packages (including inactive)
  Future<List<MenuPackage>> getAllPackages();

  /// Get only available (active) packages
  Future<List<MenuPackage>> getAvailablePackages();

  /// Get a package by ID
  Future<MenuPackage?> getPackageById(String id);

  /// Create a new menu package
  Future<void> createPackage(MenuPackage package);

  /// Update an existing menu package
  Future<void> updatePackage(MenuPackage package);

  /// Delete a menu package
  Future<void> deletePackage(String id);

  /// Seed initial menu data (for first-time setup)
  Future<void> seedInitialData();
}

/// Implementation of MenuService using MenuPackageRepository
class MenuServiceImpl implements MenuService {
  final MenuPackageRepository _menuPackageRepository;
  final Uuid _uuid = const Uuid();

  MenuServiceImpl({required MenuPackageRepository menuPackageRepository})
      : _menuPackageRepository = menuPackageRepository;

  @override
  Future<List<MenuPackage>> getAllPackages() async {
    try {
      return await _menuPackageRepository.findAll();
    } catch (e) {
      throw Exception('Failed to get all packages: $e');
    }
  }

  @override
  Future<List<MenuPackage>> getAvailablePackages() async {
    try {
      return await _menuPackageRepository.findAvailable();
    } catch (e) {
      throw Exception('Failed to get available packages: $e');
    }
  }

  @override
  Future<MenuPackage?> getPackageById(String id) async {
    try {
      return await _menuPackageRepository.findById(id);
    } catch (e) {
      throw Exception('Failed to get package by id: $e');
    }
  }

  @override
  Future<void> createPackage(MenuPackage package) async {
    try {
      await _menuPackageRepository.insert(package);
    } catch (e) {
      throw Exception('Failed to create package: $e');
    }
  }

  @override
  Future<void> updatePackage(MenuPackage package) async {
    try {
      final updatedPackage = package.copyWith(
        updatedAt: DateTime.now(),
      );
      await _menuPackageRepository.update(updatedPackage);
    } catch (e) {
      throw Exception('Failed to update package: $e');
    }
  }

  @override
  Future<void> deletePackage(String id) async {
    try {
      await _menuPackageRepository.delete(id);
    } catch (e) {
      throw Exception('Failed to delete package: $e');
    }
  }

  @override
  Future<void> seedInitialData() async {
    try {
      final now = DateTime.now();

      final packages = [
        MenuPackage(
          id: _uuid.v4(),
          title: 'Basic Wedding Package',
          description:
              'Perfect for intimate wedding celebrations. Includes appetizers, main course, desserts, and basic decorations. Our experienced chefs will create a memorable dining experience for your special day.',
          pricePerGuest: 85.0,
          minGuests: 30,
          maxGuests: 50,
          imagePath: null,
          features: [
            '3-course meal',
            'Welcome drinks',
            'Basic floral centerpieces',
            'White linen tablecloths',
            'Dedicated event coordinator',
          ],
          active: true,
          createdAt: now,
          updatedAt: now,
        ),
        MenuPackage(
          id: _uuid.v4(),
          title: 'Premium Wedding Package',
          description:
              'Elegant wedding package with premium menu selections, live cooking stations, and luxurious decorations. Create unforgettable memories with our signature culinary experience.',
          pricePerGuest: 150.0,
          minGuests: 50,
          maxGuests: 150,
          imagePath: null,
          features: [
            '5-course gourmet meal',
            'Premium wine selection',
            'Live cooking stations',
            'Luxury floral arrangements',
            'Professional MC services',
            'Complimentary wedding cake',
            'Valet parking',
          ],
          active: true,
          createdAt: now,
          updatedAt: now,
        ),
        MenuPackage(
          id: _uuid.v4(),
          title: 'Corporate Lunch Package',
          description:
              'Professional catering solution for corporate meetings and business lunches. Efficient service with diverse menu options to accommodate various dietary requirements.',
          pricePerGuest: 45.0,
          minGuests: 20,
          maxGuests: 100,
          imagePath: null,
          features: [
            'Buffet-style setup',
            'Vegetarian options included',
            'Coffee & tea station',
            'Presentation equipment available',
            'Quick service guarantee',
          ],
          active: true,
          createdAt: now,
          updatedAt: now,
        ),
        MenuPackage(
          id: _uuid.v4(),
          title: 'Birthday Celebration Package',
          description:
              'Make birthdays extra special with our fun and festive celebration package. Includes themed decorations, entertainment options, and a customizable menu.',
          pricePerGuest: 55.0,
          minGuests: 15,
          maxGuests: 80,
          imagePath: null,
          features: [
            'Themed decorations',
            'Birthday cake included',
            'Kids-friendly menu options',
            'Party games & entertainment',
            'Photo booth setup',
            'Goodie bags for guests',
          ],
          active: true,
          createdAt: now,
          updatedAt: now,
        ),
        MenuPackage(
          id: _uuid.v4(),
          title: 'Gala Dinner Package',
          description:
              'Sophisticated evening affair with exquisite fine dining, premium beverages, and elegant ambiance. Perfect for charity events, award ceremonies, and upscale gatherings.',
          pricePerGuest: 200.0,
          minGuests: 100,
          maxGuests: 300,
          imagePath: null,
          features: [
            '7-course fine dining experience',
            'Premium champagne reception',
            'Live orchestra performance',
            'Red carpet entrance',
            'Professional event photography',
            'Luxury table settings',
            'VIP lounge access',
            'Complimentary valet parking',
          ],
          active: true,
          createdAt: now,
          updatedAt: now,
        ),
        MenuPackage(
          id: _uuid.v4(),
          title: 'Casual BBQ Party Package',
          description:
              'Relaxed outdoor BBQ experience perfect for family reunions, team building events, and casual gatherings. Fresh grilled selections with all the classic sides.',
          pricePerGuest: 40.0,
          minGuests: 25,
          maxGuests: 120,
          imagePath: null,
          features: [
            'Live BBQ grilling stations',
            'Variety of meats & seafood',
            'Fresh salad bar',
            'Refreshing beverages included',
            'Outdoor seating arrangements',
            'Background music setup',
          ],
          active: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Insert all packages
      for (final package in packages) {
        await _menuPackageRepository.insert(package);
      }
    } catch (e) {
      throw Exception('Failed to seed initial data: $e');
    }
  }
}