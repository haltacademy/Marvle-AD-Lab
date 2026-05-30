FROM rockylinux:9

RUN dnf update -y && dnf install -y \
    openssh-server \
    openssh-clients \
    iproute \
    iputils \
    procps-ng \
    sudo \
    && dnf clean all

RUN ssh-keygen -A

RUN useradd -m -s /bin/bash tonystark && \
    echo "tonystark:IronManStrong123!" | chpasswd && \
    echo "tonystark ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "FLAG{stark_workstation_tonystark_user_compromised}" > /home/tonystark/user.txt && \
    chown tonystark:tonystark /home/tonystark/user.txt && \
    chmod 600 /home/tonystark/user.txt && \
    echo "FLAG{stark_workstation_root_compromised}" > /root/root.txt && \
    chmod 600 /root/root.txt

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
