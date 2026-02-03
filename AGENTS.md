# Agent Instructions for Todo App

This is a full-stack Todo application with Vue.js frontend and Laravel backend, containerized with Docker.

## Architecture

- **Frontend**: Vue 3 + Vite (port 5173)
- **Backend**: Laravel 11 + PHP 8.3 (port 8000)
- **Database**: MariaDB 11 (port 3306)
- **Package Manager**: Yarn (frontend), Composer (backend)

## Build Commands

### Docker (Recommended)
```bash
# Start all services
docker compose up -d

# Build specific service
docker compose build --no-cache frontend
docker compose build --no-cache backend

# View logs
docker compose logs -f frontend
docker compose logs -f backend

# Stop all
docker compose down
```

### Frontend (Local Development)
```bash
cd frontend
yarn install
yarn dev          # Start dev server
yarn build        # Production build
yarn preview      # Preview production build
```

### Backend (Local Development)
```bash
cd backend
composer install
php artisan serve --host=0.0.0.0 --port=8000
```

## Test Commands

### Backend Tests (PHPUnit)
```bash
# Run all tests
docker compose exec backend ./vendor/bin/phpunit

# Run single test class
docker compose exec backend ./vendor/bin/phpunit tests/Feature/TodoControllerTest.php

# Run single test method
docker compose exec backend ./vendor/bin/phpunit --filter test_can_create_todo

# Run with coverage
docker compose exec backend ./vendor/bin/phpunit --coverage-html coverage
```

### Frontend Tests
**Note**: No test framework configured. To add:
```bash
cd frontend
yarn add -D vitest @vue/test-utils
# Then create tests/ directory and test files
```

## Lint Commands

### Backend (Laravel Pint)
```bash
# Check code style
docker compose exec backend ./vendor/bin/pint --test

# Fix code style
docker compose exec backend ./vendor/bin/pint

# Fix specific file
docker compose exec backend ./vendor/bin/pint app/Models/Todo.php
```

### Frontend
**Note**: No linter configured. Recommended setup:
```bash
yarn add -D eslint prettier eslint-plugin-vue
```

## Database Commands

```bash
# Run migrations
docker compose exec backend php artisan migrate

# Run migrations with fresh seed
docker compose exec backend php artisan migrate:fresh

# Seed database
docker compose exec backend php artisan db:seed

# Access MariaDB CLI
docker compose exec db mysql -u todo_user -p todo_db
```

## Code Style Guidelines

### PHP (Backend)

**Naming Conventions:**
- Classes: `PascalCase` (e.g., `TodoController`)
- Methods: `camelCase` (e.g., `getAllTodos`)
- Variables: `camelCase` (e.g., `$todoList`)
- Constants: `UPPER_SNAKE_CASE`
- Database tables: `snake_case`, plural (e.g., `todos`)

**Imports:**
- Use fully qualified class names in docblocks
- Group imports: Framework → Vendor → App
- Alphabetical order within groups

```php
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Models\Todo;
```

**Formatting:**
- Follow PSR-12 standards (enforced by Laravel Pint)
- 4 spaces indentation
- Unix line endings (LF)
- Trailing commas in multi-line arrays

**Error Handling:**
- Use try-catch for external calls (API, DB)
- Return proper HTTP status codes
- Use Laravel's validation for requests

```php
public function store(Request $request): JsonResponse
{
    $validated = $request->validate([
        'title' => 'required|string|max:255',
    ]);
    // ...
}
```

### JavaScript/Vue (Frontend)

**Naming Conventions:**
- Components: `PascalCase` (e.g., `TodoList.vue`)
- Composables: `camelCase` with `use` prefix (e.g., `useTodos.js`)
- Variables/Functions: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

**Imports:**
- Vue core imports first
- Third-party libraries next
- Local modules last

```javascript
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { todoApi } from '../services/api.js'
```

**Vue Composition API:**
- Use `<script setup>` syntax
- Group related logic with composables
- Use `ref()` for reactive state
- Use `computed()` for derived state

**Error Handling:**
- Wrap API calls in try-catch
- Use error state variables
- Console.error for debugging

```javascript
const fetchTodos = async () => {
  try {
    const response = await todoApi.getAll()
    todos.value = response.data
  } catch (err) {
    error.value = '取得に失敗しました'
    console.error(err)
  }
}
```

## File Organization

```
frontend/
  src/
    components/     # Vue components
    services/       # API calls
    composables/    # Reusable logic (add as needed)
    views/          # Page components (add as needed)

backend/
  app/
    Http/
      Controllers/  # API controllers
    Models/         # Eloquent models
  routes/
    api.php         # API routes
  database/
    migrations/     # Schema migrations
    factories/      # Model factories (add as needed)
    seeders/        # Database seeders (add as needed)
  tests/
    Feature/        # Feature tests (add as needed)
    Unit/           # Unit tests (add as needed)
```

## API Conventions

- Base URL: `http://localhost:8000/api`
- RESTful resource routes
- JSON responses
- Proper HTTP status codes (200, 201, 204, 400, 404, 500)

## Environment Variables

Frontend uses `VITE_API_URL` (set in docker-compose.yml).
Backend uses Laravel's `.env` file.

## Common Issues

1. **Port conflicts**: Ensure ports 5173, 8000, 3306 are free
2. **Permission issues**: Files created in Docker may have wrong permissions
3. **Yarn lockfile**: Yarn 1.22.19 is fixed in Dockerfile to avoid Yarn 4 issues
4. **Vendor/node_modules**: These are excluded from git and mounted as volumes in Docker

## Adding New Features

1. Backend: Create model → migration → controller → route
2. Frontend: Create API service method → component → integrate
3. Test: Write tests in `backend/tests/Feature/` following existing patterns
4. Run `docker compose exec backend ./vendor/bin/pint` before committing
