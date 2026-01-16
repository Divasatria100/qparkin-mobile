# AGENTS.md - QParkin Mobile Development Guide

## Build & Test Commands

### Flutter App (qparkin_app)
- **Run app:** `flutter run --dart-define=API_URL=http://192.168.x.xx:8000`
- **Build APK:** `flutter build apk --release`
- **Lint/Analyze:** `flutter analyze`
- **Format code:** `dart format .`
- **Run tests:** `flutter test` or single test: `flutter test test/widget_test.dart`
- **Get dependencies:** `flutter pub get`

### Laravel Backend (qparkin_backend)
- **Dev server:** `composer run dev` (runs server, queue, logs, vite concurrently)
- **Start artisan server:** `php artisan serve`
- **Run tests:** `composer test` or single test: `php artisan test tests/Unit/SomeTest.php`
- **Run migrations:** `php artisan migrate`
- **Clear cache:** `php artisan config:clear`

## Architecture & Codebase Structure

### Flutter App (`qparkin_app/`)
**Clean architecture with layer separation:**
- `lib/config/` - Routes, theme, constants (global config)
- `lib/data/` - Models, API services (HttpClient), QR services
- `lib/logic/` - State management (providers using ChangeNotifier pattern)
- `lib/presentation/` - Screens, widgets, dialogs (UI only, no business logic)
- `lib/utils/` - Helpers, validators (shared utility functions)

**Key Dependencies:** Flutter SDK 3.0+, http, shared_preferences, google_sign_in, flutter_secure_storage

**Database:** SharedPreferences for local storage, plus remote Laravel API

### Laravel Backend (`qparkin_backend/`)
**Standard Laravel 12 structure:**
- `app/` - Controllers, Models, Services, Requests, Resources
- `routes/` - API routes (RESTful endpoints)
- `database/migrations` - Schema definitions
- `database/seeders` - Test data
- `tests/` - Unit & Feature tests (PHPUnit)

**Key Features:** Passport auth, Sanctum, Google Sign-In, QR code generation, Excel export

## Code Style Guidelines

### Dart/Flutter
- **Naming:** Files use `snake_case`, Classes use `PascalCase`, variables use `camelCase`
- **Linting:** Follow `package:flutter_lints` (see analysis_options.yaml)
- **Imports:** Organize as dart imports, package imports, relative imports (separate by blank line)
- **Models:** Every model requires `fromJson()` and `toJson()` methods for API mapping
- **Structure:** Separate concerns—never mix logic/data with UI. Use providers for state.
- **Formatting:** `dart format` auto-formats; run before commits

### PHP/Laravel
- **Naming:** Classes `PascalCase`, methods `camelCase`, database tables `snake_case` plural
- **PSR-4 autoload:** `App\` namespace maps to `app/` directory
- **API responses:** Use Resource classes for consistent JSON output
- **Auth:** Uses Passport/Sanctum tokens; validate in middleware
- **Linting:** Use Laravel Pint (`./vendor/bin/pint`) for code style
