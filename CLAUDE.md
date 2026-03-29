# CLAUDE.md

This is a full-stack Todo application with Vue.js 3 frontend and Laravel 11 backend, containerized with Docker.

## Quick Reference

| Service | Technology | Port | Location |
|---------|------------|------|----------|
| Frontend | Vue 3 + Vite | 5173 | `/frontend` |
| Backend | Laravel 11 + PHP 8.3 | 8000 | `/backend` |
| Database | MariaDB 11 | 3306 | - |

## Common Commands

### Build & Development

```bash
# Start all services (Docker)
docker compose up -d

# Frontend (local)
cd frontend && yarn install && yarn dev

# Backend (local)
cd backend && composer install && php artisan serve --host=0.0.0.0 --port=8000
```

### Testing

```bash
# Run all backend tests
docker compose exec backend ./vendor/bin/phpunit

# Run single test class
docker compose exec backend ./vendor/bin/phpunit tests/Feature/TodoControllerTest.php

# Run single test method
docker compose exec backend ./vendor/bin/phpunit --filter test_can_create_todo
```

### Linting

```bash
# Check code style
docker compose exec backend ./vendor/bin/pint --test

# Fix code style
docker compose exec backend ./vendor/bin/pint
```

### Database

```bash
# Run migrations
docker compose exec backend php artisan migrate

# Fresh migrate with seed
docker compose exec backend php artisan migrate:fresh

# Access MariaDB CLI
docker compose exec db mysql -u todo_user -p todo_db
```

## Architecture Overview

### Backend (Laravel)

- **Controllers**: `app/Http/Controllers/TodoController.php` - RESTful API with route model binding
- **Models**: `app/Models/Todo.php` - Eloquent model
- **Routes**: `routes/api.php` - API resource routes (`Route::apiResource('todos', TodoController::class)`)
- **Tests**: `tests/Feature/TodoControllerTest.php` - PHPUnit feature tests
- Uses SQLite in-memory for testing (`phpunit.xml`)

### Frontend (Vue 3)

- **Components**: `src/components/TodoList.vue`, `src/components/AdUnit.vue`
- **API Service**: `src/services/api.js` - Centralized Axios HTTP client
- **Entry**: `src/App.vue`, `src/main.js`
- Uses Composition API with `<script setup>` syntax
- Environment-based API URL via `VITE_API_URL`

### AWS Production Deployment

- **Frontend**: S3 static hosting + CloudFront CDN
- **Backend**: AWS Lambda (Bref) + API Gateway + RDS
- **Domain**: Route 53
- **SSL**: ACM (us-east-1 for CloudFront)
- **Secrets**: Systems Manager Parameter Store

## File Structure Patterns

```
frontend/
  src/
    components/     # Vue components (PascalCase)
    services/       # API calls
backend/
  app/
    Http/Controllers/  # API controllers
    Models/            # Eloquent models
  routes/
    api.php            # API routes
  database/
    migrations/        # Schema migrations
  tests/Feature/       # Feature tests
```

## Naming Conventions

- **PHP**: Classes `PascalCase`, methods/variables `camelCase`, constants `UPPER_SNAKE_CASE`
- **Vue**: Components `PascalCase`, composables `use` prefix + `camelCase`
- **Database**: Tables `snake_case`, plural

## Environment Configuration

- Frontend dev: `VITE_API_URL=http://localhost:8000/api` (set in docker-compose.yml)
- Frontend prod: `.env.production` with production API URL
- Backend: Standard Laravel `.env` file
