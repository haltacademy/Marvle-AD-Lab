FROM ubuntu:22.04

# Avoid interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update repository and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    nginx \
    vsftpd \
    samba \
    smbclient \
    openssh-server \
    mysql-server \
    postfix \
    nfs-kernel-server \
    rpcbind \
    php-fpm \
    php-mysql \
    php \
    net-tools \
    iproute2 \
    iptables \
    curl \
    sudo \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Setup SSH directory and SSH service
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Copy user setup script and run it
COPY configs/setup_users.sh /tmp/setup_users.sh
RUN chmod +x /tmp/setup_users.sh && /tmp/setup_users.sh && rm /tmp/setup_users.sh

# Setup directories for services
RUN mkdir -p /var/run/vsftpd/empty && \
    mkdir -p /srv/ftp && \
    chown -R tonystark:root /srv/ftp && \
    chmod 755 /srv/ftp

# Setup SMB share directory
RUN mkdir -p /srv/samba/share && \
    chown -R tonystark:root /srv/samba/share && \
    chmod 777 /srv/samba/share

# Setup NFS shared directory
RUN mkdir -p /srv/nfs/share && \
    chown -R tonystark:root /srv/nfs/share && \
    chmod 777 /srv/nfs/share

# Setup PHP-FPM socket directory and permissions for Nginx panel
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php && \
    mkdir -p /var/www/html/panel/uploads && \
    chown -R www-data:www-data /var/www/html/panel

# Copy configurations
COPY configs/nginx.conf /etc/nginx/sites-available/default
COPY configs/index.html /var/www/html/index.html
COPY configs/panel/index.php /var/www/html/panel/index.php
COPY configs/panel/config.php /var/www/html/panel/config.php
COPY configs/vsftpd.conf /etc/vsftpd.conf
COPY configs/smb.conf /etc/samba/smb.conf
COPY configs/exports /etc/exports
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create FTP note.txt to establish initial access link
RUN echo "Steve, I have uploaded the database configuration tools to the secure panel at /panel/ so you can verify our hash database. Let me know if you find any weak hashes. - Tony" > /srv/ftp/note.txt && \
    chown tonystark:root /srv/ftp/note.txt && \
    chmod 644 /srv/ftp/note.txt

# Finalize permissions for php-fpm execution and uploads directory
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod 777 /var/www/html/panel/uploads

# Postfix configuration for SMTP (local delivery setup)
RUN postconf -e "inet_interfaces = all" && \
    postconf -e "mynetworks = 10.10.1.0/24 172.168.1.0/24 127.0.0.0/8" && \
    postconf -e "mail_owner = postfix"

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 80 2121 2222 1399 4445 33060 2525 2049 111

ENTRYPOINT ["/entrypoint.sh"]
