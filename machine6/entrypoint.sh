#!/bin/bash
set -e

# Initialize MariaDB data directory if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "=== Initializing MariaDB data directory ==="
    mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1
fi

# Start MariaDB
echo "=== Starting MariaDB ==="
service mariadb start

# Check if Joomla database is initialized
if ! mysql -u root -e "use joomla_db;" >/dev/null 2>&1; then
    echo "=== Initializing Joomla Database ==="
    mysql -u root -e "CREATE DATABASE joomla_db;"
    mysql -u root -e "CREATE USER 'joomla_user'@'localhost' IDENTIFIED BY 'JoomlaSecretShield2026!';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON joomla_db.* TO 'joomla_user'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"
    
    # Process base.sql to replace prefix placeholder #__ with jos_
    echo "=== Processing Joomla Database Schema ==="
    sed 's/#__/jos_/g' /var/www/html/installation/sql/mysql/base.sql > /tmp/joomla_import.sql
    mysql -u root joomla_db < /tmp/joomla_import.sql
    rm -f /tmp/joomla_import.sql
    
    # Generate bcrypt hash of JoomlaSecretShield2026!
    echo "=== Generating Administrator Password Hash ==="
    BCRYPT_HASH=$(php -r "echo password_hash('JoomlaSecretShield2026!', PASSWORD_DEFAULT);")
    
    # Insert Administrator user (ID 99, Super User)
    echo "=== Registering Administrator Account ==="
    mysql -u root joomla_db -e "INSERT INTO jos_users (id, name, username, email, password, block, sendEmail, registerDate, lastvisitDate, activation, params, lastResetTime, resetCount, otpKey, otep, requireReset) VALUES (99, 'Administrator', 'admin', 'admin@marvel.local', '${BCRYPT_HASH}', 0, 0, NOW(), NOW(), '', '', NOW(), 0, '', '', 0);"
    mysql -u root joomla_db -e "INSERT INTO jos_user_usergroup_map (user_id, group_id) VALUES (99, 8);"
    
    # Clean up installation directory so Joomla allows frontend/backend access
    echo "=== Removing Installation Directory ==="
    rm -rf /var/www/html/installation
fi

# Create Flags
echo "=== Writing Flags ==="
echo "FLAG{machine6_joomla_web_compromised}" > /var/www/html/user.txt
chmod 644 /var/www/html/user.txt
chown www-data:www-data /var/www/html/user.txt

echo "FLAG{machine6_joomla_root_compromised}" > /root/root.txt
chmod 600 /root/root.txt

# Configure SUID privilege escalation challenge (find)
echo "=== Setting up Privilege Escalation Challenge (SUID find) ==="
chown root:root /usr/bin/find
chmod u+s /usr/bin/find

# Set up logs redirection
ln -sf /dev/stdout /var/log/apache2/access.log
ln -sf /dev/stderr /var/log/apache2/error.log

# Start Apache in the foreground
echo "=== Starting Apache Web Server ==="
source /etc/apache2/envvars
exec apache2 -DFOREGROUND
