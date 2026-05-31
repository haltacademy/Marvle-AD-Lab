FROM almalinux:9

RUN dnf update -y && dnf install -y \
    openssh-server \
    openssh-clients \
    iproute \
    iputils \
    procps-ng \
    sudo \
    && dnf clean all

RUN ssh-keygen -A

RUN useradd -m -s /bin/bash steverogers && \
    echo "steverogers:CapShield123!" | chpasswd && \
    echo "steverogers ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "FLAG{cap_workstation_steverogers_user_compromised}" > /home/steverogers/user.txt && \
    chown steverogers:steverogers /home/steverogers/user.txt && \
    chmod 600 /home/steverogers/user.txt && \
    echo "FLAG{cap_workstation_root_compromised}" > /root/root.txt && \
    chmod 600 /root/root.txt && \
    echo -e "MARVEL\\\tonystark:ef684e3ef27d029b577f51e6a50354bf\n# Simulated domain credentials backup for Pass-the-Hash AD testing" > /root/ad_hash.txt && \
    chmod 600 /root/ad_hash.txt

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
