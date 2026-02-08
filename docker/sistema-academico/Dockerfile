# UniPlus - Sistema Academico
# PHP static frontend container

FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mbstring \
    zip \
    opcache

# Set working directory
WORKDIR /var/www/html

# Copy application files (static PHP frontend)
COPY docker/sistema-academico/src/ /var/www/html/public/

# Copy configuration files
COPY docker/sistema-academico/nginx-main.conf /etc/nginx/nginx.conf
COPY docker/sistema-academico/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/sistema-academico/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/sistema-academico/php.ini /usr/local/etc/php/conf.d/custom.ini

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
