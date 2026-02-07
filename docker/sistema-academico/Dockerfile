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
COPY docker/sistema-academico/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/sistema-academico/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/sistema-academico/php.ini /usr/local/etc/php/conf.d/custom.ini

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Expose port
EXPOSE 80

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
