FROM php:8.3-fpm-alpine

# 必要なパッケージをインストール
RUN apk add --no-cache \
    nginx \
    supervisor \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    oniguruma-dev \
    libxml2-dev \
    mysql-client

# PHP拡張をインストール
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip

# Composerをインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Nginx設定
COPY docker/nginx.conf /etc/nginx/http.d/default.conf

# Supervisor設定
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html

# 権限設定
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
