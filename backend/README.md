# Online Exam Platform - Backend API

A Laravel 11.x backend API for the Online Exam Platform.

## Requirements

- PHP 8.2 or higher
- PostgreSQL 14+
- Redis 6+
- Composer 2.x

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   composer install
   ```

3. Copy environment file:
   ```bash
   cp .env.example .env
   ```

4. Generate application key:
   ```bash
   php artisan key:generate
   ```

5. Generate JWT secret:
   ```bash
   php artisan jwt:secret
   ```

6. Configure your database in `.env`:
   ```
   DB_CONNECTION=pgsql
   DB_HOST=127.0.0.1
   DB_PORT=5432
   DB_DATABASE=online_exam_platform
   DB_USERNAME=postgres
   DB_PASSWORD=your_password
   ```

7. Run migrations:
   ```bash
   php artisan migrate
   ```

## Running Tests

The project uses Pest PHP for testing, including property-based tests.

```bash
# Run all tests
php artisan test

# Run specific test file
php vendor/bin/pest tests/Feature/AuditLogImmutabilityTest.php

# Run with coverage
php vendor/bin/pest --coverage
```

## Project Structure

```
backend/
├── app/
│   ├── Exceptions/          # Custom exceptions
│   ├── Http/                # Controllers, Middleware, Requests
│   ├── Models/              # Eloquent models
│   └── Providers/           # Service providers
├── config/                  # Configuration files
├── database/
│   ├── factories/           # Model factories
│   ├── migrations/          # Database migrations
│   └── seeders/             # Database seeders
├── routes/                  # API routes
└── tests/
    ├── Feature/             # Feature/Integration tests
    └── Unit/                # Unit tests
```

## Key Features

- JWT Authentication with refresh tokens
- Role-Based Access Control (RBAC)
- Audit logging with immutability
- PostgreSQL with UUID primary keys
- Redis for caching and sessions

## Database Schema

### Core Tables
- `users` - User accounts with roles
- `students` - Student profiles
- `parents` - Parent profiles
- `teachers` - Teacher profiles
- `parent_student_links` - Parent-student relationships
- `audit_logs` - Immutable audit trail

## API Documentation

API documentation will be available at `/api/documentation` when the server is running.

## License

MIT
