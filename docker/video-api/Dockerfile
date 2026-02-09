# UniPlus - Video API
# PHP API container

FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libzip-dev \
    oniguruma-dev \
    && mkdir -p /etc/supervisor/conf.d

# Install PHP extensions (json is built-in since PHP 8.0)
RUN docker-php-ext-install -j$(nproc) \
    mbstring \
    zip \
    opcache

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY docker/video-api/src/ /var/www/html/public/

# Copy configuration files
COPY docker/video-api/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/video-api/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/video-api/php.ini /usr/local/etc/php/conf.d/custom.ini

# Set permissions and create non-root user
RUN chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /var/log \
    && chown -R www-data:www-data /var/run \
    && mkdir -p /run/nginx && chown www-data:www-data /run/nginx

# Security: Run as non-root user
USER www-data

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Expose port
EXPOSE 3000

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
