// lib/app_router.dart
import 'package:go_router/go_router.dart';

// Import your screens
import 'screens/guest/splash_screen.dart';
import 'screens/guest/guest_home_page.dart';
import 'screens/guest/menu_details_page.dart';

import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';

import 'screens/user/user_dashboard_page.dart';
import 'screens/user/booking_form_page.dart';
import 'screens/user/booking_summary_page.dart';
import 'screens/user/booking_history_page.dart';
import 'screens/user/user_profile_page.dart';

import 'screens/admin/admin_dashboard_page.dart';
import 'screens/admin/admin_manage_menu_page.dart';
import 'screens/admin/admin_manage_bookings_page.dart';
import 'screens/admin/admin_add_edit_menu_page.dart';

import 'models/menu_package.dart';
import 'models/booking.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // ✅ Splash screen (entry point)
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // ✅ Guest routes
      GoRoute(
        path: '/guest-home',
        builder: (context, state) => const GuestHomePage(),
      ),
      
      // ✅ Menu details route with extra parameter
      GoRoute(
        path: '/menu-details',
        builder: (context, state) {
          // Get package from extra parameter
          final package = state.extra as MenuPackage?;
          return MenuDetailsPage(package: package);
        },
      ),

      // ✅ Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ✅ User routes
      GoRoute(
        path: '/user-dashboard',
        builder: (context, state) => const UserDashboardPage(),
      ),
      GoRoute(
        path: '/booking-form',
        builder: (context, state) {
          // Get package from extra parameter (optional)
          final package = state.extra as MenuPackage?;
          return BookingFormPage(package: package);
        },
      ),
      GoRoute(
        path: '/booking-summary',
        builder: (context, state) {
          // Get booking from extra parameter
          final booking = state.extra as Booking?;
          return BookingSummaryPage(booking: booking);
        },
      ),
      GoRoute(
        path: '/booking-history',
        builder: (context, state) => const BookingHistoryPage(),
      ),
      GoRoute(
        path: '/user-profile',
        builder: (context, state) => const UserProfilePage(),
      ),

      // ✅ Admin routes
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin-manage-menu',
        builder: (context, state) => const AdminManageMenuPage(),
      ),
      GoRoute(
        path: '/admin-manage-bookings',
        builder: (context, state) => const AdminManageBookingsPage(),
      ),
      GoRoute(
        path: '/admin-add-menu',
        builder: (context, state) {
          final package = state.extra as MenuPackage?;
          return AdminAddEditMenuPage(package: package);
        },
      ),
    ],
  );
}