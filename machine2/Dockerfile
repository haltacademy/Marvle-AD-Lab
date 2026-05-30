FROM debian:12-slim

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Samba AD DC dependencies, Kerberos, and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    samba \
    samba-ad-provision \
    samba-dsdb-modules \
    samba-vfs-modules \
    smbclient \
    winbind \
    libnss-winbind \
    krb5-admin-server \
    krb5-kdc \
    krb5-user \
    ldb-tools \
    iproute2 \
    iputils-ping \
    procps \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Active Directory ports (internal only, not mapped to host)
EXPOSE 53 88 135 138 139 389 445 464 636 3268 3269

ENTRYPOINT ["/entrypoint.sh"]
