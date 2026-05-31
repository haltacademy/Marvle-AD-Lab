#!/bin/bash
set -e

# Path to Samba AD DB to check if already provisioned
SAM_LDB="/var/lib/samba/private/sam.ldb"

if [ ! -f "$SAM_LDB" ]; then
    mkdir -p /var/log/samba
    echo "=== Provisioning Active Directory Domain Controller ===" | tee -a /var/log/samba/provision.log
    # Remove existing smb.conf if present, as provision requires it
    rm -f /etc/samba/smb.conf
    
    # Provision Samba AD DC
    samba-tool domain provision \
        --use-rfc2307 \
        --realm=MARVEL.LOCAL \
        --domain=MARVEL \
        --server-role=dc \
        --dns-backend=SAMBA_INTERNAL \
        --adminpass="StarkPassword123!" \
        --option="dns forwarder = 8.8.8.8" >> /var/log/samba/provision.log 2>&1
    
    # Disable SMB signing on the AD DC to allow SMB relay attacks
    sed -i '/\[global\]/a \ \ \ \ server signing = disabled' /etc/samba/smb.conf || true
    
    # Configure Kerberos client config
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
    
    echo "=== Creating Custom AD Groups and Users ==="
    # Add custom groups
    samba-tool group add Avengers-Leaders || true
    samba-tool group add Avengers-Main || true
    samba-tool group add Service-Accounts || true

    # Define AD users with different privilege levels (Username:Password:Group)
    USERS_AD=(
        "nickfury:DirectorFury123!:Domain Admins"
        "tonystark:IronManStrong123!:Domain Admins"
        "steverogers:CapShield123!:Avengers-Leaders"
        "brucebanner:HulkSmashPass123!:Avengers-Main"
        "natasharomanoff:BlackWidowSpy123!:Avengers-Main"
        "thorodinson:GodOfThunder123!:Avengers-Main"
        "peterparker:SpideyWebSlinger123!:Domain Users"
        "sql_service:SqlServicePass123!:Service-Accounts"
        "http_service:WebServicesStark99!:Service-Accounts"
    )

    for item in "${USERS_AD[@]}"; do
        username="${item%%:*}"
        rest="${item#*:}"
        password="${rest%%:*}"
        group="${rest#*:}"
        
        echo "Creating AD user: $username (Group: $group)" >> /var/log/samba/provision.log
        samba-tool user create "$username" "$password" >> /var/log/samba/provision.log 2>&1 || true
        
        if [ "$group" != "Domain Users" ] && [ "$group" != "Domain Admins" ]; then
            samba-tool group addmembers "$group" "$username" >> /var/log/samba/provision.log 2>&1 || true
        elif [ "$group" == "Domain Admins" ]; then
            samba-tool group addmembers "Domain Admins" "$username" >> /var/log/samba/provision.log 2>&1 || true
        fi
        
        # Create local directory and user flag for AD user
        mkdir -p "/home/$username"
        echo "FLAG{machine2_${username}_user_compromised}" > "/home/${username}/user.txt"
        chmod 644 "/home/${username}/user.txt"
    done

    # Write root flag
    echo "FLAG{machine2_root_compromised}" > /root/root.txt
    chmod 600 /root/root.txt

    echo "=== Registering Service Principal Names (SPNs) for Kerberoasting ===" >> /var/log/samba/provision.log
    samba-tool spn add MSSQLSvc/marvel-sql.marvel.local:1433 sql_service >> /var/log/samba/provision.log 2>&1 || true
    samba-tool spn add HTTP/marvel-web.marvel.local http_service >> /var/log/samba/provision.log 2>&1 || true
    
    echo "=== Provisioning Completed ===" >> /var/log/samba/provision.log
else
    echo "=== Active Directory Domain already provisioned ==="
fi

# Configure NSS host resolution to fallback to WINS (NetBIOS broadcast name query)
sed -i 's/hosts:.*/hosts:          files dns wins/' /etc/nsswitch.conf || true

# Start background loop to simulate network name resolution queries (misspelled share access)
# This will broadcast NetBIOS name queries for a non-existent fileshare 'stark-fileshare'.
# If Responder is listening on the subnet, it will respond, and this client will send
# the NTLM hash of 'sql_service' to the attacker VM / pivot machine.
(
    echo "=== Initializing LLMNR/NetBIOS Traffic Generator ==="
    # Wait for the Samba AD DC to fully start up and bind to interfaces
    sleep 30
    while true; do
        echo "=== Simulating WINS/NetBIOS name query for stark-fileshare ==="
        # Attempt to list shares on non-existent 'stark-fileshare' using sql_service account.
        # WINS/NetBIOS lookup will broadcast on 172.168.1.255.
        smbclient -L stark-fileshare -U "MARVEL\sql_service%SqlServicePass123!" -d 0 >/dev/null 2>&1 || true
        # Wait 60 seconds before next broadcast
        sleep 60
    done
) &

echo "=== Starting Samba Active Directory Domain Controller ==="
# Run Samba in foreground (AD DC mode requires the 'samba' binary, not smbd/nmbd)
exec /usr/sbin/samba -F --no-process-group
