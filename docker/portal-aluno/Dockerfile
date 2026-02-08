# UniPlus - Portal do Aluno
# Laravel/PHP application container

FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    git \
    zip \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    mysql-client

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_mysql \
    mbstring \
    zip \
    bcmath \
    opcache \
    intl \
    pcntl

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files (static PHP frontend)
COPY docker/portal-aluno/src/ /var/www/html/public/

# No composer dependencies needed for static PHP

# Copy configuration files
COPY docker/portal-aluno/nginx-main.conf /etc/nginx/nginx.conf
COPY docker/portal-aluno/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/portal-aluno/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/portal-aluno/php.ini /usr/local/etc/php/conf.d/custom.ini

# Set permissions and prepare for non-root user
# Create all directories Nginx needs with proper permissions in /tmp
RUN mkdir -p /tmp/nginx/client_body \
    && mkdir -p /tmp/nginx/proxy \
    && mkdir -p /tmp/nginx/fastcgi \
    && mkdir -p /tmp/nginx/uwsgi \
    && mkdir -p /tmp/nginx/scgi \
    && mkdir -p /run/nginx \
    && mkdir -p /var/lib/nginx/logs \
    && mkdir -p /var/log/nginx \
    && chmod -R 777 /tmp/nginx \
    && chmod 777 /run/nginx \
    && chown -R www-data:www-data /var/lib/nginx \
    && chown -R www-data:www-data /var/log/nginx \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage 2>/dev/null || true \
    && chmod -R 755 /var/www/html/bootstrap/cache 2>/dev/null || true \
    && chown -R www-data:www-data /var/log \
    && chown -R www-data:www-data /var/run \
    && touch /var/run/supervisord.pid \
    && chown www-data:www-data /var/run/supervisord.pid

# Security: Run as non-root user
USER www-data

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Expose port
EXPOSE 80

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
