#!/bin/bash
set -e

echo "=== Machine 3: Waiting for MySQL database on Machine 1 (172.168.1.1:33060) ==="
until timeout 1 bash -c 'cat < /dev/null > /dev/tcp/172.168.1.1/33060' 2>/dev/null; do
    echo "MySQL is still offline. Waiting..."
    sleep 3
done
echo "=== MySQL is online! Proceeding with WordPress check/installation ==="

# Execute silent installation of WordPress tables
php /install_wp.php || true

# Write low-privilege web shell compromise flag
echo "FLAG{machine3_wordpress_user_compromised}" > /var/www/html/user.txt
chown www-data:www-data /var/www/html/user.txt
chmod 600 /var/www/html/user.txt

# Write root compromise flag
echo "FLAG{machine3_root_compromised}" > /root/root.txt
chmod 600 /root/root.txt

echo "=== Starting Apache Web Server ==="
# Apache configuration variables
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
