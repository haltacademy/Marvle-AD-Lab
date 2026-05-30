#!/bin/bash

# Add steverogers NOPASSWD: /usr/bin/find to sudoers for LPE challenge
echo "steverogers ALL=(root) NOPASSWD: /usr/bin/find" >> /etc/sudoers || true

# 1. Initialize SSH Host Keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi
# Configure SSH to listen on custom port 2222
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config || true
if ! grep -q "^Port\s*=" /etc/ssh/sshd_config; then
    echo "Port 2222" >> /etc/ssh/sshd_config
fi

# 2. Configure MySQL to listen on all interfaces and custom port 33060
sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i 's/port\s*=\s*3306/port = 33060/' /etc/mysql/mysql.conf.d/mysqld.cnf || true
if ! grep -q "^port\s*=" /etc/mysql/mysql.conf.d/mysqld.cnf; then
    sed -i '/\[mysqld\]/a port = 33060' /etc/mysql/mysql.conf.d/mysqld.cnf
fi

# Ensure mysql directories have proper permissions
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Initialize MySQL data directory if empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysqld --initialize-insecure --user=mysql
fi

# Start MySQL database setup in the background so it does not block the container startup
(
    # Wait for MySQL to start up (up to 30 seconds)
    for i in {1..30}; do
        if mysqladmin ping -h localhost --silent; then
            break
        fi
        sleep 1
    done

    # If connection is successful without a password, configure database/users
    if mysql -u root -e "status" >/dev/null 2>&1; then
        mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';"
        
        # Create database and key MySQL users
        mysql -u root -prootpassword -e "CREATE DATABASE IF NOT EXISTS lab_db;"
        mysql -u root -prootpassword -e "CREATE DATABASE IF NOT EXISTS wordpress_db;"
        mysql -u root -prootpassword -e "CREATE DATABASE IF NOT EXISTS drupal_db;"
        mysql -u root -prootpassword -e "CREATE USER 'tonystark'@'%' IDENTIFIED BY 'iamironman';"
        mysql -u root -prootpassword -e "CREATE USER 'steverogers'@'%' IDENTIFIED BY 'capshield75';"
        mysql -u root -prootpassword -e "CREATE USER 'loki'@'%' IDENTIFIED BY 'godofmischief';"
        mysql -u root -prootpassword -e "CREATE USER 'wp_user'@'%' IDENTIFIED BY 'WpSecretStarkPassword77!';"
        mysql -u root -prootpassword -e "CREATE USER 'drupal_user'@'%' IDENTIFIED BY 'DrupalSecretRogersPassword88!';"
        mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON lab_db.* TO 'tonystark'@'%';"
        mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON lab_db.* TO 'steverogers'@'%';"
        mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON lab_db.* TO 'loki'@'%';"
        mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'%';"
        mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON drupal_db.* TO 'drupal_user'@'%';"
        
        # Create and populate credentials table with hashes
        mysql -u root -prootpassword -e "USE lab_db; CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL, password_hash VARCHAR(100) NOT NULL, hash_type VARCHAR(20) NOT NULL, role VARCHAR(50) DEFAULT 'user');"
        
        mysql -u root -prootpassword -e "USE lab_db; INSERT INTO users (username, password_hash, hash_type, role) VALUES \
            ('tonystark', SHA2('iamironman', 256), 'SHA-256', 'Admin/IronMan'), \
            ('steverogers', SHA2('capshield75', 256), 'SHA-256', 'Leader/CaptainAmerica'), \
            ('thor', SHA1('godofthunder'), 'SHA-1', 'Avenger/Thor'), \
            ('brucebanner', MD5('hulksmash!'), 'MD5', 'Avenger/Hulk'), \
            ('natasharomanoff', SHA2('blackwidow', 256), 'SHA-256', 'Spy/BlackWidow'), \
            ('clintbarton', SHA1('hawkeye123'), 'SHA-1', 'Avenger/Hawkeye'), \
            ('nickfury', MD5('motherfury'), 'MD5', 'Director/SHIELD'), \
            ('peterparker', SHA2('spideyweb', 256), 'SHA-256', 'Hero/SpiderMan'), \
            ('wandamaximoff', SHA2('scarletwitch', 256), 'SHA-256', 'Avenger/ScarletWitch'), \
            ('vision', SHA1('mindstone'), 'SHA-1', 'Avenger/Vision'), \
            ('tchalla', SHA2('wakandaforever', 256), 'SHA-256', 'King/BlackPanther'), \
            ('stephenstrange', SHA2('sorcerersupreme', 256), 'SHA-256', 'Sorcerer/DoctorStrange'), \
            ('caroldanvers', SHA1('captainmarvel'), 'SHA-1', 'Avenger/CaptainMarvel'), \
            ('buckybarnes', MD5('wintersoldier'), 'MD5', 'Soldier/WinterSoldier'), \
            ('samwilson', SHA2('falconfly', 256), 'SHA-256', 'Avenger/Falcon'), \
            ('scottlang', SHA1('antman88'), 'SHA-1', 'Avenger/AntMan'), \
            ('hopedyne', MD5('waspsting'), 'MD5', 'Avenger/Wasp'), \
            ('loki', SHA2('godofmischief', 256), 'SHA-256', 'Villain/Loki'), \
            ('thanos', SHA2('inevitable', 256), 'SHA-256', 'Titan/Thanos'), \
            ('philcoulson', SHA1('tahiti_is_nice'), 'SHA-1', 'Agent/SHIELD');"
        
        mysql -u root -prootpassword -e "FLUSH PRIVILEGES;"
    fi
) &

# Configure Postfix to run on custom port 2525
sed -i 's/^smtp\s*inet/2525      inet/' /etc/postfix/master.cf || true

# 3. Configure NFS Exports
# Ensure rpcbind directory exists
mkdir -p /run/sendsigs.omit.d

# Start rpcbind directly (needed for NFS)
/usr/sbin/rpcbind

# Export directories defined in /etc/exports
exportfs -a

# Start kernel NFS daemon threads (returns immediately)
/usr/sbin/rpc.nfsd 8

# Start background loop to generate NTLM traffic for SMB relay attacks.
# This loop attempts to connect to the non-existent server 'stark-backup'
# using the Domain Admin credentials (MARVEL\tonystark).
# Since it broadcasts a WINS/NetBIOS query, Responder will poison it and redirect it
# to the local ntlmrelayx instance which relays the Admin session to Machine 2.
(
    echo "=== Initializing SMB Relay Traffic Generator ==="
    sleep 45
    while true; do
        echo "=== Simulating admin SMB connection to stark-backup ==="
        smbclient -L stark-backup -U "MARVEL\tonystark%IronManStrong123!" -d 0 >/dev/null 2>&1 || true
        sleep 60
    done
) &

# 4. Start supervisord in the foreground
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
