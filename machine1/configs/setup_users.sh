#!/bin/bash

# Define 20 Marvel characters (username:password)
USERS=(
    "tonystark:iamironman"
    "steverogers:capshield75"
    "thor:godofthunder"
    "brucebanner:hulksmash!"
    "natasharomanoff:blackwidow"
    "clintbarton:hawkeye123"
    "nickfury:motherfury"
    "peterparker:spideyweb"
    "wandamaximoff:scarletwitch"
    "vision:mindstone"
    "tchalla:wakandaforever"
    "stephenstrange:sorcerersupreme"
    "caroldanvers:captainmarvel"
    "buckybarnes:wintersoldier"
    "samwilson:falconfly"
    "scottlang:antman88"
    "hopedyne:waspsting"
    "loki:godofmischief"
    "thanos:inevitable"
    "philcoulson:tahiti_is_nice"
)

# Loop through and create each user
for item in "${USERS[@]}"; do
    username="${item%%:*}"
    password="${item##*:}"
    
    echo "Creating user: $username..."
    
    # 1. Create Linux system user
    useradd -m -s /bin/bash "$username"
    echo "$username:$password" | chpasswd
    
    # Write compromise flag
    echo "FLAG{machine1_${username}_user_compromised}" > "/home/${username}/user.txt"
    chown "${username}:${username}" "/home/${username}/user.txt"
    chmod 600 "/home/${username}/user.txt"
    
    # 2. Add user to Samba database
    (echo "$password"; echo "$password") | smbpasswd -a -s "$username"
done

# Write root compromise flag
echo "FLAG{machine1_root_compromised}" > /root/root.txt
chmod 600 /root/root.txt
