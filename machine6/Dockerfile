FROM debian:12-slim

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, MariaDB, PHP 8.2, and extensions required for Joomla 4
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    mariadb-server \
    mariadb-client \
    php \
    libapache2-mod-php \
    php-mysql \
    php-xml \
    php-curl \
    php-gd \
    php-zip \
    php-mbstring \
    php-intl \
    curl \
    unzip \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module
RUN a2enmod rewrite

# Remove default index.html and download Joomla 4.2.5 (vulnerable to CVE-2023-23752)
RUN rm -rf /var/www/html/* \
    && curl -sS -L -o /tmp/joomla.tar.gz https://github.com/joomla/joomla-cms/releases/download/4.2.5/Joomla_4.2.5-Stable-Full_Package.tar.gz \
    && tar -xzf /tmp/joomla.tar.gz -C /var/www/html/ \
    && rm -f /tmp/joomla.tar.gz \
    && chown -R www-data:www-data /var/www/html/

# Copy configuration.php and entrypoint script
COPY configuration.php /var/www/html/configuration.php
COPY entrypoint.sh /entrypoint.sh

RUN chmod 644 /var/www/html/configuration.php \
    && chown www-data:www-data /var/www/html/configuration.php \
    && chmod +x /entrypoint.sh

# Expose HTTP port
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
