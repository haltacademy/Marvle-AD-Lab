FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP, and extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    php \
    php-mysql \
    php-xml \
    php-gd \
    php-curl \
    php-zip \
    libapache2-mod-php \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Download and extract WordPress
RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 && \
    rm /tmp/wordpress.tar.gz

# Configure Apache rewrite and permissions
RUN a2enmod rewrite && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy configurations, entrypoints, and plugins
COPY wp-config.php /var/www/html/wp-config.php
COPY install_wp.php /install_wp.php
COPY entrypoint.sh /entrypoint.sh
COPY plugins/ /var/www/html/wp-content/plugins/

# Fix permissions
RUN chmod +x /entrypoint.sh && \
    chown -R www-data:www-data /var/www/html/wp-config.php /var/www/html/wp-content/plugins/

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
