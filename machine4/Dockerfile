FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP, extensions, and curl/unzip/git
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    php \
    php-mysql \
    php-xml \
    php-gd \
    php-curl \
    php-zip \
    php-sqlite3 \
    libapache2-mod-php \
    curl \
    ca-certificates \
    unzip \
    git \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Drupal 7.97
RUN curl -o /tmp/drupal.tar.gz https://ftp.drupal.org/files/projects/drupal-7.97.tar.gz && \
    tar -xzf /tmp/drupal.tar.gz -C /var/www/html --strip-components=1 && \
    rm /tmp/drupal.tar.gz

# Download and install Drush 8.4.8 (supports Drupal 7)
RUN curl -OL https://github.com/drush-ops/drush/releases/download/8.4.8/drush.phar && \
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush

# Configure Apache rewrite and permissions
RUN a2enmod rewrite && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Create temporary staging directory for modules and settings
RUN mkdir -p /tmp/modules
COPY modules/ /tmp/modules/
COPY settings.php /tmp/settings.php
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
