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

# Create nginx config for API
RUN echo 'server { \n\
    listen 3000; \n\
    server_name _; \n\
    root /var/www/html/public; \n\
    index index.php; \n\
    \n\
    location / { \n\
        try_files $uri $uri/ /index.php?$query_string; \n\
    } \n\
    \n\
    location ~ \.php$ { \n\
        fastcgi_pass 127.0.0.1:9000; \n\
        fastcgi_index index.php; \n\
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \n\
        include fastcgi_params; \n\
    } \n\
    \n\
    location = /health { \n\
        try_files $uri /health.php; \n\
    } \n\
}' > /etc/nginx/http.d/default.conf

# Create supervisord config
RUN echo '[supervisord] \n\
nodaemon=true \n\
user=root \n\
\n\
[program:php-fpm] \n\
command=/usr/local/sbin/php-fpm -F \n\
autostart=true \n\
autorestart=true \n\
\n\
[program:nginx] \n\
command=/usr/sbin/nginx -g "daemon off;" \n\
autostart=true \n\
autorestart=true' > /etc/supervisor/conf.d/supervisord.conf

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
