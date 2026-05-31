#!/bin/bash

# Start the cron daemon
service cron start

# Ensure ssh host keys are generated
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Run SSH daemon in foreground
echo "=== Starting SSH Daemon on Machine 5 ==="
exec /usr/sbin/sshd -D
