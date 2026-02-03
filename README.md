# Todo App

Vue.js + Laravel + MariaDB で構築したシンプルなTodoアプリケーション。

## 構成

- **Frontend**: Vue.js 3 (Vite)
- **Backend**: Laravel 11 (API専用)
- **Database**: MariaDB 11
- **Package Manager**: Yarn (Frontend)

## ポート

- Frontend: http://localhost:5173
- Backend: http://localhost:8000
- Database: localhost:3306

## セットアップ

### 1. リポジトリの初期化

```bash
# Frontend
cd frontend
git init
git add .
git commit -m "Initial commit"

# Backend
cd ../backend
git init
git add .
git commit -m "Initial commit"
```

### 2. Dockerで起動

```bash
docker compose up -d
```

### 3. 依存関係のインストール

```bash
# Backend
docker compose exec backend composer install

# Frontend
cd frontend
yarn install
```

### 4. データベースセットアップ

```bash
docker compose exec backend php artisan migrate
```

## 開発

### フロントエンド

```bash
cd frontend
yarn dev
```

### バックエンド

```bash
docker compose exec backend php artisan serve --host=0.0.0.0 --port=80
```

## APIエンドポイント

- `GET /api/todos` - Todo一覧取得
- `POST /api/todos` - Todo作成
- `GET /api/todos/{id}` - Todo詳細取得
- `PUT /api/todos/{id}` - Todo更新
- `DELETE /api/todos/{id}` - Todo削除

## 機能

- ✅ Todoの追加
- ✅ Todoの完了/未完了切り替え
- ✅ Todoの編集
- ✅ Todoの削除

## 学習ポイント

- Vue.js Composition API
- Laravel API開発
- Dockerによる環境構築
- RESTful API設計
- フロントエンド・バックエンドの分離
