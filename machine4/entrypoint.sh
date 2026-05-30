#!/bin/bash
set -e

echo "=== Machine 4: Waiting for MySQL database on Machine 1 (172.168.1.1:33060) ==="
until timeout 1 bash -c 'cat < /dev/null > /dev/tcp/172.168.1.1/33060' 2>/dev/null; do
    echo "MySQL is still offline. Waiting..."
    sleep 3
done
echo "=== MySQL is online! Proceeding with Drupal check/installation ==="

# Check if Drupal is already installed
if [ ! -f /var/www/html/sites/default/files/.installed ]; then
    echo "=== Running silent Drupal installation ==="
    
    # Run Drush site-install to build database tables
    drush site-install standard \
      --db-url=mysql://drupal_user:DrupalSecretRogersPassword88!@172.168.1.1:33060/drupal_db \
      --site-name="Stark Industries Drupal Portal" \
      --account-name=admin \
      --account-pass=DrupalWpAdmin123! \
      --yes
      
    # Copy custom modules
    mkdir -p /var/www/html/sites/all/modules/
    cp -r /tmp/modules/* /var/www/html/sites/all/modules/ || true
    
    # Enable the custom module
    drush pm-enable stark_cms_backup --yes || true
    
    # Copy custom settings.php containing LDAP Active Directory credentials comment
    cp /tmp/settings.php /var/www/html/sites/default/settings.php
    
    # Mark as installed
    touch /var/www/html/sites/default/files/.installed
fi

# Set appropriate permissions
chown -R www-data:www-data /var/www/html/sites/default
chmod -R 775 /var/www/html/sites/default

# Write low-privilege web shell compromise flag
echo "FLAG{machine4_drupal_user_compromised}" > /var/www/html/user.txt
chown www-data:www-data /var/www/html/user.txt
chmod 600 /var/www/html/user.txt

# Write root compromise flag
echo "FLAG{machine4_root_compromised}" > /root/root.txt
chmod 600 /root/root.txt

echo "=== Starting Apache Web Server ==="
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
