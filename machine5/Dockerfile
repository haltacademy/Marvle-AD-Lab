FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    cron \
    gcc \
    make \
    libcap2-bin \
    python3 \
    nano \
    vim \
    less \
    tar \
    curl \
    iproute2 \
    iputils-ping \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set up SSH configuration
RUN mkdir /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Create low-privilege user sharon
RUN useradd -m -s /bin/bash sharon && \
    echo "sharon:password123" | chpasswd

# Setup flag files
RUN echo "FLAG{machine5_sharon_user_compromised}" > /home/sharon/user.txt && \
    chown sharon:sharon /home/sharon/user.txt && \
    chmod 644 /home/sharon/user.txt && \
    echo "FLAG{machine5_root_compromised}" > /root/root.txt && \
    chmod 600 /root/root.txt

# LPE Challenge 1: Writable /etc/passwd
RUN chmod 666 /etc/passwd

# LPE Challenge 2: Sudo with LD_PRELOAD
RUN echo 'sharon ALL=(root) NOPASSWD: /usr/bin/uptime' > /etc/sudoers.d/sharon && \
    echo 'Defaults:sharon env_keep += "LD_PRELOAD"' >> /etc/sudoers.d/sharon && \
    chmod 0440 /etc/sudoers.d/sharon

# LPE Challenge 3: SUID Binary (env)
RUN chmod +s /usr/bin/env

# LPE Challenge 4: Cron Job with Writable Script
RUN echo "* * * * * root /usr/local/bin/cleanup.sh" > /etc/cron.d/cleanup_cron && \
    chmod 0644 /etc/cron.d/cleanup_cron && \
    echo '#!/bin/bash\necho "Cleaning up temporary logs..."' > /usr/local/bin/cleanup.sh && \
    chmod 777 /usr/local/bin/cleanup.sh

# LPE Challenge 5: File Capabilities (python3 setuid)
RUN setcap cap_setuid+ep $(readlink -f /usr/bin/python3)

# LPE Challenge 6: Cron job wildcard expansion (tar)
RUN echo "* * * * * root cd /var/log/backup && tar -cf /tmp/backup.tar *" > /etc/cron.d/tar_cron && \
    chmod 0644 /etc/cron.d/tar_cron && \
    mkdir -p /var/log/backup && \
    chmod 777 /var/log/backup

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSH port
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
