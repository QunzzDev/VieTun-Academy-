# Exam Platform Mobile

Flutter mobile application for the Online Exam Platform.

## Requirements

- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0
- Android Studio / Xcode for platform-specific builds

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

3. Run tests:
```bash
flutter test
```

## Project Structure

```
lib/
├── config/           # Environment and API configuration
│   ├── environment.dart
│   └── api_client.dart
├── models/           # Data models
│   ├── user.dart
│   ├── auth_tokens.dart
│   ├── exam.dart
│   ├── exam_attempt.dart
│   └── question.dart
├── services/         # Business logic services
│   ├── auth_service.dart
│   └── sync_service.dart
├── repositories/     # Data access layer
│   ├── auth_repository.dart
│   └── local_storage_repository.dart
├── screens/          # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   └── home_screen.dart
├── widgets/          # Reusable widgets
│   ├── loading_overlay.dart
│   └── sync_status_indicator.dart
└── main.dart         # App entry point
```

## Features

- **Authentication**: JWT-based login with secure token storage
- **Offline Support**: Local SQLite database for offline exam taking
- **Sync Service**: Automatic answer syncing when connection restores
- **Multi-Environment**: Support for development, staging, and production

## Dependencies

- `dio`: HTTP client for API requests
- `flutter_secure_storage`: Secure token storage
- `sqflite`: Local SQLite database
- `provider`: State management
- `connectivity_plus`: Network connectivity monitoring
- `glados`: Property-based testing

## Environment Configuration

The app supports multiple environments configured via build arguments:

```bash
# Development (default)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter run --dart-define=ENV=production
```

## Testing

Run unit tests:
```bash
flutter test
```

Run property-based tests:
```bash
flutter test test/property/
```

## Requirements Coverage

- **Requirement 12.1**: Mobile app provides same exam functionality as web
- **Requirement 21.1**: Supports separate environments (dev, staging, prod)
