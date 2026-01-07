# Restaurant Event Booking App

Flutter-based mobile app for restaurant event bookings with guest, user, and admin flows. Uses SQLite persistence, repository/service layers, and dependency injection.

## Features

### Guest
- Splash screen with branding
- Browse available menu packages
- View package details
- Access login/register

### User
- Register and login
- Create event bookings (date, time, guests, notes)
- Booking summary and history
- Profile and account info

### Admin
- Dashboard metrics overview
- Manage bookings (status updates, filtering)
- Manage menu packages (create, edit, activate/deactivate, delete)

### UX
- Dark theme UI
- Reusable widget library
- Consistent navigation patterns

## Tech Stack
- Flutter (Dart)
- SQLite via sqflite
- go_router
- get_it
- uuid
- crypto (SHA256 hashing)

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio or VS Code with Flutter extensions

### Install and Run
```
flutter pub get
flutter run
```



## Project Structure
```
lib/
  app_router.dart
  main.dart
  data/
  models/
  screens/
    admin/
    auth/
    guest/
    user/
  services/
  theme/
  widgets/
```

## Architecture Notes
- SQLite persistence via repository layer
- Service layer for business logic
- get_it service locator for DI
- go_router for navigation
